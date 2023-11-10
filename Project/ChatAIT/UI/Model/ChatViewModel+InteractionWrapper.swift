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
}
