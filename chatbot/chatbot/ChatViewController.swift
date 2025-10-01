//
//  ChatViewController.swift
//  chatbot
//
//  Created by FDC-JONREL-NC-IOS on 9/15/25.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var inputText: String = ""

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            ChatMessageRow(message: message)
                        }

                        if !viewModel.currentStreamText.isEmpty {
                            StreamingTextRow(text: viewModel.currentStreamText)
                        }

                        Color.clear.frame(height: 1).id("BOTTOM")
                    }
                    .padding()
                    .onChange(of: viewModel.messages.count) { _,_ in scrollToBottom(proxy: proxy) }
                    .onChange(of: viewModel.currentStreamText) { _,_ in scrollToBottom(proxy: proxy) }
                }
            }

            inputArea
        }
        .navigationTitle("Chat")
        .onTapGesture { hideKeyboard() }
    }

    @ViewBuilder
    private var inputArea: some View {
        HStack {
            TextField("Type a message...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 8)

            Button(action: {
                guard !inputText.isEmpty else { return }
                viewModel.sendMessage(inputText)
                inputText = ""
                hideKeyboard()
            }) {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
            }
            .padding(.trailing, 8)
        }
        .padding(.vertical, 6)
        .background(Color(UIColor.systemGray6))
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.1)) {
            proxy.scrollTo("BOTTOM", anchor: .bottom)
        }
    }
}


struct ChatMessageRow: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            LiveMarkdownText(text: message.text, isUser: message.isUser)
            if !message.isUser { Spacer() }
        }
    }
}

struct StreamingTextRow: View {
    let text: String

    var body: some View {
        HStack {
            LiveMarkdownText(text: text, isUser: false)
            Spacer()
        }
    }
}

//
//struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatView(viewModel: ChatViewModel())
//    }
//}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
