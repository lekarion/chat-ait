//
//  ChatModel.swift
//  ChatAIT
//
//  Created by developer on 04.09.2023.
//

// MARK: - ### MVC (Apple) - Model ### -

import CocoaLumberjack
import Combine
import DecouplingLabSDK
import DLCoreSDK
import UIKit

/**
    Chat model class, in Apple MVC architecture, implementation of the `Model` component. It has a reference to the `Controller` interface, which provides an API for receiving notifications about user actions from the `View` component and sending notifications to the `Controller` about model data changes.
 */
class ChatModel {
    private (set) var state: ChatModelState = .off {
        didSet {
            guard oldValue != state else { return }
            updateEventSubject.send(.stateChanged(state: state))
        }
    }

    var currentAssistantIcon: UIImage? { assistantIcon }

    // MARK: ### Private ###
    private var updateEventSubject = PassthroughSubject<ChatModelUpdateReason, Never>()
    private var contentProviderCancellable: AnyCancellable?

    private var assistantId: String?
    private var assistantIcon: UIImage?
    private var currentAssistant: DecouplingLabAssistant?
    private var assistantItemCancellable: AnyCancellable?

    private var showConversationsPrompt: Bool = false
}

extension ChatModel { // Coordinator API
    /// Start chat model.
    func start() {
        guard state == .off else { return }

        state = .idle

        updateEventSubject.send(.commandReceived(command: showWelcomeMessage()))
    }
    /// Start new conversation
    func startConversation(withAssistant identifier: String, icon: UIImage? = nil) {
        guard state == .idle else { return }

        guard let assistantId = AssistantsFactory.assistantIdentifiersMap[identifier] else { return }
        guard let assistant = DecouplingLab.assistant(for: assistantId) else { return }

        currentAssistant?.stopAssisting()

        assistantItemCancellable = assistant.interactionItem.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] item in
            self?.process(item)
        })
        assistant.startAssisting()

        self.currentAssistant = assistant
        self.assistantId = identifier
        self.assistantIcon = icon

        state = .assisting
    }
    /// Start current conversation
    func stopConversation() {
        guard state != .off else { return }

        assistantItemCancellable = nil
        currentAssistant?.stopAssisting()
        currentAssistant = nil
        assistantId = nil
        assistantIcon = nil

        showConversationsPrompt = true
        state = .idle
    }
    /// Stop chat model.
    func stop() {
        guard state != .off else { return }

        stopConversation()

        state = .off
    }
}

extension ChatModel: ChatModelInterface {
    var updateEvent: AnyPublisher<ChatModelUpdateReason, Never> { updateEventSubject.eraseToAnyPublisher() }
}

private extension ChatModel {
    static let logPrefix = "ChatModel:"

    func process(_ item: DLCoreInteractionItem?) {
        if let interactionItem = item {
            updateEventSubject.send(.commandReceived(command: InteractionWrapper(interactionItem)))
        } else {
            stopConversation()
            updateEventSubject.send(.commandReceived(command: showConversations(withPrompt: true)))
        }
    }

    func showWelcomeMessage() -> ChatModelCommand { InteractionWrapper(by: .welcomeMessage, handler: didSelectAssistant) }
    func showConversations(withPrompt: Bool) -> ChatModelCommand { InteractionWrapper(by: .continueMessage(withPrompt: withPrompt), handler: didSelectAssistant) }

    func didSelectAssistant(_ command: DLCoreInteractionItem, _ identifier: String, _ icon: UIImage?) {
        updateEventSubject.send(.commandReceived(command: ChatModel.InteractionWrapper(command)))

        stopConversation()
        startConversation(withAssistant: identifier, icon: icon)
    }
}
