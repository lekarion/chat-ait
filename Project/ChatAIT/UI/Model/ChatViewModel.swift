//
//  ChatViewModel.swift
//  ChatAIT
//
//  Created by developer on 04.09.2023.
//

import CocoaLumberjack
import Combine
import DecouplingLabSDK
import DLCoreSDK
import UIKit

class ChatViewModel {
    weak var contentProvider: ChatViewModelContentProvider? {
        didSet {
            guard oldValue !== contentProvider else { return }

            contentProviderCancellable = contentProvider?.updateEvent.receive(on: DispatchQueue.main).sink { [weak self] in
                self?.updateEventSubject.send(.contentChanged)
            }

            updateEventSubject.send(.contentChanged)
        }
    }

    private (set) var state: State = .off {
        didSet {
            guard oldValue != state else { return }
            updateEventSubject.send(.stateChanged(state: state))
        }
    }

    var currentAssistantIcon: UIImage? { assistantIcon }

    // MARK: ### Private ###
    private var updateEventSubject = PassthroughSubject<UpdateReason, Never>()
    private var contentProviderCancellable: AnyCancellable?

    private var assistantId: String?
    private var assistantIcon: UIImage?
    private var currentAssistant: DecouplingLabAssistant?
    private var assistantItemCancellable: AnyCancellable?

    private var showConversationsPrompt: Bool = false
}

extension ChatViewModel {
    enum State {
        case off, idle, assisting
    }

    enum UpdateReason {
        case stateChanged(state: State)
        case contentChanged
    }

    enum Action {
        case clearContent, showSettings
    }
}

extension ChatViewModel { // Coordinator API
    /// Start chat model.
    func start() {
        guard state == .off else { return }

        contentProvider?.send(command: .showWelcomeMessage)

        state = .idle
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

extension ChatViewModel: ChatViewModelInterface { // View controller API
    var updateEvent: AnyPublisher<UpdateReason, Never> { updateEventSubject.eraseToAnyPublisher() }
    var isChatEmpty: Bool { contentProvider?.isEmpty ?? true }
}

private extension ChatViewModel {
    static let logPrefix = "ChatViewModel:"

    func process(_ item: DLCoreInteractionItem?) {
        if let interactionItem = item {
            contentProvider?.send(command: .showInteraction(InteractionWrapper(interactionItem)))
        } else {
            stopConversation()
            contentProvider?.send(command: .showConversations(withPrompt: true))
        }
    }
}
