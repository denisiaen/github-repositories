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
            window.rootViewController = UIHostingController(rootView:  makeRepositoriesView())
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func makeRepositoriesView() -> RepositoriesView {
        let httpClient = URLSessionHTTPClient()
        let url = URL(string: "https://api.github.com/search/repositories?q=language=+sort:stars")!
        let apiRepositoriesLoader = APIRepositoriesLoader(client: httpClient, url: url)
        let viewModel = RepositoriesViewModel(repositoriesLoader: apiRepositoriesLoader)
        return RepositoriesView(viewModel: viewModel)
    }
}
