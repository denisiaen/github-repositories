//
//  GithubRepositoryApp.swift
//  GithubRepository
//
//  Created by Denisia Enasescu on 22.06.2023.
//

import SwiftUI

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
        let httpClient = self.httpClient
        return RepositoriesUIComposer.repositoriesComposeWith(
            repositoriesLoader: apiRepositoriesLoader,
            imageDataLoader: { APIImageDataLoader(client: httpClient) }
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
    
    
}
