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
    func startConversation()
    func stopConversation()
}

class AppCoordinator {
    init() {
        chatUICoordinator.setup(with: ChatLikeConfiguration.Builder().build())

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
    }

    deinit {
        chatModel.stop()
    }

    private let chatUICoordinator = ChatLikeCoordinator()
    private let chatModel = ChatModel()
    private var bag = Set<AnyCancellable>()

    private var isInitialStart = true
    private lazy var chatIcon = { UIImage(named: "chat-icon") }()
}

extension AppCoordinator: AppCoordinatorInterface {
    func installUI(with installer: InterfaceInstaller) {
        guard let viewController = chatUICoordinator.viewController else {
            fatalError("Cannot start main interface module")
        }

        installer.install(viewController: viewController)
    }

    func startConversation() {
        chatModel.startConversation()
    }

    func stopConversation() {
        chatModel.stopConversation()
    }
}

private extension AppCoordinator {
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
