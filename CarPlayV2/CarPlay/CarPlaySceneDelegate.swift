//
//  CarPlaySceneDelegate.swift
//  CarPlayV2
//
//  Created by Damor on 2022/05/26.
//

import UIKit
import CarPlay
import RxSwift

struct CarPlayTemplateModelComponent: CarPlayTemplateModelDependency {
    var provider: CarPlayProviding
    var mainScheduler: SchedulerType
    var maximumTabCount: Int
    var maximumItemCount: Int
    var maximumSectionCount: Int
    
    init(
        provider: CarPlayProviding = CarPlayProvider(),
        mainScheduler: SchedulerType = MainScheduler.instance,
        maximumTabCount: Int,
        maximumItemCount: Int,
        maximumSectionCount: Int
    ) {
        self.provider = provider
        self.mainScheduler = mainScheduler
        self.maximumTabCount = maximumTabCount
        self.maximumItemCount = maximumItemCount
        self.maximumSectionCount = maximumSectionCount
    }
}

@available(iOS 14.0, *)
final class CarPlaySceneDelegate: NSObject, CPTemplateApplicationSceneDelegate {
    
    private let rootComponent: CarPlayTemplateModelDependency = {
        return CarPlayTemplateModelComponent(
            provider: CarPlayProvider(),
            mainScheduler: MainScheduler.instance,
            maximumTabCount: CPTabBarTemplate.maximumTabCount,
            maximumItemCount: CPListTemplate.maximumItemCount,
            maximumSectionCount: CPListTemplate.maximumSectionCount
        )
    }()

    private lazy var templateManager: CarPlayTemplateManager = {
        return CarPlayTemplateManager(
            model: CarPlayTemplateModel(
                dependency: rootComponent
            )
        )
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("## will connect")
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        templateManager.connect(interfaceController)
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        templateManager.disconnect()
    }
}

@available(iOS 14.0, *)
extension CarPlaySceneDelegate {
    func sceneDidDisconnect(_ scene: UIScene) { print("## did disconnect") }
    
    func sceneDidBecomeActive(_ scene: UIScene) { }
    
    func sceneWillResignActive(_ scene: UIScene) { }
}

