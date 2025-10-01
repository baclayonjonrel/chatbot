require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Environment variables
const PORT = process.env.PORT || 4000;
const MONGO_URI = process.env.MONGO_URI;

// Connect to MongoDB
mongoose.connect(MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
.then(() => console.log("MongoDB connected"))
.catch(err => console.log(err));

// --- Schemas & Models ---

const conversationSchema = new mongoose.Schema({
    user_id: { type: String, required: true },
    title: String,
    created_at: { type: Date, default: Date.now }
});

const messageSchema = new mongoose.Schema({
    conversation_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Conversation' },
    user_id: String,
    message: String,
    type: { type: String, enum: ['sent', 'received'] },
    created_at: { type: Date, default: Date.now }
});

const Conversation = mongoose.model('Conversation', conversationSchema);
const Message = mongoose.model('Message', messageSchema);

// --- Routes ---

// Create a conversation
app.post('/api/chatbot_messages/conversations', async (req, res) => {
    try {
        const conv = new Conversation(req.body);
        await conv.save();
        res.json(conv);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// List conversations for a user
app.get('/api/chatbot_messages/conversations', async (req, res) => {
    try {
        const { user_id } = req.query;
        const convs = await Conversation.find({ user_id });
        res.json(convs);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Delete conversation and all its messages
app.delete('/api/chatbot_messages/conversations/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const conv = await Conversation.findByIdAndDelete(id);
        if (!conv) {
            return res.status(404).json({ success: false, message: "Conversation not found." });
        }

        // Delete all messages in this conversation
        await Message.deleteMany({ conversation_id: id });

        res.json({ success: true, message: "Conversation and its messages deleted." });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Save a message
app.post('/api/chatbot_messages/messages', async (req, res) => {
    try {
        const msg = new Message(req.body);
        await msg.save();
        res.json(msg);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// List messages in a conversation
app.get('/api/chatbot_messages/messages', async (req, res) => {
    try {
        const { conversation_id } = req.query;
        const messages = await Message.find({ conversation_id }).sort({ created_at: 1 });
        res.json(messages);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// --- Start Server ---
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
