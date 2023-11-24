//
//  ChatControllerInterface.swift
//  ChatAIT
//
//  Created by developer on 24.11.2023.
//

import Foundation

// MARK: - ### Controller Interfaces ### -
/// The chat `Controller` component interface protocol
protocol ChatControllerInterface: AnyObject {
    /// The controller start method
    func start()
    /// The controller stop method
    func stop()
}
