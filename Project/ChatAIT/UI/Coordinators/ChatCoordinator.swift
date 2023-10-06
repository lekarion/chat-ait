//
//  ChatCoordinator.swift
//  ChatAIT
//
//  Created by developer on 30.09.2023.
//

import Combine
import ChatLikeUI_iOS
import UIKit

class ChatCoordinator {
    init(viewController: UIViewController) {
        guard let controller = viewController as? (InterfaceInstaller & ChatViewControllerInterface) else {
            fatalError("Invalid main view controller class")
        }
        self.viewController = viewController

        chatUICoordinator.setup(with: ChatLikeConfiguration.Builder()
            .set(chatMessageColor: UIColor.systemBlue)
            .set(userMessageColor: UIColor.systemYellow)
            .build())

        guard let rootViewController = chatUICoordinator.viewController else {
            fatalError("Cannot start main interface module")
        }

        chatViewModel.contentProvider = self

        controller.install(viewController: rootViewController)
        controller.propagate(viewModel: chatViewModel)
        controller.delegate = self

        bindEvents()
    }

    func start() {
        chatViewModel.start()
        chatViewModel.startConversation()
    }

    func stop() {
        chatViewModel.stopConversation()
        chatViewModel.stop()
    }

    // MARK: ### Private ###
    private let viewController: UIViewController
    private let chatUICoordinator = ChatLikeCoordinator()
    private let chatViewModel = ChatViewModel()
    private var bag = Set<AnyCancellable>()

    private let contentUpdateSubject = PassthroughSubject<Void, Never>()

    private var isInitialStart = true
    private lazy var chatIcon = { UIImage(named: "chat-icon") }()
}

extension ChatCoordinator: ChatViewControllerDelegate {
    func showSettings() {
        // TODO: implement
    }

    func clearChat() {
        chatUICoordinator.erase()
    }
}

extension ChatCoordinator: ChatViewModelContentProvider {
    var isEmpty: Bool { chatUICoordinator.isEmpty }
    var updateEvent: AnyPublisher<Void, Never> { contentUpdateSubject.eraseToAnyPublisher() }

    func send(command: ContentCommand) {
        switch command {
        case .showWelcomeMessage:
            chatUICoordinator.push(item: ChatLikeData(text: "Welcome message".localized, image: nil, source: .chat))
        case .showConversations(let isWithPrompt):
            break
        }
    }
}

private extension ChatCoordinator {
    func bindEvents() {
        chatUICoordinator.notificationEvent.receive(on: DispatchQueue.main).sink { [weak self] event in
            switch event {
            case .didUpdateContent:
                self?.contentUpdateSubject.send()
            default:
                break
            }
        }.store(in: &bag)
    }
}
