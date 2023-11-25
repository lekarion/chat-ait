//
//  ChatViewController.swift
//  ChatAIT
//
//  Created by developer on 31.08.2023.
//

// MARK: - ### MVC (Apple) - View ### -

import Combine
import UIKit

/**
    Chat root view controller class, in Apple MVC architecture, implementation of the `View` component. It notifies the `delegate` of user actions and handles model data update notifications.
 */
class ChatViewController: UIViewController, ChatViewInterface {
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.appCoordinator.propagateViewController(main: self)

        updateUI()
    }

    weak var delegate: ChatViewDelegate?
    weak var viewModel: ChatViewModelInterface? {
        didSet {
            guard oldValue !== viewModel else { return }

            viewModelBag.removeAll()
            viewModel?.isEmpty.receive(on: DispatchQueue.main).sink { [weak self] _ in
                self?.updateUI()
            }.store(in: &viewModelBag)
        }
    }

    func install(chatViewController: UIViewController) {
        guard nil == chatViewController.parent else { return }

        children.forEach {
            $0.removeFromParent()
            $0.view.removeFromSuperview()
        }

        contentView.addArrangedSubview(chatViewController.view)
        addChild(chatViewController)
    }

    // MARK: ### Private ###
    @IBOutlet private weak var contentView: UIStackView!
    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var eraseButton: UIButton!

    private var viewModelBag = Set<AnyCancellable>()
}

extension ChatViewController { // Actions
    @IBAction func onEraseChat(_ sender: Any) {
        delegate?.viewInterfaceDidRequestErase(self)
    }

    static let settingsSegueIdentifier = "com.show.settings"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case Self.settingsSegueIdentifier:
            delegate?.viewInterfaceDidShowSettings(self)
        default:
            break
        }
    }
}

// MARK: -
private extension ChatViewController {
    func updateUI() {
        eraseButton.isEnabled = viewModel?.isEmpty.value == false
    }
}
