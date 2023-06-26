//
//  ContentView.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import SwiftUI

struct RepositoriesView: View {
    private let imageDataLoader: () -> ImageDataLoader
    @ObservedObject var viewModel: RepositoriesViewModel
    
    init(viewModel: RepositoriesViewModel, imageDataLoader: @escaping () -> ImageDataLoader) {
        self.viewModel = viewModel
        self.imageDataLoader = imageDataLoader
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(viewModel.repositoryItems.indices, id: \.self) { index in
                let item = viewModel.repositoryItems[index]
                makeItemView(item: item)
                    .padding()
                Divider()
            }
        }
        .onAppear {
            Task {
                await viewModel.viewDidAppear()
            }
        }
    }
    
    private var placeholder: some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 20, height: 20)
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
        if #available(iOS 15.0, *) {
            makeAsyncImage(url)
        } else {
            AsyncImageView(url: url, imageDataLoader: imageDataLoader(), placeholder: placeholder)
        }
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView(viewModel: RepositoriesViewModel.makeDummy(), imageDataLoader: {
            DummyImageDataLoader()
        })
    }
}

private extension RepositoriesViewModel {
    static func makeDummy() -> RepositoriesViewModel {
        RepositoriesViewModel(repositoriesLoader: DummyRepositoryLoader())
    }
    
    private class DummyRepositoryLoader: RepositoriesLoader {
        func load() async throws -> [RepositoryItem] {
            [RepositoryItem(id: 1, userName: "A user", imageURL: URL(string: "https://avatars.githubusercontent.com/u/4314092?v=4")!, repositoryName: "A repo", description: nil, language: nil, stars: 222) ]
        }
    }
}

private class DummyImageDataLoader: ImageDataLoader {
    func load(url: URL) async throws -> Data { Data() }
}
