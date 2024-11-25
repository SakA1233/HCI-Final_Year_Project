import React from 'react';

const Footer = () => {
  return (
    <footer className="bg-blue-100 py-4 text-center">
      <div className="text-lg font-medium text-gray-700">
        <p>&copy; {new Date().getFullYear()} Cognify</p>
        <p>Empowering minds one step at a time</p>
      </div>
      <div className="flex justify-center space-x-4 mt-2">
        <a
          href="#"
          className="text-gray-700 hover:underline focus:underline"
          aria-label="Visit our Facebook page"
        >
          Facebook
        </a>
        <a
          href="#"
          className="text-gray-700 hover:underline focus:underline"
          aria-label="Visit our X profile"
        >
          X
        </a>
        <a
          href="#"
          className="text-gray-700 hover:underline focus:underline"
          aria-label="Visit our Instagram page"
        >
          Instagram
        </a>
      </div>
    </footer>
  );
};

export default Footer;
