//
//  ChatViewController.swift
//  ChatAIT
//
//  Created by developer on 31.08.2023.
//

import UIKit

protocol ChatViewControllerDelegate: AnyObject {
    func showSettings()
    func clearChat()
}

protocol ChatViewControllerInterface: ViewModelPropagation {
    var delegate: ChatViewControllerDelegate? { get set }
}

class ChatViewController: UIViewController, ChatViewControllerInterface {
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.appCoordinator.propagateViewController(main: self)
    }

    weak var delegate: ChatViewControllerDelegate?

    // MARK: ### Private ###
    private weak var viewModel: ChatViewModelInterface?

    @IBOutlet private weak var contentView: UIStackView!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var eraseButton: UIButton!
}

extension ChatViewController { // Actions
    @IBAction func onShowSettings(_ sender: Any) {
        delegate?.showSettings()
    }

    @IBAction func onEraseChat(_ sender: Any) {
        delegate?.clearChat()
    }
}

// MARK -
extension ChatViewController: InterfaceInstaller {
    func install(viewController: UIViewController) {
        guard nil == viewController.parent else { return }

        children.forEach {
            $0.removeFromParent()
            $0.view.removeFromSuperview()
        }

        contentView.addSubview(viewController.view)
        addChild(viewController)
    }
}

extension ChatViewController { // ViewModelPropagation
    func propagate(viewModel: ChatViewModelInterface) {
        self.viewModel = viewModel
    }
}
