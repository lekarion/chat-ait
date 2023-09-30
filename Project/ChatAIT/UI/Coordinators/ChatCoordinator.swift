//
//  ChatCoordinator.swift
//  ChatAIT
//
//  Created by developer on 30.09.2023.
//

import Combine
import ChatLikeUI_iOS
import UIKit

protocol InterfaceInstaller: AnyObject {
    func install(viewController: UIViewController)
}

protocol ViewModelPropagation: AnyObject {
    func propagate(viewModel: ChatViewModelInterface)
}

class ChatCoordinator {
    init(viewController: UIViewController) {
        guard let installer = viewController as? InterfaceInstaller else {
            fatalError("Invalid main view controller class")
        }
        self.viewController = viewController

        chatUICoordinator.setup(with: ChatLikeConfiguration.Builder().build())
        guard let rootViewController = chatUICoordinator.viewController else {
            fatalError("Cannot start main interface module")
        }

        installer.install(viewController: rootViewController)

        chatViewModel.start()
        (viewController as? ViewModelPropagation)?.propagate(viewModel: chatViewModel)
    }

    func start() {
        chatViewModel.startConversation()
    }

    func stop() {
        chatViewModel.stopConversation()
    }

    // MARK: ### Private ###
    private let viewController: UIViewController
    private let chatUICoordinator = ChatLikeCoordinator()
    private let chatViewModel = ChatViewModel()
    private var bag = Set<AnyCancellable>()

    private var isInitialStart = true
    private lazy var chatIcon = { UIImage(named: "chat-icon") }()
}
