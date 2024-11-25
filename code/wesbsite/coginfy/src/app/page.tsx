import React from 'react';
import Head from 'next/head';
import Navbar from '@/app/components/navBar';
import Footer from '@/app/components/footer';

export default function Home() {
  return (
    <>
      <Head>
        <title>Cognify - Empowering Minds</title>
        <meta name="description" content="Empowering minds one step at a time" />
      </Head>
      <div className="flex flex-col min-h-screen">
        <Navbar />
        <main className="flex-grow text-center py-16 px-8">
          <h2 className="text-5xl font-bold mb-4">Cognify</h2>
          <p className="text-xl mb-6">Empowering minds one step at a time</p>
        </main>
        <Footer />
      </div>
    </>
  );
}
