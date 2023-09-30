//
//  ChatModel.swift
//  ChatAIT
//
//  Created by developer on 04.09.2023.
//

import CocoaLumberjack
import Combine
import DecouplingLabSDK
import UIKit

protocol ChatViewModelInterface: AnyObject {
}

class ChatModel: ChatViewModelInterface {
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
    /// Start chat model.
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

    /// Start new conversation
    func startConversation() {
        guard state == .idle else { return }

        state = .assisting

//        var elements = [ConversationModelElement]()
//        elements.append(GenericDataElement(with: "Let's start! Select conversation type".localized))
//
//        let allAssistants = AssistantsFactory.allDescriptors.map { descriptor in
//            let assistantIcon = UIImage(named: descriptor.iconId)
//            let element = GenericActionElement(descriptor.identifier, title: descriptor.name.localized, icon: assistantIcon) { [weak self] identifier in
//                self?.startAssistant(identifier, icon: assistantIcon)
//            }
//            element.delegate = self
//
//            return element
//        }
//        elements.append(contentsOf: allAssistants)
//
//        var index = _elements.count + 1
//        append(elements: elements )
//        _actionElements = allAssistants.map({ element in
//            let result = (element, index)
//            index += 1
//            return result
//        })
    }

    func stopConversation() {
        guard state != .off else { return }

//        _assistantItemCancellable = nil
//        _currentAssistant?.stopAssisting()
//        _currentAssistant = nil
//        _assistantId = nil
//        _assistantIcon = nil
//
//        clearActionElements()

        state = .idle
    }
    /// Stop chat model.
    func stop() {
        guard state != .off else { return }

        stopConversation()
        DecouplingLab.stop()

        state = .off
    }
}

extension ChatModel {
    static let logPrefix = "ChatModel:"
}
