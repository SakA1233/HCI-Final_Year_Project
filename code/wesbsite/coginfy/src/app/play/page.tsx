import React from "react";
import Link from "next/link";

// Array of games with their details
const games = [
  {
    id: 1,
    title: "Memory Match",
    description: "Sharpen your memory with this matching game.",
    image: "/images/memory_game_image2.png", // Path to the game image
    route: "/play/memory-match", // Route for the game page
  },
  {
    id: 2,
    title: "Word Puzzle",
    description: "Test your vocabulary with exciting word puzzles.",
    image: "/images/word_puzzle_image.png",
    route: "/play/word-puzzle",
  },
  {
    id: 3,
    title: "Math Challenge",
    description: "Enhance your math skills with fun challenges.",
    image: "/images/number_image.png",
    route: "/play/math-challenge",
  },
];

// Component for the Games page
export default function GamesPage() {
  return (
    <div className="bg-gray-50 min-h-screen">
      {" "}
      {/* Main container with background color and minimum height */}
      {/* Header section */}
      <header className="bg-blue-100 text-gray-800 py-6 px-8">
        <h1 className="text-4xl font-bold text-center">Our Games</h1>{" "}
        {/* Page title */}
        <p className="text-lg text-center mt-2 max-w-2xl mx-auto">
          Explore our games designed to enhance cognitive skills and provide
          hours of fun.
        </p>
      </header>
      {/* Main content section */}
      <main className="max-w-6xl mx-auto py-12 px-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {/* Loop through the games array and display each game */}
        {games.map((game) => (
          <Link
            key={game.id} // Unique key for each game
            href={game.route} // Link to the game's specific page
            className="block bg-white shadow-lg rounded-lg overflow-hidden hover:shadow-xl transition-shadow"
          >
            {/* Game image */}
            <img
              src={game.image} // Image source for the game
              alt={game.title} // Alternative text for accessibility
              className="w-full h-56 object-cover object-center" // Styling for the image
            />
            {/* Game details */}
            <div className="p-6">
              <h2 className="text-2xl font-bold mb-2">{game.title}</h2>{" "}
              {/* Game title */}
              <p className="text-gray-700">{game.description}</p>{" "}
              {/* Game description */}
            </div>
          </Link>
        ))}
      </main>
    </div>
  );
}
