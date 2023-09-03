//
//  ChatModelEvent.swift
//  ChatAIT
//
//  Created by developer on 04.09.2023.
//

import Foundation

protocol ChatModelEvent {
    var info: String? { get }
}

protocol UpdateEvent: ChatModelEvent {
    var kind: UpdateEventKind { get }
}

protocol StateEvent: UpdateEvent {
    var state: ChatModel.State { get }
}

protocol IndexesUpdateEvent: UpdateEvent {
    var indexes: [Int] { get }
}

enum UpdateEventKind {
    case stateUpdate, elementAdded, elementUpdated
}

// MARK: -

class ElementUpdateEvent: IndexesUpdateEvent {
    let kind: UpdateEventKind
    let info: String? = nil
    let indexes: [Int]

    init(add indexes: [Int]) {
        self.kind = .elementAdded
        self.indexes = indexes
    }

    init(update indexes: [Int]) {
        self.kind = .elementUpdated
        self.indexes = indexes
    }
}

class StateUpdateEvent: StateEvent {
    init(_ state: ChatModel.State) {
        self.state = state
    }

    let kind: UpdateEventKind = .stateUpdate
    let info: String? = nil
    let state: ChatModel.State
}
