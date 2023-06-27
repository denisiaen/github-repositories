//
//  RepositoryRow.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 26.06.2023.
//

import Foundation
import SwiftUI

struct RepositoryRow: View {
    private let item: RepositoryItem
    private let asyncImageViewModel: () -> AsyncImageViewModel
    @Binding public var isLoading: Bool
    
    init(item: RepositoryItem, asyncImageViewModel: @escaping () -> AsyncImageViewModel, isLoading: Binding<Bool>) {
        self.item = item
        self.asyncImageViewModel = asyncImageViewModel
        self._isLoading = isLoading
    }
    
    var body: some View {
        if isLoading {
            LoadingRepositoryRow()
        } else {
            makeItemView(item: item)
        }
    }
    
    @ViewBuilder
    private func makeItemView(item: RepositoryItem) -> some View {
        let size: CGFloat = 40
        HStack(alignment: .top) {
            makeAvailableAsyncImage(item.imageURL)
                .frame(width: size, height: size)
                .cornerRadius(size / 2)
                .padding(.trailing, 10)
            makeTextItemView(item)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func makeAvailableAsyncImage(_ url: URL) -> some View {
//        if #available(iOS 15.0, *) {
//            makeAsyncImage(url)
//        } else {
            AsyncImageView(url: url, viewModel: asyncImageViewModel(), placeholder: placeholder)
//        }
    }
    
    private func makeTextItemView(_ item: RepositoryItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            makeRegularTextView(item.userName)
            makeLargeTextView(item.repositoryName)

            if let description = item.description {
                makeRegularTextView(description)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            
            HStack (spacing: 20) {
                if let language = item.language {
                    makeBulletTextView(language)
                }
                
                if let stars = item.stars {
                    makeStarTextView("\(stars)")
                }
            }
        }
    }
    
    @available(iOS 15.0, *)
    private func makeAsyncImage(_ url: URL) -> some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
        } placeholder: {
            placeholder
        }
    }
    
    private func makeRegularTextView(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14))
    }
    
    private func makeLargeTextView(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 16))
    }
    
    private func makeBulletTextView(_ text: String) -> some View {
        HStack {
            Color.blue
                .frame(width: 10, height: 10)
                .cornerRadius(5)
            makeRegularTextView(text)
        }
    }
    
    private func makeStarTextView(_ text: String) -> some View {
        HStack {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 12, height: 12)
                .foregroundColor(.yellow)
            makeRegularTextView(text)
        }
    }
    
    private var placeholder: some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 20, height: 20)
    }
}
