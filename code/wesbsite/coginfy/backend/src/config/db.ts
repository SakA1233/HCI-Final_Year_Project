import mongoose from "mongoose"; // Import the Mongoose library for MongoDB connection.

// Function to connect to the MongoDB database.
const connectDB = async (): Promise<void> => {
  try {
    // Get the MongoDB connection URI from environment variables.
    const mongoURI = process.env.MONGO_URI;

    // Check if the connection string exists. If not, throw an error.
    if (!mongoURI) {
      throw new Error("MONGO_URI is not defined in the environment variables");
    }

    // Attempt to connect to MongoDB using the provided URI.
    await mongoose.connect(mongoURI);

    // Log a success message if the connection is established.
    console.log("MongoDB Connected...");
  } catch (err) {
    // Log an error message if the connection fails and exit the process.
    console.error(`Database connection error: ${(err as Error).message}`);
    process.exit(1); // Exit with a failure code (1).
  }
};

export default connectDB; // Export the function for use in other files.
