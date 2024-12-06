"use client";

import React from "react";
import Head from "next/head";
import Navbar from "@/app/components/navBar";
import Footer from "@/app/components/footer";

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
          </div>
        </main>
        <Footer />
      </div>
    </>
  );
}
