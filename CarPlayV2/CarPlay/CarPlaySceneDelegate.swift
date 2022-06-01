//
//  CarPlaySceneDelegate.swift
//  CarPlayV2
//
//  Created by Damor on 2022/05/26.
//

import UIKit
import CarPlay

@available(iOS 14.0, *)
final class CarPlaySceneDelegate: NSObject, CPTemplateApplicationSceneDelegate {
    private let templateManager = CarPlayTemplateManager(model: CarPlayTemplateModel())
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        templateManager.connect(interfaceController)
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnectInterfaceController interfaceController: CPInterfaceController) {

    }
}

@available(iOS 14.0, *)
extension CarPlaySceneDelegate {
    func sceneDidDisconnect(_ scene: UIScene) { }
    
    func sceneDidBecomeActive(_ scene: UIScene) { }
    
    func sceneWillResignActive(_ scene: UIScene) { }
}

