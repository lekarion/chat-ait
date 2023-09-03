//
//  AppCoordinator.swift
//  ChatAIT
//
//  Created by developer on 03.09.2023.
//

import ChatLikeUI_iOS
import UIKit

protocol InterfaceInstaller: AnyObject {
    func install(viewController: UIViewController)
}

protocol AppCoordinatorInterface: AnyObject {
    func installUI(with installer: InterfaceInstaller)
}

class AppCoordinator {
    func start() {
        chatModel.start(with: chatUICoordinator)
    }

    func stop() {
        chatModel.stop()
    }

    private let chatUICoordinator = ChatLikeCoordinator()
    private let chatModel = ChatModel()
}

extension AppCoordinator: AppCoordinatorInterface {
    func installUI(with installer: InterfaceInstaller) {
        guard let viewController = chatUICoordinator.viewController else {
            fatalError("Cannot start main interface module")
        }
        installer.install(viewController: viewController)
    }
}
