"use client";

// Import necessary libraries and components
import React from "react";
import Head from "next/head";
import Link from "next/link";

// Define the Home component
export default function Home() {
  return (
    <>
      <Head>
        <title>Cognify - Empowering Minds</title>
        <meta
          name="description"
          content="Empowering minds one step at a time"
        />
      </Head>

      {/* Main container with background and text color */}
      <div className="flex flex-col min-h-screen bg-background text-foreground transition duration-300">
        <main className="flex-grow text-center py-16 px-8">
          <div className="max-w-3xl mx-auto">
            <h1 className="text-5xl font-bold mb-6 text-heading">
              Welcome to Cognify
            </h1>
            {/* Subtitle/Description */}
            <p className="text-xl mb-8 text-text">
              Explore our games and tools designed to enhance cognitive skills
              and empower your mind.
            </p>
            {/* Buttons for navigation */}
            <div className="flex flex-col space-y-4 sm:space-y-0 sm:flex-row sm:space-x-6 justify-center">
              <Link href="/play" className="btn">
                Play Games
              </Link>
              <Link href="/about" className="btn">
                Learn More
              </Link>
              <Link href="/login" className="btn">
                Log In
              </Link>
            </div>
            {/* Image section */}
            <div className="mt-12">
              <img
                src="/images/brain.png" // Path to the image
                alt="Cognitive Growth Illustration" // Alternative text for accessibility
                className="w-full max-w-md mx-auto rounded-lg shadow-md dark:shadow-lg" // Styling for the image
              />
            </div>
          </div>
        </main>
      </div>
    </>
  );
}
