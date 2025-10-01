# ChatbotAI

Instead of paying a subscription, why not create your **own AI agent** with already trained models?  

This project is a **practice implementation of a mobile AI-powered chatbot**.  
It shows how to combine a simple iOS app, a Node.js message server, and an AI server (via [Ollama](https://ollama.ai/)) into a working system.  

The goal is to learn how to:  
- Build your own AI chatbot locally (no subscriptions needed)  
- Use real-time messaging with Socket.IO  
- Connect an iOS app to both a chat backend and an AI model  

The project is divided into three parts:

- **chatbot/** → iOS mobile app (Xcode project)  
- **messages-server/** → Node.js server for handling user messages  
- **ollama-server/** → Local AI server powered by [Ollama](https://ollama.ai/)  
- **Screenshots/** → App screenshots (1.PNG → 10.PNG)  

---
## 📦 Dependencies

- [MarkdownUI](https://github.com/gonzalezreal/MarkdownUI) → Used for rendering Markdown content inside the iOS app.
- [Socket.IO](https://socket.io/) → Real-time communication between clients and server.
- [Express.js](https://expressjs.com/) → Web framework for Node.js message server.
- [Ollama](https://ollama.ai/) → Local AI model runner (LLaMA2, Mistral, etc.).


## 📂 Folder Structure

```
ChatbotAI/
│
├── chatbot/            # iOS Xcode project (mobile app)
│
├── messages-server/    # Node.js Express server for chat messages
│   └── server.js
│
├── ollama-server/      # Local AI server with Ollama
│   └── server.js
│
└── Screenshots/        # Screenshots (1.PNG → 10.PNG)
```

---

## ⚡ Features

- Real-time **messaging** with WebSocket (Socket.IO)  
- AI **chatbot responses** using Ollama local models  
- **Mobile app** built in Swift (iOS)  
- Screenshot previews available in the `Screenshots/` folder  

---

## 🛠 Setup Instructions

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/yourusername/chatbotai.git
cd chatbotai
```

---

### 2️⃣ Setup the Messaging Server (Node.js)

1. Navigate to the **messages-server** folder:
   ```bash
   cd messages-server
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure environment variables: create `.env` file
   ```env
   PORT=4000
   MONGO_URI=mongodb://localhost:27017/chatbotai
   ```
4. Start the server:
   ```bash
   npm start
   ```
5. ✅ Server will run on:  
   ```
   http://localhost:4000
   ```

---

### 3️⃣ Setup the Ollama AI Server

#### Step 1. Install Ollama
- **macOS**:
  ```bash
  brew install ollama
  ```
- **Linux**:
  ```bash
  curl -fsSL https://ollama.com/install.sh | sh
  ```
- **Windows**:  
  Download from [Ollama Downloads](https://ollama.ai/download)  

Verify installation:
```bash
ollama --version
```

#### Step 2. Pull a Model
Example: download **llama2**
```bash
ollama pull llama2
```

#### Step 3. Run Ollama
```bash
ollama serve
```

Test with:
```bash
ollama run llama2
```

#### Step 4. Setup Ollama Express Server
Inside **ollama-server/** create `server.js`:

```js
const express = require("express");
const bodyParser = require("body-parser");
const fetch = require("node-fetch");

const app = express();
app.use(bodyParser.json());

app.post("/api/ask", async (req, res) => {
  const { prompt } = req.body;

  try {
    const response = await fetch("http://localhost:11434/api/generate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ model: "llama2", prompt })
    });

    const data = await response.json();
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Ollama server running on port ${PORT}`));
```

Run the server:
```bash
cd ollama-server
npm install express body-parser node-fetch
node server.js
```

✅ Server will run on:
```
http://localhost:5000
```

Test API:
```bash
curl -X POST http://localhost:5000/api/ask \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Hello AI, how are you?"}'
```

---

### 4️⃣ Setup the iOS App

1. Open `chatbot/ChatbotAI.xcodeproj` in Xcode  
2. Ensure deployment target is **iOS 13+**  
3. Update API base URLs in code:
   - `messages-server` → `http://localhost:4000`
   - `ollama-server` → `http://localhost:5000`
4. Build & Run on Simulator or iPhone  

---

## 📸 Screenshots

Screenshots available in `Screenshots/` folder. Example:

| Screenshot 1 | Screenshot 2 | Screenshot 3 |
|--------------|--------------|--------------|
| ![](Screenshots/1.PNG) | ![](Screenshots/2.PNG) | ![](Screenshots/3.PNG) |

---

## 🚀 Running the Full System

1. Start **messages-server**  
   ```bash
   cd messages-server && npm start
   ```
2. Start **ollama-server**  
   ```bash
   cd ollama-server && node server.js
   ```
3. Run the **iOS app** from Xcode  
4. 🎉 Chat with AI in real time  

---

## 🔗 API Endpoints

**Messages Server**  
- `POST /api/chatbot_messages/conversations` → Create conversation  
- `GET /api/chatbot_messages/conversations?user_id=123` → List conversations  
- `POST /api/chatbot_messages/messages` → Save a message  
- `GET /api/chatbot_messages/messages?conversation_id=xxx` → Fetch messages  

**Ollama Server**  
- `POST /api/ask` → Ask the AI with a prompt  

---

## 🧩 Tech Stack

- **Frontend (iOS)**: Swift / UIKit  
- **Backend (Messages)**: Node.js, Express, MongoDB  
- **AI Engine**: Ollama + LLaMA2 / Mistral / Gemma  

---

## 📌 Notes

- Ollama must be running before you start the **ollama-server**  
- MongoDB must be running before you start the **messages-server**  
- You can swap `llama2` with any supported Ollama model  

---

## 🤝 Contributing
PRs welcome! Fork the repo and submit pull requests.  

---

## 📄 License
This project is licensed under the MIT License.  
