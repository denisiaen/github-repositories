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
        refreshableList
            .onAppear {
                Task {
                    await viewModel.viewDidAppear()
                }
            }
            .navigationBarTitle("Trending", displayMode: .automatic)
    }
    
    @ViewBuilder
    private var refreshableList: some View {
        if #available(iOS 15.0, *) {
            listContent
                .refreshable {
                    Task {
                        await viewModel.refresh()
                    }
                }
        } else {
            listContent
        }
    }
    
    private var listContent: some View {
        List {
            ForEach(viewModel.repositoryItems.indices, id: \.self) { index in
                let item = viewModel.repositoryItems[index]
                RepositoryRow(item: item, imageDataLoader: imageDataLoader, isLoading: $viewModel.isLoading)
                    .padding()
            }
        }
        .listStyle(.plain)
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
