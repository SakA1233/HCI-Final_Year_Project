"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation"; // For navigation
import axios from "axios"; // For HTTP requests

export default function LoginPage() {
  // States for input fields, errors, and loading
  const [email, setEmail] = useState(""); // Email input
  const [password, setPassword] = useState(""); // Password input
  const [error, setError] = useState<string | null>(null); // Error message
  const [loading, setLoading] = useState(false); // Loading state
  const router = useRouter(); // For page redirection

  // Handles form submission
  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault(); // Stop default form behavior
    setError(null); // Reset errors
    setLoading(true); // Show loading

    try {
      // Send login request
      const response = await axios.post(
        "http://localhost:5001/api/auth/login",
        { email, password }
      );
      // Save user data and redirect to play page
      localStorage.setItem("user", JSON.stringify(response.data.user));
      // Dispatch custom event for same-tab updates
      window.dispatchEvent(new Event('loginStateChange'));
      router.push("/play");
    } catch (err: any) {
      // Show error if login fails
      setError(
        err.response?.data?.message || "Invalid login. Please try again."
      );
    } finally {
      setLoading(false); // Hide loading
    }
  };

  return (
    <>
      <div className="min-h-screen bg-background text-foreground flex items-center justify-center transition duration-300">
        <div className="bg-white dark:bg-darkCard p-8 shadow-md rounded-lg max-w-md w-full">
          <h1 className="text-2xl font-bold mb-6 text-center text-black">
            Login
          </h1>

          {/* Show error message */}
          {error && <p className="text-red-500 text-center mb-4">{error}</p>}

          {/* Login form */}
          <form onSubmit={handleLogin} className="space-y-4">
            {/* Email input */}
            <div>
              <label
                htmlFor="email"
                className="block text-gray-700 dark:text-gray-300"
              >
                Email
              </label>
              <input
                type="email"
                id="email"
                className="w-full border-gray-300 dark:border-gray-600 bg-white dark:bg-darkBg text-gray-900 dark:text-white rounded-lg p-2"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                placeholder="Enter your email"
              />
            </div>

            {/* Password input */}
            <div>
              <label
                htmlFor="password"
                className="block text-gray-700 dark:text-gray-300"
              >
                Password
              </label>
              <input
                type="password"
                id="password"
                className="w-full border-gray-300 dark:border-gray-600 bg-white dark:bg-darkBg text-gray-900 dark:text-white rounded-lg p-2"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                placeholder="Enter your password"
              />
            </div>

            {/* Submit button */}
            <button
              type="submit"
              className={`w-full py-2 rounded-lg transition ${
                loading
                  ? "bg-blue-300 dark:bg-navbar-footer-dark cursor-not-allowed" // Disabled button
                  : "bg-blue-500 dark:bg-navbar-footer-dark hover:bg-blue-600 dark:hover:bg-darkBg text-white" // Active button
              }`}
              disabled={loading}
            >
              {loading ? "Logging in..." : "Login"} {/* Button text */}
            </button>
          </form>
        </div>
      </div>
    </>
  );
}
