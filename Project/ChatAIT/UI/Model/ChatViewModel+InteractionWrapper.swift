//
//  ChatViewModel+InteractionWrapper.swift
//  ChatAIT
//
//  Created by developer on 10.11.2023.
//

import DLCoreSDK

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
        switch coreInteractionItem {
        case let unionItem as DLCoreUnionInteractionItem:
            return transformer.transformUnion(subitems: unionItem.subItems.compactMap({ item in
                    transform(with: transformer, to: T.self)
                }), to: T.self)
        case let infoItem as DLCoreInfoInteractionItem:
            return transformer.transformInfo(text: infoItem.text, image: infoItem.image, to: T.self)
        default:
            return nil
        }

//        if let unionItem = item as? DLCoreUnionInteractionItem {
//        } else if let infoItem = item as? DLCoreInfoInteractionItem {
//            container.append(GenericDataElement(with: infoItem, assistantIcon: _assistantIcon))
//        } else if let actionItem = item as? DLCoreActionInteractionItem {
//            let actions = actionItem.actions.compactMap { action in
//                let element = GenericActionElement(with: action)
//                element.delegate = self
//                return element
//            }
//
//            var index = startIndex + container.count
//            container.append(contentsOf: actions)
//            actionsContainer.append(contentsOf: actions.map({ element in
//                let result = (element, index)
//                index += 1
//                return result
//            }))
//        }
    }
}
