//
//  ChatViewModel.swift
//  ChatAIT
//
//  Created by developer on 04.09.2023.
//

import CocoaLumberjack
import Combine
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

    // MARK: ### Private ###
    private var updateEventSubject = PassthroughSubject<UpdateReason, Never>()
    private var contentProviderCancellable: AnyCancellable?

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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.contentProvider?.send(command: .showWelcomeMessage)
        }

        state = .idle
    }

    /// Start new conversation
    func startConversation() {
        guard state == .idle else { return }

        contentProvider?.send(command: .showConversations(withPrompt: showConversationsPrompt))

        state = .assisting
    }

    func stopConversation() {
        guard state != .off else { return }

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
}
