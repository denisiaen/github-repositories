//
//  ContentView.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import SwiftUI

public struct RepositoriesView: View {
    private let asyncImageViewModel: () -> AsyncImageViewModel
    @ObservedObject var viewModel: RepositoriesViewModel
    
    public init(viewModel: RepositoriesViewModel, asyncImageViewModel: @escaping () -> AsyncImageViewModel) {
        self.viewModel = viewModel
        self.asyncImageViewModel = asyncImageViewModel
    }
    
    public var body: some View {
        loadingList
            .onAppear {
                Task {
                    await viewModel.viewDidAppear()
                }
            }
            .navigationBarTitle("Trending", displayMode: .automatic)
    }
    
    @ViewBuilder
    private var loadingList: some View {
        if viewModel.isLoading {
            ActivityIndicator()
        } else if let _ = viewModel.error {
            ErrorView(animationName: "retry-and-user-busy-version-2", action: {
                Task {
                    await viewModel.viewDidAppear()
                }
            })
        } else {
            redactableList
        }
    }
    
    @ViewBuilder
    private var redactableList: some View {
        if #available(iOS 14.0, *) {
            refreshableList
                .redacted(reason: viewModel.isRefreshing ? .placeholder : [])
        } else {
            refreshableList
        }
    }
    
    @ViewBuilder
    private var refreshableList: some View {
        if #available(iOS 15.0, *) {
            listContent
                .refreshable {
                    await viewModel.refresh()
                }
        } else {
            listContent
                .navigationBarItems(
                    trailing: HStack {
                        Button("Update") {
                            Task {
                                await viewModel.refresh()
                            }
                        }
                    }
                )
        }
    }
    
    private var listContent: some View {
        List {
            ForEach(viewModel.repositoryItems.indices, id: \.self) { index in
                let item = viewModel.repositoryItems[index]
                RepositoryRow(item: item, asyncImageViewModel: asyncImageViewModel, isLoading: $viewModel.isRefreshing)
                    .padding()
            }
        }
        .listStyle(.plain)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView(viewModel: RepositoriesViewModel.makeDummy(), asyncImageViewModel: {
            AsyncImageViewModel(imageDataLoader: DummyImageDataLoader())
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
