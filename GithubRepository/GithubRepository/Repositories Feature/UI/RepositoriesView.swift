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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.viewDidAppear()
            }
        }
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
        func load() async throws -> [RepositoryItem] { [] }
    }
}
