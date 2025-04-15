"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

const NavbarComponent = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [darkMode, setDarkMode] = useState(false);
  const router = useRouter();

  // Load user authentication & dark mode state
  useEffect(() => {
    const checkLoginStatus = () => {
      const user = localStorage.getItem("user");
      setIsLoggedIn(!!user);
    };

    // Check initial status
    checkLoginStatus();

    // Add event listener for storage changes (other tabs)
    window.addEventListener('storage', checkLoginStatus);

    // Create a custom event listener for same-tab changes
    window.addEventListener('loginStateChange', checkLoginStatus);

    const theme = localStorage.getItem("theme");
    if (theme === "dark") {
      document.documentElement.classList.add("dark");
      setDarkMode(true);
    }

    return () => {
      window.removeEventListener('storage', checkLoginStatus);
      window.removeEventListener('loginStateChange', checkLoginStatus);
    };
  }, []);

  // Toggle Dark Mode
  const toggleDarkMode = () => {
    if (darkMode) {
      document.documentElement.classList.remove("dark");
      localStorage.setItem("theme", "light");
    } else {
      document.documentElement.classList.add("dark");
      localStorage.setItem("theme", "dark");
    }
    setDarkMode(!darkMode);
  };

  const handleLogout = () => {
    localStorage.removeItem("user");
    setIsLoggedIn(false);
    // Dispatch custom event for same-tab updates
    window.dispatchEvent(new Event('loginStateChange'));
    router.push("/login");
  };

  return (
    <header className="navbar py-4 px-8 transition duration-300">
      <nav className="flex justify-between items-center">
        <Link href="/" className="text-3xl font-bold hover:underline">
          Cognify
        </Link>

        <ul className="flex space-x-6 text-lg">
          <li>
            <Link href="/play" className="hover:underline">
              Play
            </Link>
          </li>
          <li>
            <Link href="/about" className="hover:underline">
              About Us
            </Link>
          </li>

          {isLoggedIn ? (
            <li>
              <button
                onClick={handleLogout}
                className="text-red-600 hover:text-red-700 dark:text-red-500 dark:hover:text-red-400 hover:underline"
              >
                Log Out
              </button>
            </li>
          ) : (
            <li>
              <Link href="/login" className="hover:underline">
                Log In
              </Link>
            </li>
          )}

          {/* Dark Mode Toggle */}
          <li>
            <button
              onClick={toggleDarkMode}
              className="p-2 rounded-md border border-gray-300 dark:border-gray-600 bg-gray-200 dark:bg-darkBg text-gray-900 dark:text-white hover:bg-gray-300 dark:hover:bg-gray-700 transition duration-300"
            >
              {darkMode ? "☀️ Light Mode" : "🌙 Dark Mode"}
            </button>
          </li>
        </ul>
      </nav>
    </header>
  );
};

export default NavbarComponent;
