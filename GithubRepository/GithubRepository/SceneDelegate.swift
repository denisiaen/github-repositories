//
//  GithubRepositoryApp.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = navigationController
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    private lazy var navigationController = UINavigationController(rootViewController: UIHostingController(rootView:  makeRepositoriesView()))
    
    private func makeRepositoriesView() -> RepositoriesView {
        RepositoriesUIComposer.repositoriesComposeWith(
            repositoriesLoader: apiRepositoriesLoader,
            asyncImageViewModel: makeAsyncImageViewModel
        )
    }
    
    private var httpClient: HTTPClient {
        let urlSession = URLSessionHTTPClient()
        return urlSession
    }
    
    private lazy var apiRepositoriesLoader: RepositoriesLoader = {
        let url = URL(string: "https://api.github.com/search/repositories?q=language=+sort:stars")!
        return APIRepositoriesLoader(client: httpClient, url: url)
    }()
    
    private func makeAsyncImageViewModel() -> AsyncImageViewModel<UIImage> {
        AsyncImageViewModel(imageDataLoader: APIImageDataLoader(client: httpClient), imageTransformer: UIImage.init)
    }
}

final class RepositoriesUIComposer {
    private init() {}
    
    static func repositoriesComposeWith(repositoriesLoader: RepositoriesLoader, asyncImageViewModel: @escaping () -> AsyncImageViewModel<UIImage>) -> RepositoriesView {
        let viewModel = RepositoriesViewModel(repositoriesLoader: repositoriesLoader)
        let view = RepositoriesView(viewModel: viewModel) { item in
            RepositoryRow(item: item, asyncImageViewModel: asyncImageViewModel, isLoading: isLoadingBinded(viewModel: viewModel))
        }
        
        return view
    }
    
    static func isLoadingBinded(viewModel: RepositoriesViewModel) -> Binding<Bool> {
        Binding<Bool>(get: { viewModel.isRefreshing }, set: { viewModel.isRefreshing = $0 })
    }
}
