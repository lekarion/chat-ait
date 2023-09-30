//
//  ChatViewController.swift
//  ChatAIT
//
//  Created by developer on 31.08.2023.
//

import UIKit

class ChatViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.appCoordinator.propagateViewController(main: self)
    }

    // MARK: ### Private ###
    private var viewModel: ChatViewModelInterface?

    @IBOutlet private weak var contentView: UIStackView!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var eraseButton: UIButton!
}

extension ChatViewController { // Actions
    @IBAction func onShowSettings(_ sender: Any) {
    }

    @IBAction func onEraseChat(_ sender: Any) {
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

extension ChatViewController: ViewModelPropagation {
    func propagate(viewModel: ChatViewModelInterface) {
        self.viewModel = viewModel
    }
}
