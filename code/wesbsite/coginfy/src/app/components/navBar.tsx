"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link"; // For navigation links
import { useRouter } from "next/navigation"; // For redirection

const NavbarComponent = () => {
  const [isLoggedIn, setIsLoggedIn] = useState(false); // Track if user is logged in
  const router = useRouter(); // For navigation

  // Check if the user is logged in when the page loads
  useEffect(() => {
    const user = localStorage.getItem("user");
    setIsLoggedIn(!!user); // Set to true if user exists
  }, []);

  // Log out the user
  const handleLogout = () => {
    localStorage.removeItem("user"); // Clear user info
    setIsLoggedIn(false); // Update state
    router.push("/login"); // Go to login page
  };

  return (
    <header className="bg-blue-100 py-4 px-8">
      <nav className="flex justify-between items-center">
        {/* Link to the home page */}
        <Link href="/" className="text-3xl font-bold hover:underline">
          Cognify
        </Link>

        {/* Navigation links */}
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

          {/* Show Log Out if logged in, Log In otherwise */}
          {isLoggedIn ? (
            <li>
              <button
                onClick={handleLogout}
                className="text-red-500 hover:underline"
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
        </ul>
      </nav>
    </header>
  );
};

export default NavbarComponent;
