//
//  ChatModel.swift
//  ChatAIT
//
//  Created by developer on 04.09.2023.
//

import CocoaLumberjack
import Combine
import DecouplingLabSDK

class ChatModel {
    enum State {
        case off, idle, assisting
    }

    var state: State = .off {
        didSet {
            eventSubject.send(StateUpdateEvent(state))
        }
    }

    var event: AnyPublisher<ChatModelEvent, Never> { eventSubject.eraseToAnyPublisher() }

    // MARK: ### Private ###
    init() {
        guard let identifier = Bundle.main.bundleIdentifier else {
            fatalError("Internal inconsistency")
        }
        self.identifier = identifier
    }

    private let identifier: String
    private var eventSubject = PassthroughSubject<ChatModelEvent, Never>()
}

extension ChatModel {
    func start() {
        guard state == .off else { return }

        DecouplingLab.start(with: identifier)
        DecouplingLab.registerAssistants { context in
            AssistantsFactory.allDescriptors.forEach { descriptor in
                descriptor.registrationHandler(context)
            }
        }

        DecouplingLab.allAssistantIdentifiers.forEach { identifier in
            DecouplingLab.enableAssistant(for: identifier, true)
            DDLogVerbose("\(Self.logPrefix) assistant with identifier '\(identifier)' is enabled")
        }

        state = .idle
    }

    func stop() {
        guard state != .off else { return }

        DecouplingLab.stop()
        state = .off
    }
}

extension ChatModel {
    static let logPrefix = "ChatModel:"
}
