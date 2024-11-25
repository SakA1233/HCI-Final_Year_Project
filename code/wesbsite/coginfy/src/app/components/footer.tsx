import React from 'react';
import { FaFacebook, FaInstagram } from 'react-icons/fa';

const Footer = () => {
  return (
    <footer className="bg-blue-100 py-4 text-center">
      <div className="text-lg font-medium text-gray-700">
        <p>&copy; {new Date().getFullYear()} Cognify</p>
        <p>Empowering minds one step at a time</p>
      </div>
      <div className="flex justify-center space-x-6 mt-4">
        {/* Facebook Icon */}
        <a
          href="https://facebook.com"
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Visit our Facebook page"
          className="text-gray-700 hover:text-blue-600"
        >
          <FaFacebook size={24} />
        </a>

        {/* Instagram Icon */}
        <a
          href="https://instagram.com"
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Visit our Instagram page"
          className="text-gray-700 hover:text-pink-500"
        >
          <FaInstagram size={24} />
        </a>

        {/* X Icon */}
        <a
          href="https://x.com"
          target="_blank"
          rel="noopener noreferrer"
          aria-label="Visit our X profile"
          className="text-gray-700 hover:text-blue-400"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 300 300.251"
            width="24"
            height="24"
            fill="currentColor"
            className="hover:text-gray-500"
          >
            <path d="M178.57 127.15 290.27 0h-26.46l-97.03 110.38L89.34 0H0l117.13 166.93L0 300.25h26.46l102.4-116.59 81.8 116.59h89.34M36.01 19.54H76.66l187.13 262.13h-40.66" />
          </svg>
        </a>
      </div>
    </footer>
  );
};

export default Footer;
