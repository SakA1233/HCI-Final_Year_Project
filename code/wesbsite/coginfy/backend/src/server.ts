// Import required modules
import express from "express"; // Framework for building APIs
import dotenv from "dotenv"; // Load environment variables
import cors from "cors"; // Enable cross-origin requests
import connectDB from "./config/db"; // Database connection function
import authRoutes from "./routes/auth"; // Authentication routes

// Load environment variables
dotenv.config();

const app = express(); // Create an Express app

// Allow requests from the frontend (localhost:3000)
app.use(
  cors({
    origin: "http://localhost:3000",
    methods: ["GET", "POST"],
    credentials: true,
  })
);

// Parse JSON data in requests
app.use(express.json());

// Connect to MongoDB
connectDB()
  .then(() => console.log("MongoDB Connected...")) // Success message
  .catch((err) => console.error("MongoDB Connection Error:", err)); // Error message

// Test route to check if the API is running
app.get("/", (req, res) => {
  res.send("API is running...");
});

// Use authentication routes
app.use("/api/auth", authRoutes);

// Start the server
const PORT = process.env.PORT || 5001; // Use the port from .env or default to 5001
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
