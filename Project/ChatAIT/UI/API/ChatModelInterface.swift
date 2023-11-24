//
//  ChatModelInterface.swift
//  ChatAIT
//
//  Created by developer on 24.11.2023.
//

import Combine
import Foundation
import UIKit.UIImage

// MARK: - ### Model Interfaces ### -
/// The chat `Model` component interface protocol
protocol ChatModelInterface: AnyObject {
    /// chat model update notification event
    var modelUpdateEvent: AnyPublisher<ChatModelUpdateReason, Never> { get }

    /// Start chat model
    func start()
    /// Start new conversation
    /// - Parameter identifier: unique identifier for a new conversation
    /// - Parameter icon: custom conversation icon
    func startConversation(withAssistant identifier: String, icon: UIImage?)
    /// Stop current conversation
    func stopConversation()
    /// Stop chat model
    func stop()
}
/// The reason for sending the update event
enum ChatModelUpdateReason {
    /// sent when the model state changed
    case stateChanged(state: ChatModelState)
    /// sent when new command received and ready to be "visualized"
    case commandReceived(command: ChatModelCommand)
}
/// The chat model state
enum ChatModelState {
    case off, idle, assisting
}

/// The model command interface protocol
protocol ChatModelCommand: AnyObject {
    /// Abstract command transformation method
    /// - Parameter transformer: Command transformation object (adapter)
    /// - Parameter type: Transformation result type
    /// - Returns new command of requested type or nil
    func transform<T>(with transformer: ChatModelCommandTransformer, to type: T.Type) -> T?
}
/// Abstract command transformation interface (adaptation interface)
protocol ChatModelCommandTransformer {
    func transformUnion<T>(subitems: [T], to: T.Type) -> T?
    func transformInfo<T>(text: String?, image: UIImage?, to: T.Type) -> T?
    func transformAction<T>(actions: [ChatModelCommandAction], to: T.Type) -> T?
}
/// Model command action interface
protocol ChatModelCommandAction {
    var title: String { get }
    var icon: UIImage? { get }
    var handler: () -> Void { get }
}
