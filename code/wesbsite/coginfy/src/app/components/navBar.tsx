import React from "react";
import Link from "next/link";

const NavbarComponent = () => {
  return (
    <header className="bg-blue-100 py-4 px-8">
      <nav className="flex justify-between items-center">
        {/* Cognify logo links to home */}
        <Link href="/" className="text-3xl font-bold hover:underline">
          Cognify
        </Link>
        <ul className="flex space-x-6 text-lg">
          <li>
            <Link href="#get-started" className="hover:underline">
              Get Started
            </Link>
          </li>
          <li>
            <Link href="/about" className="hover:underline">
              About Us
            </Link>
          </li>
          <li>
            <Link href="#login" className="hover:underline">
              Log In
            </Link>
          </li>
        </ul>
      </nav>
    </header>
  );
};

export default NavbarComponent;
