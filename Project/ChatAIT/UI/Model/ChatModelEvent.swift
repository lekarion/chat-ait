//
//  ChatModelEvent.swift
//  ChatAIT
//
//  Created by developer on 04.09.2023.
//

import UIKit

protocol ChatModelEvent {
    var info: String? { get }
}

protocol UpdateEvent: ChatModelEvent {
    var kind: UpdateEventKind { get }
}

protocol StateEvent: UpdateEvent {
    var state: ChatModel.State { get }
}

protocol ElementEvent: UpdateEvent {
    var text: String? { get }
    var image: UIImage? { get }
}

enum UpdateEventKind {
    case stateUpdate, elementAdded
}

// MARK: -

class StateUpdateEvent: StateEvent {
    init(_ state: ChatModel.State, comment: String? = nil) {
        self.state = state
        self.info = comment
    }

    let kind: UpdateEventKind = .stateUpdate
    let info: String?
    let state: ChatModel.State
}

class ElementUpdateEvent: ElementEvent {
    init(add text: String?, image: UIImage?, comment: String? = nil) {
        self.kind = .elementAdded
        self.text = text
        self.image = image
        self.info = comment
    }

    let kind: UpdateEventKind
    let text: String?
    let image: UIImage?
    let info: String?
}
