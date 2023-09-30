//
//  AssistantsFactory.swift
//  ChatAIT
//
//  Created by developer on 04.09.2023.
//

import Foundation
import DL8BallAssistant
import DLDragonAssistant

class AssistantsFactory {
    struct AssistantDescriptor {
        let identifier: String
        let name: String
        let iconId: String
        let registrationHandler: (Any) -> Void
    }

    static let allDescriptors = [
        AssistantDescriptor(identifier: magic8BallConversationId, name: "Magic 8 Ball Assistant", iconId: "magic-8-ball-assistant-icon") {
            assistantIdentifiersMap[magic8BallConversationId] = "AssistantsFactory.Magic8BallAssistant"
            DL8BallAssistantRegistrar.registerAssistant(for: assistantIdentifiersMap[magic8BallConversationId]!, with: $0)
        },
        AssistantDescriptor(identifier: dragonConversationId, name: "Dragon Assistant", iconId: "dragon-assistant-icon") {
            assistantIdentifiersMap[dragonConversationId] = "AssistantsFactory.DragonAssistant"
            DLDragonAssistantRegistrar.registerAssistant(for: assistantIdentifiersMap[dragonConversationId]!, with: $0)
        }
    ]

    private(set) static var assistantIdentifiersMap = [String: String]()

    // MARK: ### Private ###
    private init() {
    }
}

extension AssistantsFactory {
    static let magic8BallConversationId = "com.assistants.magic8BallConversation"
    static let dragonConversationId = "com.assistants.dragonConversation"
}
