const crypto = require("crypto")

// Generate a secure random 32-byte key for AES-256
const key = crypto.randomBytes(32)
console.log("Generated key (hex):", key.toString("hex"))
console.log("Generated key (base64):", key.toString("base64"))
console.log("Key length:", key.length, "bytes")

// For use in your server.js:
console.log("\nCopy this line to your server.js:")
console.log(`const ENCRYPTION_KEY = Buffer.from('${key.toString("hex")}', 'hex'); // 32 bytes for AES-256`)

