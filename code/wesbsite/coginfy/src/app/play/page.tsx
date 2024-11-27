import React from "react";

const games = [
  { id: 1, title: "Memory Match", description: "Sharpen your memory with this matching game.", image: "/images/memory_game_image.png" },
  { id: 2, title: "Word Puzzle", description: "Test your vocabulary with exciting word puzzles.", image: "/images/word-puzzle.png" },
  { id: 3, title: "Math Challenge", description: "Enhance your math skills with fun challenges.", image: "/images/math-challenge.png" },
];

export default function GamesPage() {
  return (
    <div className="bg-gray-50 min-h-screen">
      <header className="bg-blue-100 text-gray-800 py-6 px-8">
        <h1 className="text-4xl font-bold text-center">Our Games</h1>
        <p className="text-lg text-center mt-2 max-w-2xl mx-auto">
          Explore our games designed to enhance cognitive skills and provide hours of fun.
        </p>
      </header>

      <main className="max-w-6xl mx-auto py-12 px-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {games.map((game) => (
          <div
            key={game.id}
            className="bg-white shadow-lg rounded-lg overflow-hidden hover:shadow-xl transition-shadow"
          >
            <img
              src={game.image}
              alt={game.title}
              className="w-full h-48 object-cover"
            />
            <div className="p-6">
              <h2 className="text-2xl font-bold mb-2">{game.title}</h2>
              <p className="text-gray-700">{game.description}</p>
            </div>
          </div>
        ))}
      </main>
    </div>
  );
}
