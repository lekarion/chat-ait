//
//  ChatCoordinator.swift
//  ChatAIT
//
//  Created by developer on 30.09.2023.
//

import Combine
import CocoaLumberjack
import ChatLikeUI
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
            .set(ignoreMessageEdgeMargin: true)
            .set(chatThinkingTime: 2.0)
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
    }

    func stop() {
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
                ChatLikeActionObject(actions: allActions)
            ]
            chatUICoordinator.push(item: ChatLikeUnionObject(with: items, source: .chat))
        case .showConversations(let isWithPrompt):
            let allActions = AssistantsFactory.allDescriptors.map { descriptor in
                let assistantIcon = UIImage(named: descriptor.iconId)
                return ActionDescriptor(icon: assistantIcon, identifier: descriptor.identifier, title: descriptor.name.localized, handler: didSelectTopic)
            }

            let actionItem = ChatLikeActionObject(actions: allActions)

            if isWithPrompt {
                chatUICoordinator.push(item: ChatLikeUnionObject(with: [
                        ChatLikeDataObject(text: "Start prompt".localized, image: nil, source: .chat),
                        actionItem
                    ], source: .chat))
            } else {
                chatUICoordinator.push(item: actionItem)
            }
        case .showInteraction(let interaction):
            guard let item = interaction.transform(with: self, to: ChatLikeItem.self) else { break }
            chatUICoordinator.push(item: item)
        }
    }
}

extension ChatCoordinator: ChatInteractionTransformer {
    func transformUnion<T>(subitems: [T], to: T.Type) -> T? {
        guard let content = subitems as? [ChatLikeItem] else { return nil }
        return ChatLikeUnionObject(with: content, source: .chat, creatorIcon: chatViewModel.currentAssistantIcon) as? T
    }

    func transformInfo<T>(text: String?, image: UIImage?, to: T.Type) -> T? {
        ChatLikeDataObject(text: text, image: image, source: .chat, creatorIcon: chatViewModel.currentAssistantIcon) as? T
    }

    func transformAction<T>(actions: [ChatInteractionAction], to: T.Type) -> T? {
        ChatLikeActionObject(actions: actions.compactMap({ action in
            ActionDescriptor(icon: action.icon, identifier: UUID().uuidString, title: action.title) { [weak self] id in
                DDLogDebug("\(Self.logPrefix) perform action with id \(id), title - '\(action.title)'")

                self?.chatUICoordinator.push(item: ChatLikeDataObject(text: action.title, image: nil, source: .user))
                action.handler()
            }
        })) as? T
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

        let icon = UIImage(named: descriptor.iconId)
        chatUICoordinator.push(item: ChatLikeDataObject(text: descriptor.name.localized, image: icon, source: .user))

        chatViewModel.stopConversation()
        chatViewModel.startConversation(withAssistant: identifier, icon: icon)
    }

    struct ActionDescriptor: ChatLikeAction {
        let icon: ChatLikeImage?
        let identifier: String
        let title: String
        let handler: (String) -> Void
    }

    static let logPrefix = "ChatCoordinator"
}
