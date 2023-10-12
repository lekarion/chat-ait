//
//  ChatViewController.swift
//  ChatAIT
//
//  Created by developer on 31.08.2023.
//

import Combine
import UIKit

class ChatViewController: UIViewController, ChatViewControllerInterface {
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.appCoordinator.propagateViewController(main: self)

        updateUI()
    }

    weak var delegate: ChatViewControllerDelegate?

    // MARK: ### Private ###
    private weak var viewModel: ChatViewModelInterface? {
        didSet {
            guard oldValue !== viewModel else { return }
            viewModelCancellable = viewModel?.updateEvent.receive(on: DispatchQueue.main).sink { [weak self] reason in
                switch reason {
                case .contentChanged:
                    self?.updateUI()
                default:
                    break
                }
            }
        }
    }

    @IBOutlet private weak var contentView: UIStackView!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var eraseButton: UIButton!

    private var viewModelCancellable: AnyCancellable?
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

        contentView.addArrangedSubview(viewController.view)
        addChild(viewController)
    }
}

extension ChatViewController { // ViewModelPropagation
    func propagate(viewModel: ChatViewModelInterface) {
        self.viewModel = viewModel
    }
}
// MARK: -
private extension ChatViewController {
    func updateUI() {
        eraseButton.isEnabled = viewModel?.isChatEmpty == false
    }
}
