//
//  SceneDelegate.swift
//  Santehnika-online-Colchugina
//
//  Created by Ирина Кольчугина on 13.10.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        window = UIWindow(frame: UIScreen.main.bounds)

        let navVc = UINavigationController()

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        let vc = StartViewController()
        navVc.viewControllers = [vc]

        window?.backgroundColor = .white
        window?.rootViewController = navVc
        window?.makeKeyAndVisible()
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window?.windowScene = windowScene
    }

}

