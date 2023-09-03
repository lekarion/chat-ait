//
//  ViewController.swift
//  ChatAIT
//
//  Created by developer on 31.08.2023.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.appCoordinator.installUI(with: self)
    }
}

extension ViewController: InterfaceInstaller {
    func install(viewController: UIViewController) {
        // TODO: implement
    }
}
