import express, { Request, Response } from "express"; // Import Express and types for request and response objects.
import bcrypt from "bcryptjs"; // Import bcrypt for password hashing and comparison.
import User, { IUser } from "../models/user"; // Import the User model and its type.

const router = express.Router(); // Create a new router for handling authentication routes.

// Register route
router.post("/register", async (req: Request, res: Response): Promise<void> => {
  const { name, email, password } = req.body;

  // Check if required fields are provided
  if (!name || !email || !password) {
    res.status(400).json({ message: "Name, email, and password are required" });
    return;
  }

  try {
    // Check if a user with the same email already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      res.status(400).json({ message: "User already exists" });
      return;
    }

    // Generate a salt and hash the password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create a new user and save to the database
    const user: IUser = new User({ name, email, password: hashedPassword });
    await user.save();

    // Respond with success message
    res.status(201).json({ message: "User registered successfully" });
  } catch (err) {
    // Handle any server errors
    res.status(500).json({ error: (err as Error).message });
  }
});

// Login route
router.post("/login", async (req: Request, res: Response): Promise<void> => {
  const { email, password } = req.body;

  // Check if required fields are provided
  if (!email || !password) {
    res.status(400).json({ message: "Email and password are required" });
    return;
  }

  try {
    // Find the user by email
    const user = await User.findOne<IUser>({ email });
    if (!user) {
      res.status(401).json({ message: "Invalid credentials" });
      return;
    }

    // Compare the password with the hashed password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      res.status(401).json({ message: "Invalid credentials" });
      return;
    }

    // Respond with success and user details
    res.status(200).json({
      message: "Login successful",
      user: { name: user.name, email: user.email },
    });
  } catch (err) {
    // Handle any server errors
    res.status(500).json({ error: (err as Error).message });
  }
});

export default router; // Export the router for use in the server.
