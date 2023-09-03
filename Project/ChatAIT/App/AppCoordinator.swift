//
//  AppCoordinator.swift
//  ChatAIT
//
//  Created by developer on 03.09.2023.
//

import UIKit

protocol AppCoordinatorInterface: AnyObject {
    func installUI(to rootViewController: UIViewController)
}

class AppCoordinator: AppCoordinatorInterface {
    func installUI(to rootViewController: UIViewController) {
    }
}
