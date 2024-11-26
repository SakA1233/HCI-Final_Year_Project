import React from 'react';
import Navbar from '@/app/components/navBar';
import Footer from '@/app/components/footer';

export default function AboutLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex flex-col min-h-screen">
      <Navbar />
      <main className="flex-grow">{children}</main>
      <Footer />
    </div>
  );
}
