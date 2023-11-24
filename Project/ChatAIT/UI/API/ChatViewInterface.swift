//
//  ChatViewInterface.swift
//  ChatAIT
//
//  Created by developer on 24.11.2023.
//

import Combine
import UIKit.UIViewController

// MARK: - ### View Interfaces ### -
/// The chat `View` component interface protocol
protocol ChatViewInterface: AnyObject {
    /// The view delegate property
    var delegate: ChatViewDelegate? { get set }
    /// The provider of the data to be visualized by the view
    var viewModel: ChatViewModelInterface? { get set }

    /// This method provides ability to instal external view controller that provides chat view
    /// - Parameter chatViewController: chat view controller object
    func install(chatViewController: UIViewController)
}
/// The chat view delegate interface
protocol ChatViewDelegate: AnyObject {
    func viewInterfaceDidRequestErase(_ viewInterface: ChatViewInterface)
}
/// The chat data provider interface
protocol ChatViewModelInterface: AnyObject {
    /// The model data availability property
    var isEmpty: CurrentValueSubject<Bool, Never> { get }
}
