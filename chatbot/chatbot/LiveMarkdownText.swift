//
//  LiveMarkdownText.swift
//  chatbot
//
//  Created by FDC-JONREL-NC-IOS on 9/15/25.
//

import SwiftUI
import MarkdownUI

struct LiveMarkdownText: View {
    let text: String
    let isUser: Bool

    var body: some View {
        return  Markdown(text)
            .markdownTheme(.docC)
            .padding(10)
            .background(isUser ? Color.blue : Color.gray.opacity(0.3))
            .foregroundColor(isUser ? .white : .black)
            .cornerRadius(10)
            .multilineTextAlignment(.leading)
            .textSelection(.enabled)
            .markdownBlockStyle(\.blockquote) { configuration in
              configuration.label
                .padding()
                .markdownTextStyle {
                  FontCapsVariant(.lowercaseSmallCaps)
                  FontWeight(.semibold)
                  BackgroundColor(nil)
                }
                .overlay(alignment: .leading) {
                  Rectangle()
                    .fill(Color.teal)
                    .frame(width: 4)
                }
                .background(Color.teal.opacity(0.5))
            }
    }
}
