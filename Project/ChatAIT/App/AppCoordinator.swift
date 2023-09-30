//
//  AppCoordinator.swift
//  ChatAIT
//
//  Created by developer on 03.09.2023.
//

import UIKit

protocol AppCoordinatorInterface: AnyObject {
    func propagateViewController(main viewController: UIViewController)
}

class AppCoordinator: AppCoordinatorInterface {
    func propagateViewController(main viewController: UIViewController) {
        guard nil == charCoordinator else { return }

        charCoordinator = ChatCoordinator(viewController: viewController)
        charCoordinator?.start()
    }

    deinit {
        charCoordinator?.stop()
    }

    private var charCoordinator: ChatCoordinator?
}
