//
//  ChatCoordinator.swift
//  ChatAIT
//
//  Created by developer on 30.09.2023.
//

// MARK: - ### MVC (Apple) - Controller ### -

import Combine
import CocoaLumberjack
import ChatLikeUI
import UIKit

/**
    Chat coordinator class, in Apple MVC architecture, implementation of the `Controller` component. It owns `Model` and `View` components. As a delegate of the `View` component, it handles user actions that result in modification of the `Model`. As commands sender, it provides data to be presented by the `View` component.
 */
class ChatCoordinator: ChatControllerInterface, ChatViewModelInterface {
    init(viewController: UIViewController) {
        guard let rootView = viewController as? ChatViewInterface else {
            fatalError("Invalid main view controller class")
        }
        self.rootView = rootView

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

        guard let chatViewController = chatUICoordinator.viewController else {
            fatalError("Cannot start main interface module")
        }

        self.rootView.install(chatViewController: chatViewController)
        self.rootView.viewModel = self
        self.rootView.delegate = self

        bindEvents()
    }

    func start() {
        chatModel.start()
    }

    func stop() {
        chatModel.stop()
    }

    let isEmpty = CurrentValueSubject<Bool, Never>(true)

    // MARK: ### Private ###
    private let chatModel = ChatModel()
    private let rootView: ChatViewInterface

    private let chatUICoordinator = ChatLikeCoordinator()
    private var bag = Set<AnyCancellable>()

    private var contentEraseRequested = false
}

extension ChatCoordinator: ChatViewDelegate {
    func viewInterfaceDidRequestErase(_ viewInterface: ChatViewInterface) {
        DDLogDebug("\(Self.logPrefix) \(#function)")

        contentEraseRequested = true
        chatUICoordinator.erase()
    }

    func viewInterfaceDidShowSettings(_ viewInterface: ChatViewInterface) {
        DDLogDebug("\(Self.logPrefix) \(#function)")
    }
}

private extension ChatCoordinator {
    func bindEvents() {
        chatUICoordinator.notificationEvent.receive(on: DispatchQueue.main).sink { [weak self] event in
            guard let self = self else { return }

            switch event {
            case .didUpdateContent:
                if self.contentEraseRequested && !self.isEmpty.value {
                    self.isEmpty.value = true
                    self.contentEraseRequested = false
                } else if !self.contentEraseRequested && self.isEmpty.value {
                    self.isEmpty.value = false
                }
            default:
                break
            }
        }.store(in: &bag)

        chatModel.modelUpdateEvent.receive(on: DispatchQueue.main).sink { [weak self] reason in
            guard let self = self else { return }

            switch reason {
            case .stateChanged(let state):
                DDLogDebug("\(Self.logPrefix) \(#function); new model state is \(state)")
            case .commandReceived(let command):
                guard let item = command.transform(with: self, to: ChatLikeItem.self) else { break }
                chatUICoordinator.push(item: item)
            }
        }.store(in: &bag)
    }

    static let logPrefix = "ChatCoordinator"
}

extension ChatCoordinator: ChatModelCommandTransformer {
    func transformUnion<T>(subitems: [T], to: T.Type) -> T? {
        guard let content = subitems as? [ChatLikeItem] else { return nil }
        return ChatLikeUnionObject(with: content, source: .chat, creatorIcon: chatModel.currentAssistantIcon) as? T
    }

    func transformInfo<T>(text: String?, image: UIImage?, to: T.Type) -> T? {
        ChatLikeDataObject(text: text, image: image, source: .chat, creatorIcon: chatModel.currentAssistantIcon) as? T
    }

    func transformAction<T>(actions: [ChatModelCommandAction], to: T.Type) -> T? {
        ChatLikeActionObject(actions: actions.compactMap({ action in
            ActionDescriptor(icon: action.icon, identifier: UUID().uuidString, title: action.title) { [weak self] id in
                DDLogDebug("\(Self.logPrefix) perform action with id \(id), title - '\(action.title)'")

                self?.chatUICoordinator.push(item: ChatLikeDataObject(text: action.title, image: nil, source: .user))
                action.handler()
            }
        })) as? T
    }

    private struct ActionDescriptor: ChatLikeAction {
        let icon: ChatLikeImage?
        let identifier: String
        let title: String
        let handler: (String) -> Void
    }
}
