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
    func propagate(viewModel: ChatModelInterface)
}

// MARK: -
/// The chat view model interface protocol
protocol ChatModelInterface: AnyObject {
    var updateEvent: AnyPublisher<ChatModelUpdateReason, Never> { get }
}

enum ChatModelState {
    case off, idle, assisting
}

enum ChatModelUpdateReason {
    case stateChanged(state: ChatModelState)
    case commandReceived(command: ChatModelCommand)
}

protocol ChatModelCommand: AnyObject {
    func transform<T>(with transformer: ChatModelCommandTransformer, to: T.Type) -> T?
}

protocol ChatModelCommandTransformer {
    func transformUnion<T>(subitems: [T], to: T.Type) -> T?
    func transformInfo<T>(text: String?, image: UIImage?, to: T.Type) -> T?
    func transformAction<T>(actions: [ChatModelCommandAction], to: T.Type) -> T?
}

protocol ChatModelCommandAction {
    var title: String { get }
    var icon: UIImage? { get }
    var handler: () -> Void { get }
}

// MARK: -

/// The chat view model external content data provider interface
protocol ChatViewModelContentProvider: AnyObject {
    var updateEvent: AnyPublisher<Void, Never> { get }
    var isEmpty: Bool { get }

    func send(command: ContentCommand)
}

enum ContentCommand {
    case showWelcomeMessage
    case showConversations(withPrompt: Bool)
    case showInteraction(_ interaction: ChatInteraction)
}

// MARK: -
/// The view action delegate
protocol ChatViewControllerDelegate: AnyObject {
    func clearChat()
}

/// The view interface protocol
protocol ChatViewControllerInterface: ViewModelPropagation {
    var delegate: ChatViewControllerDelegate? { get set }
}

// MARK: -
protocol ChatInteraction: AnyObject {
    func transform<T>(with transformer: ChatInteractionTransformer, to: T.Type) -> T?
}

protocol ChatInteractionTransformer {
    func transformUnion<T>(subitems: [T], to: T.Type) -> T?
    func transformInfo<T>(text: String?, image: UIImage?, to: T.Type) -> T?
    func transformAction<T>(actions: [ChatInteractionAction], to: T.Type) -> T?
}

protocol ChatInteractionAction {
    var title: String { get }
    var icon: UIImage? { get }
    var handler: () -> Void { get }
}
