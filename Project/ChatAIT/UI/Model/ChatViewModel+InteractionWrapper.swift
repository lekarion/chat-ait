//
//  ChatViewModel+InteractionWrapper.swift
//  ChatAIT
//
//  Created by developer on 10.11.2023.
//

import DLCoreSDK
import UIKit.UIImage

extension ChatViewModel {
    class InteractionWrapper: ChatInteraction {
        init(_ coreInteractionItem: DLCoreInteractionItem) {
            self.coreInteractionItem = coreInteractionItem
        }

        private let coreInteractionItem: DLCoreInteractionItem
    }
}

extension ChatViewModel.InteractionWrapper {
    func transform<T>(with transformer: ChatInteractionTransformer, to: T.Type) -> T? {
        transform(item: coreInteractionItem, with: transformer, to: to)
    }
}

private extension ChatViewModel.InteractionWrapper {
    struct Action: ChatInteractionAction {
        let title: String
        let icon: UIImage?
        let handler: () -> Void
    }

    func transform<T>(item: DLCoreInteractionItem, with transformer: ChatInteractionTransformer, to: T.Type) -> T? {
        switch item {
        case let unionItem as DLCoreUnionInteractionItem:
            return transformer.transformUnion(subitems: unionItem.subItems.compactMap({ subItem in
                    transform(item: subItem, with: transformer, to: T.self)
                }), to: T.self)
        case let infoItem as DLCoreInfoInteractionItem:
            return transformer.transformInfo(text: infoItem.text, image: infoItem.image, to: T.self)
        case let actionItem as DLCoreActionInteractionItem:
            return transformer.transformAction(actions: actionItem.actions.compactMap({ action in
                Action(title: action.title, icon: action.icon, handler: action.perform)
            }), to: T.self)
        default:
            return nil
        }
    }
}
