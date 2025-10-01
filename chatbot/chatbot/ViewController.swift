//
//  ViewController.swift
//  chatbot
//
//  Created by FDC-JONREL-NC-IOS on 9/15/25.
//

import UIKit
import Foundation
import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}


class ViewController: UIViewController {
    private let viewModel = ChatViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showChatView()
    }
    
    private func showChatView() {
        let chatView = ChatView(viewModel: viewModel)
        let hostingVC = UIHostingController(rootView: chatView)
        hostingVC.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(hostingVC, animated: true , completion: nil)
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


