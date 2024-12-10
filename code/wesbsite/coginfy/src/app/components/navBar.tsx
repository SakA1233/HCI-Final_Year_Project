"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

const NavbarComponent = () => {
  const [isLoggedIn, setIsLoggedIn] = useState<boolean>(false);
  const router = useRouter();

  useEffect(() => {
    const user = localStorage.getItem("user");
    setIsLoggedIn(!!user);
  }, []);

  const handleLogout = () => {
    localStorage.removeItem("user");
    setIsLoggedIn(false);
    router.push("/login");
  };

  return (
    <header className="bg-blue-100 py-4 px-8">
      <nav className="flex justify-between items-center">
        {/* Cognify logo links to home */}
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
