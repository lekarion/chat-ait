//
//  ChatCoordinator.swift
//  ChatAIT
//
//  Created by developer on 30.09.2023.
//

import Combine
import ChatLikeUI_iOS
import UIKit

protocol InterfaceInstaller: AnyObject {
    func install(viewController: UIViewController)
}

protocol ViewModelPropagation: AnyObject {
    func propagate(viewModel: ChatViewModelInterface)
}

class ChatCoordinator {
    init(viewController: UIViewController) {
        guard let controller = viewController as? (InterfaceInstaller & ChatViewControllerInterface) else {
            fatalError("Invalid main view controller class")
        }
        self.viewController = viewController

        chatUICoordinator.setup(with: ChatLikeConfiguration.Builder().build())
        guard let rootViewController = chatUICoordinator.viewController else {
            fatalError("Cannot start main interface module")
        }

        controller.install(viewController: rootViewController)
        controller.propagate(viewModel: chatViewModel)
        controller.delegate = self

        chatViewModel.start()

        bindEvents()
    }

    func start() {
        chatViewModel.startConversation()
    }

    func stop() {
        chatViewModel.stopConversation()
    }

    // MARK: ### Private ###
    private let viewController: UIViewController
    private let chatUICoordinator = ChatLikeCoordinator()
    private let chatViewModel = ChatViewModel()
    private var bag = Set<AnyCancellable>()

    private let contentUpdateSubject = PassthroughSubject<Void, Never>()

    private var isInitialStart = true
    private lazy var chatIcon = { UIImage(named: "chat-icon") }()
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
}
