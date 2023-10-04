//
//  ChatViewModelInterface.swift
//  ChatAIT
//
//  Created by developer on 04.10.2023.
//

import Combine
import UIKit

/// The external view controller installation interface
protocol InterfaceInstaller: AnyObject {
    func install(viewController: UIViewController)
}

/// The view model propagation interface
protocol ViewModelPropagation: AnyObject {
    func propagate(viewModel: ChatViewModelInterface)
}

// MARK: -
/// The chat view model interface protocol
protocol ChatViewModelInterface: AnyObject {
    var updateEvent: AnyPublisher<ChatViewModel.UpdateReason, Never> { get }
    var isChatEmpty: Bool { get }
}

/// The chat view model external content data provider interface
protocol ChatViewModelContentProvider: AnyObject {
    var updateEvent: AnyPublisher<Void, Never> { get }
    var isEmpty: Bool { get }

    func send(command: ContentCommand)
}

enum ContentCommand {
    case showWelcomeMessage
    case showConversations(withPrompt: Bool)
}

// MARK: -
/// The view action delegate
protocol ChatViewControllerDelegate: AnyObject {
    func showSettings()
    func clearChat()
}

/// The view interface protocol
protocol ChatViewControllerInterface: ViewModelPropagation {
    var delegate: ChatViewControllerDelegate? { get set }
}
