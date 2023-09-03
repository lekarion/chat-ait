//
//  ViewController.swift
//  ChatAIT
//
//  Created by developer on 31.08.2023.
//

import ChatLikeUI_iOS
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.appCoordinator.installUI(to: self)
    }
}

