//
//  LoadingRepositoryRow.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import Foundation
import SwiftUI

struct LoadingRepositoryRow: View {
    var body: some View {
        HStack {
            Circle()
                .fill(Color.gray)
                .opacity(0.2)
                .frame(width: 44, height: 44)
            VStack {
                topLine
                    .frame(height: 10)
                Spacer()
                bottomLine
                    .frame(height: 10)
            }
        }
        .shimmer()
    }
    
    private var topLine: some View {
        GeometryReader { geometry in
            HStack {
                Rectangle()
                    .fill(Color.gray)
                    .cornerRadius(8)
                    .opacity(0.2)
                Spacer(minLength: geometry.size.width / 2)
            }
        }
    }
    
    private var bottomLine: some View {
        Rectangle()
            .fill(Color.gray)
            .cornerRadius(8)
            .opacity(0.2)
    }
}
