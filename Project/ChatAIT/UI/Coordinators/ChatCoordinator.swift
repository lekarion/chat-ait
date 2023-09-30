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

        chatModel.start()
        chatModel.event.receive(on: DispatchQueue.main).sink { [weak self] event in
            guard let self = self else { return }

            switch event {
            case let state as StateEvent:
                self.process(state: state)
            default:
                break
            }
        }.store(in: &bag)

        (viewController as? ViewModelPropagation)?.propagate(viewModel: chatModel)
    }

    func start() {
        chatModel.startConversation()
    }

    func stop() {
        chatModel.stopConversation()
    }

    // MARK: ### Private ###
    private let viewController: UIViewController
    private let chatUICoordinator = ChatLikeCoordinator()
    private let chatModel = ChatModel()
    private var bag = Set<AnyCancellable>()

    private var isInitialStart = true
    private lazy var chatIcon = { UIImage(named: "chat-icon") }()
}

private extension ChatCoordinator {
    func process(state event: StateEvent) {
        switch event.state {
        case .assisting:
            if isInitialStart {
                chatUICoordinator.push(item: ChatLikeData(text: "Welcome message".localized, image: nil, source: .chat, creatorIcon: chatIcon))
                isInitialStart = false
            } else {
                chatUICoordinator.startThread()
            }
        case .off:
            chatUICoordinator.updateThread(ChatLikeThreadInfo(footer: event.info))
        default:
            break
        }
    }
}
