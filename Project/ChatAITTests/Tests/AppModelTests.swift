//
//  AppModelTests.swift
//  ChatAITTests
//
//  Created by developer on 27.11.2023.
//

import XCTest
import Combine

@testable import ChatAIT

class AppModelTests: XCTestCase {
    override func setUpWithError() throws {
        eventsQueue = DispatchQueue(label: "com.chatait.tests.eventQueue", qos: .utility)
        model = ChatModel()
    }

    override func tearDownWithError() throws {
        bag.removeAll()
        model = nil
        eventsQueue = nil
        currentExpectation = nil
    }

    func testStartStop() throws {
        XCTAssertEqual(model.state, .off, "Model should not be started yet")

        model.modelUpdateEvent.receive(on: eventsQueue).sink { [weak self] reason in
            guard let self = self else { return }

            switch reason {
            case .stateChanged(let state):
                XCTAssertEqual(self.model.state, state)
                print("\(#function): state = \(state)")
                self.currentExpectation?.fulfill()
            default:
                break
            }
        }.store(in: &bag)

        currentExpectation = XCTestExpectation(description: "Waiting for update event")
        model.start()
        XCTAssertEqual(model.state, .idle, "Model should be in idle state")
        wait(for: [currentExpectation!], timeout: 5.0)
        currentExpectation = nil

        currentExpectation = XCTestExpectation(description: "Waiting for update event")
        model.stop()
        XCTAssertEqual(model.state, .off, "Model should be in off state")
        wait(for: [currentExpectation!], timeout: 5.0)
        currentExpectation = nil
    }

    func test8BallAssistant() throws {
        XCTAssertGreaterThanOrEqual(AssistantsFactory.assistantIdentifiersMap.count, 1)

        let assistantId = "com.assistants.magic8BallConversation"
        XCTAssertNotNil(AssistantsFactory.assistantIdentifiersMap[assistantId])

        XCTAssertEqual(model.state, .off)

        model.start()
        XCTAssertEqual(model.state, .idle)

        model.startConversation(withAssistant: assistantId)
        XCTAssertEqual(model.state, .assisting)

        model.stopConversation()
        XCTAssertEqual(model.state, .idle)

        model.stop()
        XCTAssertEqual(model.state, .off)
    }

    func testPerformanceExample() throws {
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    var model: ChatModel!
    var bag = Set<AnyCancellable>()
    var eventsQueue: DispatchQueue!
    var currentExpectation: XCTestExpectation?

    static let assistanIDs = ["com.assistants.magic8BallConversation", "com.assistants.dragonConversation"]
}
