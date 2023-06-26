//
//  ContentView.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import SwiftUI

struct RepositoriesView: View {
    
    @ObservedObject var viewModel: RepositoriesViewModel
    
    init(viewModel: RepositoriesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(viewModel.repositoryItems.indices, id: \.self) { index in
                let item = viewModel.repositoryItems[index]
                HStack {
                    CircularAsyncImage(url: item.imageURL, placeholder: placeholder)
                        .frame(width: 20, height: 20)
                    Text(item.userName)
                        .foregroundColor(.black)
                    Spacer()
                }
                Divider()
            }
        }
        .padding(.leading)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RepositoriesView(viewModel: RepositoriesViewModel.makeDummy())
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
