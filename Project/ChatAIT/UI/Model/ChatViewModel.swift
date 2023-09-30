//
//  ChatViewModel.swift
//  ChatAIT
//
//  Created by developer on 04.09.2023.
//

import CocoaLumberjack
import Combine
import UIKit

protocol ChatViewModelInterface: AnyObject {
    var isChatEmpty: Bool { get }
    func showSettings()
    func clearChat()
}

class ChatViewModel {
    enum State {
        case off, idle, assisting
    }

    enum UpdateReason {
        case stateChanged(state: State)
        case conentChanged
    }

    enum Action {
        case clearContent
    }

    private (set) var state: State = .off {
        didSet {
            updateEventSubject.send(.stateChanged(state: state))
        }
    }

    // MARK: ### Private ###
    private var actionEventSubject = PassthroughSubject<Action, Never>()
    private var updateEventSubject = PassthroughSubject<UpdateReason, Never>()
}

extension ChatViewModel { // Coordinator API
    var actionEvent: AnyPublisher<Action, Never> { actionEventSubject.eraseToAnyPublisher() }

    /// Start chat model.
    func start() {
        guard state == .off else { return }


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

        state = .off
    }
}

extension ChatViewModel: ChatViewModelInterface { // View controller API
    var updateEvent: AnyPublisher<UpdateReason, Never> { updateEventSubject.eraseToAnyPublisher() }

    var isChatEmpty: Bool { true }

    func showSettings() {
    }

    func clearChat() {
        actionEventSubject.send(.clearContent)
    }
}

private extension ChatViewModel {
    static let logPrefix = "ChatViewModel:"
}
