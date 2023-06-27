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
    
    private func makeAsyncImageViewModel() -> AsyncImageViewModel {
        AsyncImageViewModel(imageDataLoader: APIImageDataLoader(client: httpClient))
    }
}

final class RepositoriesUIComposer {
    private init() {}
    
    static func repositoriesComposeWith(repositoriesLoader: RepositoriesLoader, asyncImageViewModel: @escaping () -> AsyncImageViewModel) -> RepositoriesView {
        let viewModel = RepositoriesViewModel(repositoriesLoader: repositoriesLoader)
        return RepositoriesView(viewModel: viewModel, asyncImageViewModel: asyncImageViewModel)
    }
}
