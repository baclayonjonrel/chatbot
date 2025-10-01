import express from "express";
import { spawn } from "child_process";

const app = express();
app.use(express.json());

/**
 * 🔹 Streaming Endpoint
 * Returns data chunk by chunk (typing effect)
 */
app.post("/chat-stream", (req, res) => {
  const { message } = req.body;

  res.setHeader("Content-Type", "text/plain");
  res.setHeader("Transfer-Encoding", "chunked");

  const ollama = spawn("ollama", ["run", "gemma"]);

  ollama.stdin.write(message + "\n");
  ollama.stdin.end();

  ollama.stdout.on("data", (data) => {
    res.write(data.toString());
  });

  ollama.on("close", () => {
    res.end();
  });
});

/**
 * 🔹 Whole Reply Endpoint
 * Collects Ollama output fully, then returns at once
 */
app.post("/chat", (req, res) => {
  const { message } = req.body;

  let output = "";

  const ollama = spawn("ollama", ["run", "gemma"]);

  ollama.stdin.write(message + "\n");
  ollama.stdin.end();

  ollama.stdout.on("data", (data) => {
    output += data.toString();
  });

  ollama.on("close", () => {
    res.json({ reply: output.trim() });
  });
});

app.listen(3000, () => {
  console.log("🚀 Server running on http://localhost:3000");
  console.log("   ➡️  /chat        (whole response)");
  console.log("   ➡️  /chat-stream (streaming response)");
});

/*
app.post("/chat-stream", (req, res) => {
  const { message } = req.body;

  res.setHeader("Content-Type", "text/plain");
  res.setHeader("Transfer-Encoding", "chunked");

  // Determine which model to use
  let model = "gemma"; // default text model
  if (message.includes("[image]")) {
    model = "stable-diffusion-xl"; // or FLUX.1
  } else if (message.includes("[video]")) {
    model = "ltx-video"; // or Mochi-1
  }

  const ollama = spawn("ollama", ["run", model]);

  ollama.stdin.write(message + "\n");
  ollama.stdin.end();

  ollama.stdout.on("data", (data) => {
    res.write(data.toString());
  });

  ollama.on("close", () => {
    res.end();
  });
});
*/