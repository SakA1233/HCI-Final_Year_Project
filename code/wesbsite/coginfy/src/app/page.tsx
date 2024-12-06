"use client";

import React from "react";
import Head from "next/head";
import Navbar from "@/app/components/navBar";
import Footer from "@/app/components/footer";
import Link from "next/link";

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
      <div className="flex flex-col min-h-screen bg-gray-50">
        <Navbar />
        <main className="flex-grow text-center py-16 px-8">
          <div className="max-w-3xl mx-auto">
            <h1 className="text-5xl font-bold mb-6 text-blue-600">
              Welcome to Cognify
            </h1>
            <p className="text-xl mb-8 text-gray-700">
              Explore our games and tools designed to enhance cognitive skills
              and empower your mind.
            </p>

            {/* Buttons */}
            <div className="flex flex-col space-y-4 sm:space-y-0 sm:flex-row sm:space-x-6 justify-center">
              <Link
                href="/play"
                className="bg-blue-100 text-blue-700 text-lg font-semibold py-3 px-8 rounded-lg shadow-md hover:bg-blue-200 transition duration-300"
              >
                Play Games
              </Link>
              <Link
                href="/about"
                className="bg-blue-100 text-blue-700 text-lg font-semibold py-3 px-8 rounded-lg shadow-md hover:bg-blue-200 transition duration-300"
              >
                Learn More
              </Link>
              <Link
                href="/login"
                className="bg-blue-100 text-blue-700 text-lg font-semibold py-3 px-8 rounded-lg shadow-md hover:bg-blue-200 transition duration-300"
              >
                Log In
              </Link>
            </div>
          </div>
        </main>
        <Footer />
      </div>
    </>
  );
}
