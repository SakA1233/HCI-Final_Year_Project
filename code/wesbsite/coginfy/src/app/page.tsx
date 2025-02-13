"use client";

// Import necessary libraries and components
import React from "react";
import Head from "next/head";
import Navbar from "@/app/components/navBar";
import Footer from "@/app/components/footer";
import Link from "next/link";

// Define the Home component
export default function Home() {
  return (
    <>
      {/* Set metadata for the webpage */}
      <Head>
        <title>Cognify - Empowering Minds</title>
        <meta
          name="description"
          content="Empowering minds one step at a time"
        />
      </Head>

      {/* Main page container */}
      <div className="flex flex-col min-h-screen bg-gray-50">
        {/* Include the Navbar at the top */}
        <Navbar />

        {/* Main content area */}
        <main className="flex-grow text-center py-16 px-8">
          {/* Centered content container */}
          <div className="max-w-3xl mx-auto">
            {/* Title */}
            <h1 className="text-5xl font-bold mb-6 text-blue-600">
              Welcome to Cognify
            </h1>

            {/* Subtitle/Description */}
            <p className="text-xl mb-8 text-gray-700">
              Explore our games and tools designed to enhance cognitive skills
              and empower your mind.
            </p>

            {/* Buttons for navigation */}
            <div className="flex flex-col space-y-4 sm:space-y-0 sm:flex-row sm:space-x-6 justify-center">
              {/* Button to the Play Games page */}
              <Link
                href="/play"
                className="bg-blue-100 text-blue-700 text-lg font-semibold py-3 px-8 rounded-lg shadow-md hover:bg-blue-200 transition duration-300"
              >
                Play Games
              </Link>

              {/* Button to the Learn More page */}
              <Link
                href="/about"
                className="bg-blue-100 text-blue-700 text-lg font-semibold py-3 px-8 rounded-lg shadow-md hover:bg-blue-200 transition duration-300"
              >
                Learn More
              </Link>

              {/* Button to the Log In page */}
              <Link
                href="/login"
                className="bg-blue-100 text-blue-700 text-lg font-semibold py-3 px-8 rounded-lg shadow-md hover:bg-blue-200 transition duration-300"
              >
                Log In
              </Link>
            </div>

            {/* Image section */}
            <div className="mt-12">
              <img
                src="../images/brain.png" // Path to the image
                alt="Cognitive Growth Illustration" // Alternative text for accessibility
                className="w-full max-w-md mx-auto rounded-lg shadow-md" // Styling for the image
              />
            </div>
          </div>
        </main>

        {/* Include the Footer at the bottom */}
        <Footer />
      </div>
    </>
  );
}
