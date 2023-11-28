//
//  AppModelTests+Command.swift
//  ChatAITTests
//
//  Created by developer on 28.11.2023.
//

import XCTest
import UIKit

@testable import ChatAIT

protocol AppModelTestCommand {
    var type: AppModelTestCommandType { get }
}

protocol AppModelTestCommandUnion: AppModelTestCommand {
    var subitems: [AppModelTestCommand] { get }
}

extension AppModelTestCommandUnion {
    var type: AppModelTestCommandType { .union }
}

protocol AppModelTestCommandAction: AppModelTestCommand {
    var actions: [AppModelTestAction] { get }
}

extension AppModelTestCommandAction {
    var type: AppModelTestCommandType { .action }
}

protocol AppModelTestCommandData: AppModelTestCommand {
    var text: String? { get }
    var imageInfo: String? { get }
}

extension AppModelTestCommandData {
    var type: AppModelTestCommandType { .data }
}

enum AppModelTestCommandType {
    case data, action, union
}

protocol AppModelTestAction {
    var identifier: String { get }
    var title: String { get }
    var handler: (String) -> Void { get }
}

// MARK: - ### Command Transforming ### -
extension AppModelTests {
    class DataCommand: AppModelTestCommandData {
        let text: String?
        let imageInfo: String?

        init(text: String?, imageInfo: String?) {
            self.text = text
            self.imageInfo = imageInfo
        }
    }

    class ActionDescriptor: AppModelTestAction {
        let identifier: String
        let title: String
        let handler: (String) -> Void

        init(identifier: String, title: String, handler: @escaping (String) -> Void) {
            self.identifier = identifier
            self.title = title
            self.handler = handler
        }
    }

    class ActionCommand: AppModelTestCommandAction {
        let actions: [AppModelTestAction]

        init(actions: [AppModelTestAction]) {
            self.actions = actions
        }
    }

    class UnionCommand: AppModelTestCommandUnion {
        let subitems: [AppModelTestCommand]

        init(subitems: [AppModelTestCommand]) {
            self.subitems = subitems
        }
    }
}

extension AppModelTests: ChatModelCommandTransformer {
    func transformUnion<T>(subitems: [T], to: T.Type) -> T? {
        guard let content = subitems as? [AppModelTestCommand] else { return nil }
        return UnionCommand(subitems: content) as? T
    }

    func transformInfo<T>(text: String?, image: UIImage?, to: T.Type) -> T? {
        DataCommand(text: text, imageInfo: image?.testDescription) as? T
    }

    func transformAction<T>(actions: [ChatModelCommandAction], to: T.Type) -> T? {
        ActionCommand(actions: actions.compactMap({ action in
            ActionDescriptor(identifier: UUID().uuidString, title: action.title) { _ in
                action.handler()
            }
        })) as? T
    }
}

extension UIImage {
    var testDescription: String {
        "UIImage: size = \(self.size)"
    }
}
