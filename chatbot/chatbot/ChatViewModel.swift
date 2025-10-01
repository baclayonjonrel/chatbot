//
//  ChatViewModel.swift
//  chatbot
//
//  Created by FDC-JONREL-NC-IOS on 9/15/25.
//

import Foundation
import Combine

class ChatViewModel: NSObject, URLSessionDataDelegate, ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentStreamText: String = ""

    private var task: URLSessionDataTask?

    func sendMessage(_ text: String) {
        messages.append(ChatMessage(text: text, isUser: true))
        currentStreamText = ""
        startStreaming(message: text)
    }

    private func startStreaming(message: String) {
        guard let url = URL(string: "http://192.168.107.122:3000/chat-stream") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["message": message]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        task = session.dataTask(with: request)
        task?.resume()
    }
    
    func getPromptForAI(newMessage: String, history: [ChatMessage]) -> String {
        var prompt = "You are a helpful assistant. Use previous conversation for context if any, but do not mention it explicitly.\n"
        
        if !history.isEmpty {
            for msg in history {
                let role = msg.isUser == true ? "User" : "AI"
                prompt += "\(role): \(msg.text)\n"
            }
        }
        
        // Add the current user message
        prompt += "User: \(newMessage)\nAI:"
        
        return prompt
    }

    // MARK: Streaming
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let chunk = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.objectWillChange.send()
                self.currentStreamText += chunk
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            if !self.currentStreamText.isEmpty {
                self.messages.append(ChatMessage(text: self.currentStreamText, isUser: false))
                self.currentStreamText = ""
            }
        }
    }
    
    func sendMessageWhole(_ text: String) {
        let url = URL(string: "http://192.168.107.122:3000/chat")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["message": text]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let reply = json["reply"] as? String {
                print("✅ Whole reply:", reply)
            } else {
                print("❌ Error:", error?.localizedDescription ?? "Unknown error")
            }
        }.resume()
    }
}

/*
 if messages will be saved soon
 import Foundation

 struct Conversation: Codable {
     let _id: String?
     let user_id: String
     let title: String
     let created_at: String?
 }

 struct Message: Codable {
     let _id: String?
     let conversation_id: String
     let user_id: String
     let message: String
     let type: String // "sent" or "received"
     let created_at: String?
 }
 func createConversation(userId: String, title: String, completion: @escaping (Conversation?) -> Void) {
     guard let url = URL(string: "http://localhost:4000/api/chatbot_messages/conversations") else { return }

     var request = URLRequest(url: url)
     request.httpMethod = "POST"
     request.setValue("application/json", forHTTPHeaderField: "Content-Type")

     let body = ["user_id": userId, "title": title]
     request.httpBody = try? JSONSerialization.data(withJSONObject: body)

     URLSession.shared.dataTask(with: request) { data, _, _ in
         guard let data = data else { completion(nil); return }
         let conversation = try? JSONDecoder().decode(Conversation.self, from: data)
         completion(conversation)
     }.resume()
 }
 func sendMessage(conversationId: String, userId: String, message: String, type: String = "sent", completion: @escaping (Message?) -> Void) {
     guard let url = URL(string: "http://localhost:4000/api/chatbot_messages/messages") else { return }

     var request = URLRequest(url: url)
     request.httpMethod = "POST"
     request.setValue("application/json", forHTTPHeaderField: "Content-Type")

     let body: [String: Any] = [
         "conversation_id": conversationId,
         "user_id": userId,
         "message": message,
         "type": type
     ]
     request.httpBody = try? JSONSerialization.data(withJSONObject: body)

     URLSession.shared.dataTask(with: request) { data, _, _ in
         guard let data = data else { completion(nil); return }
         let msg = try? JSONDecoder().decode(Message.self, from: data)
         completion(msg)
     }.resume()
 }
 func fetchMessages(conversationId: String, completion: @escaping ([Message]?) -> Void) {
     guard let url = URL(string: "http://localhost:4000/api/chatbot_messages/messages?conversation_id=\(conversationId)") else { return }

     URLSession.shared.dataTask(with: url) { data, _, _ in
         guard let data = data else { completion(nil); return }
         let messages = try? JSONDecoder().decode([Message].self, from: data)
         completion(messages)
     }.resume()
 }
 func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
     guard let url = URL(string: "http://localhost:4000/api/chatbot_messages/conversations/\(conversationId)") else { return }

     var request = URLRequest(url: url)
     request.httpMethod = "DELETE"

     URLSession.shared.dataTask(with: request) { data, _, _ in
         guard let data = data else { completion(false); return }
         if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            result["success"] as? Bool == true {
             completion(true)
         } else {
             completion(false)
         }
     }.resume()
 }

 */
