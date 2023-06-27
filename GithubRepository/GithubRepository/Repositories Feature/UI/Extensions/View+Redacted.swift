//
//  View+Redacted.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 27.06.2023.
//

import Foundation
import SwiftUI

extension View {
    func redacted(reason: RedactionReason?) -> some View {
        modifier(Redactable(reason: reason))
    }
}

enum RedactionReason {
  case placeholder
  case circularPlaceholder
}

struct Redactable: ViewModifier {
    let reason: RedactionReason?

      @ViewBuilder
      func body(content: Content) -> some View {
        switch reason {
        case .placeholder:
          content
            .modifier(Placeholder())
        case .circularPlaceholder:
          content
            .modifier(CirclePlaceholder())
        case nil:
          content
        }
      }
}

struct Placeholder: ViewModifier {
  func body(content: Content) -> some View {
      content
          .opacity(0)
          .overlay(
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.black.opacity(0.1))
                .padding(.vertical, 4.5)
          )
  }
}

struct CirclePlaceholder: ViewModifier {
  func body(content: Content) -> some View {
    content
      .opacity(0)
      .overlay(
        Circle()
            .opacity(0.1)
            .frame(width: 40, height: 40)

    )
  }
}
