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
}

class ChatViewModel: ChatViewModelInterface {
    enum State {
        case off, idle, assisting
    }

    var state: State = .off {
        didSet {
            eventSubject.send(StateUpdateEvent(state))
        }
    }

    var event: AnyPublisher<ChatViewModelEvent, Never> { eventSubject.eraseToAnyPublisher() }

    // MARK: ### Private ###
    private var eventSubject = PassthroughSubject<ChatViewModelEvent, Never>()
}

extension ChatViewModel {
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

extension ChatViewModel {
    static let logPrefix = "ChatViewModel:"
}

//private extension ChatCoordinator {
//        chatModel.event.receive(on: DispatchQueue.main).sink { [weak self] event in
//            guard let self = self else { return }
//
//            switch event {
//            case let state as StateEvent:
//                self.process(state: state)
//            default:
//                break
//            }
//        }.store(in: &bag)
//
//    func process(state event: StateEvent) {
//        switch event.state {
//        case .assisting:
//            if isInitialStart {
//                chatUICoordinator.push(item: ChatLikeData(text: "Welcome message".localized, image: nil, source: .chat, creatorIcon: chatIcon))
//                isInitialStart = false
//            } else {
//                chatUICoordinator.startThread()
//            }
//        case .off:
//            chatUICoordinator.updateThread(ChatLikeThreadInfo(footer: event.info))
//        default:
//            break
//        }
//    }
//}
