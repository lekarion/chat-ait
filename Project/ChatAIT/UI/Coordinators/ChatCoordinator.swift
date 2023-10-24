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
            .set(chatDefaultIcon: UIImage(named: "chat-icon"))
            .set(chatMessageColor: UIColor(named: "AccentColor"))
            .set(chatMessageTextColor: UIColor(named: "chatMessageTextColor"))
            .set(userMessageColor: UIColor(named: "userMessageColor"))
            .set(userMessageTextColor: UIColor(named: "userMessageTextColor"))
            .set(chatThinkingEnabled: true)
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
            let allActions = AssistantsFactory.allDescriptors.map { descriptor in
                let assistantIcon = UIImage(named: descriptor.iconId)
                return ActionDescriptor(icon: assistantIcon, identifier: descriptor.identifier, title: descriptor.name.localized, handler: didSelectTopic)
            }

            let items: [ChatLikeItem] = [
                ChatLikeDataObject(text: "Welcome message".localized, image: nil, source: .chat),
                ChatLikeActionObject(actions: allActions),
//                ChatLikeDataObject(text: "Start prompt".localized, image: nil, source: .chat)
            ]
            chatUICoordinator.push(item: ChatLikeUnionObject(with: items, source: .chat))
        case .showConversations(let isWithPrompt):
            if isWithPrompt {
                chatUICoordinator.push(item: ChatLikeDataObject(text: "Start prompt".localized, image: nil, source: .chat))
            }
            let allActions = AssistantsFactory.allDescriptors.map { descriptor in
                let assistantIcon = UIImage(named: descriptor.iconId)
                return ActionDescriptor(icon: assistantIcon, identifier: descriptor.identifier, title: descriptor.name.localized, handler: didSelectTopic)
            }
            chatUICoordinator.push(item: ChatLikeActionObject(actions: allActions))
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

    func didSelectTopic(_ identifier: String) {
        guard let descriptor = AssistantsFactory.allDescriptors.first(where: { $0.identifier == identifier }) else { return }
        chatUICoordinator.push(item: ChatLikeDataObject(text: descriptor.name.localized, image: UIImage(named: descriptor.iconId), source: .user))
    }

    struct ActionDescriptor: ChatLikeAction {
        let icon: ChatLikeImage?
        let identifier: String
        let title: String
        let handler: (String) -> Void
    }
}
