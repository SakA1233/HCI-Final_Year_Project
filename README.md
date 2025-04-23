# Final Year Project

# 🧠 Cognify & Lumina

This project explores accessibility and usability for elderly users by developing two digital interfaces grounded in Human-Computer Interaction (HCI) principles:

- **Cognify**: A cognitive training website that prioritises readability, simplicity, and accessible design.
- **Lumina**: A real-time messaging app designed with older users in mind, featuring large fonts, dark mode, voice support, and intuitive navigation.

---

## 📦 Features

### Cognify (Web Platform)

- Large, high-contrast text
- Adjustable themes (light/dark mode)
- Simple, responsive navigation
- Secure login system with MongoDB backend

### Lumina (Mobile Messaging App)

- Real-time messaging using Firebase Firestore
- Chatbot integration to simulate conversation
- Font scaling and dark mode toggle
- Text-to-speech and mock voice command support
- Clean and minimal chat interface

---

## 🛠️ Technologies Used

### Cognify

- React (Next.js)
- Tailwind CSS
- TypeScript
- Express.js (Backend)
- MongoDB (Database)

### Lumina

- Flutter (Dart)
- Firebase Firestore & Auth
- Provider (state management)
- TTS and simulated voice command integration

---

## 🚀 Setup Instructions

### 📍 Cognify Website

#### Prerequisites

- Node.js & npm
- MongoDB Atlas account (or local MongoDB instance)
- Git

#### Steps to Run

1. Clone the repository:
   git clone https://gitlab.cim.rhul.ac.uk/zlac406/PROJECT.git

   cd cognify
   npm install

2. Install dependencies:
   npm install

3. Create a .env.local file in the root directory and add your environment variables:
   MONGODB_URI

4. Start the development server for backend and frontend:
   npm run dev

Lumina Messaging App
Prerequisites
Flutter SDK

Firebase project (Firestore & Auth enabled)

Android Studio or Xcode (for mobile emulation)

Git

Steps to Run

### 📍 Lumina Messaging App

### Prerequisites

Flutter SDK

Firebase project (Firestore & Auth enabled)

Android Studio or Xcode (for mobile emulation)

Git

### Steps to Run

1. Clone the repository:
   git clone https://gitlab.cim.rhul.ac.uk/zlac406/PROJECT.git

2. Install dependencies:
   flutter pub get

3. Connect your Firebase project:

   - Add your google-services.json (Android) or GoogleService-Info.plist (iOS) to the respective platform directories.

   - Enable Firestore and Authentication in Firebase Console.

4. Run the app:  
   flutter run

⚠️ Note: Due to iOS restrictions, some features (such as voice input and testing on physical iOS devices) were mocked or demonstrated using a chatbot and test commands.

🔒 License
This project uses open-source libraries. Ensure you follow individual licensing terms if adapting components.

📧 Author
Sakariya Aden
Royal Holloway, University of London
Supervisor: [Gregory Gutin]
Email: [zlac406@live.rhul.ac.uk]
