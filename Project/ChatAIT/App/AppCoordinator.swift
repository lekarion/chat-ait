//
//  AppCoordinator.swift
//  ChatAIT
//
//  Created by developer on 03.09.2023.
//

import Combine
import ChatLikeUI_iOS
import UIKit

protocol InterfaceInstaller: AnyObject {
    func install(viewController: UIViewController)
}

protocol AppCoordinatorInterface: AnyObject {
    func installUI(with installer: InterfaceInstaller)
}

class AppCoordinator {
    init() {
        chatModel.event.receive(on: DispatchQueue.main).sink { [weak self] event in
            guard let self = self else { return }
        }.store(in: &bag)

        chatUICoordinator.setup(with: ChatLikeConfiguration.Builder().build())
    }

    func start() {
        chatModel.start()
    }

    func stop() {
        chatModel.stop()
    }

    private let chatUICoordinator = ChatLikeCoordinator()
    private let chatModel = ChatModel()
    private var bag = Set<AnyCancellable>()
}

extension AppCoordinator: AppCoordinatorInterface {
    func installUI(with installer: InterfaceInstaller) {
        guard let viewController = chatUICoordinator.viewController else {
            fatalError("Cannot start main interface module")
        }
        installer.install(viewController: viewController)
    }
}
