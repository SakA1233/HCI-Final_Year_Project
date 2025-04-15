const express = require("express");
const admin = require("firebase-admin");
const crypto = require("crypto");
const cors = require("cors");

const app = express();

// Enable CORS for all routes
app.use(cors());
app.use(express.json());

// Initialize Firebase Admin SDK with service account
try {
  const serviceAccount = require("./serviceAccount.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log("Firebase Admin SDK initialized successfully");
} catch (error) {
  console.error("Error initializing Firebase Admin SDK:", error);
}

// Encryption Constants
const ENCRYPTION_KEY = Buffer.from('eea861fd2850a75153141d97e58e75fffc26e0c19bac160693dfa13f179e15c1', 'hex'); // 32 bytes for AES-256
console.log("ENCRYPTION_KEY (hex):", ENCRYPTION_KEY.toString("hex"));
console.log("ENCRYPTION_KEY length:", ENCRYPTION_KEY.length);

const IV_LENGTH = 16; // AES block size

// Middleware to verify Firebase ID token
async function verifyIdToken(req, res, next) {
  const authHeader = req.headers.authorization;

  // Local dev bypass token
  if (process.env.NODE_ENV === "development") {
    console.log("Development mode: bypassing authentication");
    req.user = { uid: "test-user-id" };
    return next();
  }

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(403).json({ error: "Unauthorized - No token provided" });
  }

  const idToken = authHeader.split("Bearer ")[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error("Error verifying ID token:", error);
    return res.status(403).json({ error: "Unauthorized - Invalid token" });
  }
}

// Encryption helpers
function encrypt(text) {
  try {
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipheriv("aes-256-cbc", ENCRYPTION_KEY, iv);
    let encrypted = cipher.update(text, "utf8", "base64");
    encrypted += cipher.final("base64");
    return { iv: iv.toString("base64"), data: encrypted };
  } catch (error) {
    console.error("Encryption error:", error);
    throw new Error("Failed to encrypt message");
  }
}

function decrypt(encrypted, iv) {
  try {
    const decipher = crypto.createDecipheriv(
      "aes-256-cbc",
      ENCRYPTION_KEY,
      Buffer.from(iv, "base64")
    );
    let decrypted = decipher.update(encrypted, "base64", "utf8");
    decrypted += decipher.final("utf8");
    return decrypted;
  } catch (error) {
    console.error("Decryption error:", error);
    return "[Encrypted message]";
  }
}

// Test route
app.get("/", (req, res) => {
  res.json({ message: "Encryption server is running" });
});

// Send message endpoint
app.post("/send-message", verifyIdToken, async (req, res) => {
  try {
    console.log("Received send-message request:", req.body);
    const { chatId, text } = req.body;
    const userId = req.user.uid;

    if (!chatId || !text) {
      return res.status(400).json({ error: "chatId and text required" });
    }

    // Encrypt
    const { iv, data } = encrypt(text);
    console.log("Message encrypted successfully");

    // Write to Firestore
    const messageRef = admin
      .firestore()
      .collection("conversations")
      .doc(chatId)
      .collection("messages")
      .doc();

    await messageRef.set({
      ciphertext: data,
      iv: iv,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isMine: true,
      userId: userId,
    });
    console.log("Message stored in Firestore");

    // Update conversation metadata with decrypted last message
    await admin.firestore().collection("conversations").doc(chatId).update({
      lastMessage: text,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      unread: true,
    });
    console.log("Conversation metadata updated");

    // Generate bot response
    const botResponse = generateBotResponse(text);
    console.log("Generated bot response:", botResponse);

    // Add a small delay before sending bot response
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Encrypt and store bot response
    const botEncrypted = encrypt(botResponse);
    const botMessageRef = admin
      .firestore()
      .collection("conversations")
      .doc(chatId)
      .collection("messages")
      .doc();

    await botMessageRef.set({
      ciphertext: botEncrypted.data,
      iv: botEncrypted.iv,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isMine: false,
      userId: 'bot',
    });

    // Update conversation metadata for bot response
    await admin.firestore().collection("conversations").doc(chatId).update({
      lastMessage: botResponse,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      unread: true,
    });

    res.json({ 
      success: true, 
      messageId: messageRef.id,
      botMessageId: botMessageRef.id 
    });
  } catch (error) {
    console.error("Error sending message:", error);
    res.status(500).json({ error: "Server error", details: error.message });
  }
});

// Bot response generation
function generateBotResponse(userMessage) {
  userMessage = userMessage.toLowerCase();

  // Simple responses
  if (userMessage.includes('hello') || userMessage.includes('hi')) {
    return 'Hello there! How can I help you today?';
  } else if (userMessage.includes('how are you')) {
    return 'I\'m doing well, thank you for asking! How about you?';
  } else if (userMessage.includes('help')) {
    return 'I\'m here to help! You can ask me about the app, or just chat with me.';
  } else if (userMessage.includes('thank')) {
    return 'You\'re welcome! Is there anything else I can help with?';
  } else if (userMessage.includes('bye') || userMessage.includes('goodbye')) {
    return 'Goodbye! Have a great day!';
  } else {
    // Default responses
    const defaultResponses = [
      'That\'s interesting! Tell me more.',
      'I understand. What else is on your mind?',
      'I see. How can I help with that?',
      'Thanks for sharing that with me.',
      'I\'m processing what you said. Can you elaborate?',
    ];

    // Return a random default response
    return defaultResponses[Math.floor(Math.random() * defaultResponses.length)];
  }
}

// Fetch messages endpoint
app.get("/messages/:chatId", verifyIdToken, async (req, res) => {
  try {
    console.log("Received fetch messages request for chat:", req.params.chatId);
    const { chatId } = req.params;
    const userId = req.user.uid;
    const lastTimestamp = req.headers['if-modified-since'];

    const snapshot = await admin
      .firestore()
      .collection("conversations")
      .doc(chatId)
      .collection("messages")
      .orderBy("timestamp", "desc")
      .limit(50)
      .get();

    console.log(`Retrieved ${snapshot.docs.length} messages`);

    const messages = snapshot.docs.map((doc) => {
      const data = doc.data();
      let text = "[Encrypted message]";

      if (data.ciphertext && data.iv) {
        try {
          text = decrypt(data.ciphertext, data.iv);
        } catch (error) {
          console.warn(`Could not decrypt message ${doc.id}:`, error);
        }
      } else if (data.text) {
        // For legacy unencrypted messages
        text = data.text;
      }

      return {
        id: doc.id,
        text: text,
        timestamp: data.timestamp
          ? data.timestamp.toDate().toISOString()
          : new Date().toISOString(),
        isMine: data.userId === userId || data.isMine === true,
      };
    });

    // If If-Modified-Since header is present and no new messages
    if (lastTimestamp && messages.length > 0 && messages[0].timestamp <= lastTimestamp) {
      return res.status(304).send();
    }

    // Mark conversation as read
    await admin.firestore().collection("conversations").doc(chatId).update({
      unread: false,
    });

    res.json({ messages });
  } catch (error) {
    console.error("Error fetching messages:", error);
    res.status(500).json({ error: "Server error", details: error.message });
  }
});

// Create chat endpoint
app.post("/create-chat", verifyIdToken, async (req, res) => {
  try {
    console.log("Received create-chat request:", req.body);
    const { name } = req.body;
    const userId = req.user.uid;

    if (!name) {
      return res.status(400).json({ error: "Chat name required" });
    }

    // Create a new chat document
    const chatRef = await admin.firestore().collection("conversations").add({
      name,
      createdBy: userId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      lastMessage: "Chat created",
      unread: false,
    });
    console.log("Chat created with ID:", chatRef.id);

    // Add welcome message
    const welcomeMessage = `Welcome to ${name}!`;
    const { iv, data } = encrypt(welcomeMessage);

    await chatRef.collection("messages").add({
      ciphertext: data,
      iv: iv,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      isMine: false,
      system: true,
    });
    console.log("Welcome message added");

    res.json({ success: true, chatId: chatRef.id });
  } catch (error) {
    console.error("Error creating chat:", error);
    res.status(500).json({ error: "Server error", details: error.message });
  }
});

// Update chat name endpoint
app.post("/update-chat", verifyIdToken, async (req, res) => {
  try {
    console.log("Received update-chat request:", req.body);
    const { chatId, name } = req.body;

    if (!chatId || !name) {
      return res.status(400).json({ error: "chatId and name required" });
    }

    await admin.firestore().collection("conversations").doc(chatId).update({ name });
    console.log("Chat name updated");

    res.json({ success: true });
  } catch (error) {
    console.error("Error updating chat:", error);
    res.status(500).json({ error: "Server error", details: error.message });
  }
});

// Delete chat endpoint
app.delete("/delete-chat/:chatId", verifyIdToken, async (req, res) => {
  try {
    console.log("Received delete-chat request for chat:", req.params.chatId);
    const { chatId } = req.params;

    // Delete the chat document and all its messages
    await admin.firestore().collection("conversations").doc(chatId).delete();
    console.log("Chat deleted");

    res.json({ success: true });
  } catch (error) {
    console.error("Error deleting chat:", error);
    res.status(500).json({ error: "Server error", details: error.message });
  }
});

// Fetch all chats endpoint
app.get("/chats", verifyIdToken, async (req, res) => {
  try {
    console.log("Received fetch chats request");
    const userId = req.user.uid;

    const snapshot = await admin
      .firestore()
      .collection("conversations")
      .orderBy("timestamp", "desc")
      .get();

    console.log(`Retrieved ${snapshot.docs.length} chats`);

    const chats = snapshot.docs.map((doc) => ({
      id: doc.id,
      name: doc.data().name || "Unnamed Chat",
      lastMessage: doc.data().lastMessage || "No messages yet",
      timestamp: doc.data().timestamp
        ? doc.data().timestamp.toDate().toISOString()
        : new Date().toISOString(),
      unread: doc.data().unread || false,
    }));

    res.json({ chats });
  } catch (error) {
    console.error("Error fetching chats:", error);
    res.status(500).json({ error: "Server error", details: error.message });
  }
});

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Test the server at http://localhost:${PORT}`);
});
