import mongoose, { Schema, Document, Model } from "mongoose"; // Import Mongoose and types for working with the database.

export interface IUser extends Document {
  name: string; // The user's name.
  email: string; // The user's email address.
  password: string; // The user's password.
  createdAt?: Date; // Optional: When the user was created.
  updatedAt?: Date; // Optional: When the user was last updated.
}

// Define the structure (schema) for a User in the database.
const UserSchema: Schema<IUser> = new mongoose.Schema(
  {
    name: { type: String, required: true }, // Name is required.
    email: { type: String, required: true, unique: true }, // Email is required and must be unique.
    password: { type: String, required: true }, // Password is required.
  },
  { timestamps: true } // Automatically adds createdAt and updatedAt fields.
);

// Create a User model to interact with the database.
const User: Model<IUser> = mongoose.model<IUser>("User", UserSchema);

// Export the model so it can be used elsewhere.
export default User;
