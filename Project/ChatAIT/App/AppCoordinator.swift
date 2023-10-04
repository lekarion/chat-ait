//
//  AppCoordinator.swift
//  ChatAIT
//
//  Created by developer on 03.09.2023.
//

import CocoaLumberjack
import DecouplingLabSDK
import UIKit

protocol AppCoordinatorInterface: AnyObject {
    func propagateViewController(main viewController: UIViewController)
}

class AppCoordinator {
    init() {
        guard let identifier = Bundle.main.bundleIdentifier else {
            fatalError("Internal inconsistency")
        }

        DecouplingLab.start(with: identifier)
        DecouplingLab.registerAssistants { context in
            AssistantsFactory.allDescriptors.forEach { descriptor in
                descriptor.registrationHandler(context)
            }
        }

        DecouplingLab.allAssistantIdentifiers.forEach { identifier in
            DecouplingLab.enableAssistant(for: identifier, true)
            DDLogVerbose("\(Self.logPrefix) assistant with identifier '\(identifier)' is enabled")
        }
    }


    deinit {
        chatCoordinator?.stop()
        DecouplingLab.stop()
    }

    private var chatCoordinator: ChatCoordinator?
}

extension AppCoordinator: AppCoordinatorInterface {
    func propagateViewController(main viewController: UIViewController) {
        guard nil == chatCoordinator else { return }

        chatCoordinator = ChatCoordinator(viewController: viewController)
        chatCoordinator?.start()
    }
}

private extension AppCoordinator {
    static let logPrefix = "AppCoordinator:"
}
