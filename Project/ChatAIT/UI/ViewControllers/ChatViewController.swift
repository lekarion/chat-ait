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
    @IBOutlet private weak var contentView: UIStackView!
}

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
