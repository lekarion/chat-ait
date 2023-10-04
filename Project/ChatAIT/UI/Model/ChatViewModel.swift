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
    var updateEvent: AnyPublisher<ChatViewModel.UpdateReason, Never> { get }
    var isChatEmpty: Bool { get }
}

protocol ChatViewModelContentProvider: AnyObject {
    var updateEvent: AnyPublisher<Void, Never> { get }
    var isEmpty: Bool { get }
}

class ChatViewModel {
    weak var contentProvider: ChatViewModelContentProvider? {
        didSet {
            guard oldValue !== contentProvider else { return }

            contentProviderCancellable = contentProvider?.updateEvent.receive(on: DispatchQueue.main).sink { [weak self] in
                self?.updateEventSubject.send(.conentChanged)
            }

            updateEventSubject.send(.conentChanged)
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
}

extension ChatViewModel {
    enum State {
        case off, idle, assisting
    }

    enum UpdateReason {
        case stateChanged(state: State)
        case conentChanged
    }

    enum Action {
        case clearContent, showSettings
    }
}

extension ChatViewModel { // Coordinator API
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
    var isChatEmpty: Bool { contentProvider?.isEmpty ?? true }
}

private extension ChatViewModel {
    static let logPrefix = "ChatViewModel:"
}
