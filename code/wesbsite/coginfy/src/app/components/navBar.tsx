import React from 'react';

const NavbarComponent = () => {
  return (
    <header className="bg-blue-100 py-4 px-8">
      <nav className="flex justify-between items-center">
        <h1 className="text-3xl font-bold">Cognify</h1>
        <ul className="flex space-x-6 text-lg">
          <li><a href="#get-started" className="hover:underline">Get Started</a></li>
          <li><a href="#about-us" className="hover:underline">About Us</a></li>
          <li><a href="#login" className="hover:underline">Log In</a></li>
        </ul>
      </nav>
    </header>
  );
};

export default NavbarComponent;
