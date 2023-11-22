//
//  ChatModel+InteractionWrapper.swift
//  ChatAIT
//
//  Created by developer on 10.11.2023.
//

import DLCoreSDK
import UIKit.UIImage

extension ChatModel {
    class InteractionWrapper: ChatModelCommand {
        init(_ coreInteractionItem: DLCoreInteractionItem) {
            self.coreInteractionItem = coreInteractionItem
        }

        enum PredefinedType {
            case welcomeMessage
            case continueMessage(withPrompt: Bool)
        }

        init(by type: PredefinedType, handler: @escaping (DLCoreInteractionItem, String, UIImage?) -> Void) {
            let allActions = AssistantsFactory.allDescriptors.map { descriptor in
                let assistantIcon = UIImage(named: descriptor.iconId)
                return Action(identifier: descriptor.identifier, title: descriptor.name.localized, icon: assistantIcon, handler: handler)
            }

            switch type {
            case .welcomeMessage:
                coreInteractionItem = UnionItem(subItems: [
                    DataItem(text: "Welcome message".localized, image: nil),
                    ActionItem(actions: allActions)
                ])
            case .continueMessage(let withPrompt):
                coreInteractionItem = withPrompt ?
                    UnionItem(subItems: [
                        DataItem(text: "Start prompt".localized, image: nil),
                        ActionItem(actions: allActions)
                    ]) :
                    ActionItem(actions: allActions)
            }
        }

        private let coreInteractionItem: DLCoreInteractionItem
    }
}

extension ChatModel.InteractionWrapper {
    func transform<T>(with transformer: ChatModelCommandTransformer, to: T.Type) -> T? {
        transform(item: coreInteractionItem, with: transformer, to: to)
    }
}

private extension ChatModel.InteractionWrapper {
    struct ActionCommand: ChatModelCommandAction {
        let title: String
        let icon: UIImage?
        let handler: () -> Void
    }

    func transform<T>(item: DLCoreInteractionItem, with transformer: ChatModelCommandTransformer, to: T.Type) -> T? {
        switch item {
        case let unionItem as DLCoreUnionInteractionItem:
            return transformer.transformUnion(subitems: unionItem.subItems.compactMap({ subItem in
                    transform(item: subItem, with: transformer, to: T.self)
                }), to: T.self)
        case let infoItem as DLCoreInfoInteractionItem:
            return transformer.transformInfo(text: infoItem.text, image: infoItem.image, to: T.self)
        case let actionItem as DLCoreActionInteractionItem:
            return transformer.transformAction(actions: actionItem.actions.compactMap({ action in
                ActionCommand(title: action.title, icon: action.icon, handler: action.perform)
            }), to: T.self)
        default:
            return nil
        }
    }
}

private extension ChatModel.InteractionWrapper {
    class Action: DLCoreAction {
        let identifier: String
        let title: String
        let icon: UIImage?
        let handler: (DLCoreInteractionItem, String, UIImage?) -> Void

        func perform() {
            guard let descriptor = AssistantsFactory.allDescriptors.first(where: { $0.identifier == identifier }) else { return }

            let icon = UIImage(named: descriptor.iconId)
            handler(DataItem(text: descriptor.name.localized, image: icon), descriptor.identifier, icon)
        }

        init(identifier: String, title: String, icon: UIImage?, handler: @escaping (DLCoreInteractionItem, String, UIImage?) -> Void) {
            self.identifier = identifier
            self.title = title
            self.icon = icon
            self.handler = handler
        }
    }

    class ActionItem: DLCoreActionInteractionItem {
        let identifier: String
        let icon: UIImage?
        let actions: [DLCoreAction]

        init(actions: [DLCoreAction], icon: UIImage? = nil) {
            self.identifier = UUID().uuidString
            self.icon = icon
            self.actions = actions
        }
    }

    class DataItem: DLCoreInfoInteractionItem {
        let identifier: String
        let text: String?
        let image: UIImage?

        init(text: String?, image: UIImage?) {
            self.identifier = UUID().uuidString
            self.text = text
            self.image = image
        }
    }

    class UnionItem: DLCoreUnionInteractionItem {
        let identifier: String
        let subItems: [DLCoreInteractionItem]

        init(subItems: [DLCoreInteractionItem]) {
            self.identifier = UUID().uuidString
            self.subItems = subItems
        }
    }
}
