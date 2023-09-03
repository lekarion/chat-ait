//
//  UIApplication+Coordinator.swift
//  ChatAIT
//
//  Created by developer on 03.09.2023.
//

import UIKit

protocol AppCoordinatorProvider {
    var coordinator: AppCoordinatorInterface { get }
}

extension UIApplication {
    var appCoordinator: AppCoordinatorInterface {
        guard let provider = delegate as? AppCoordinatorProvider else {
            fatalError("Internal inconsistency!!!")
        }
        return provider.coordinator
    }
}
