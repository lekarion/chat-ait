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
        XCTAssertNotNil(AssistantsFactory.assistantIdentifiersMap[AssistantsFactory.magic8BallConversationId])

        XCTAssertEqual(model.state, .off)

        var nextCommand: AppModelTestCommand?
        model.modelUpdateEvent.receive(on: eventsQueue).sink { [weak self] reason in
            guard let self = self else { return }

            switch reason {
            case .stateChanged(let state):
                print("\(#function): state = \(state)")
            case .commandReceived(let command):
                nextCommand = command.transform(with: self, to: AppModelTestCommand.self)
                self.currentExpectation?.fulfill()
            }
        }.store(in: &bag)

        currentExpectation = XCTestExpectation(description: "Waiting for welcome command")
        model.start()
        XCTAssertEqual(model.state, .idle)

        wait(for: [currentExpectation!], timeout: 5.0)
        XCTAssertNotNil(nextCommand)
        XCTAssertEqual(model.state, .idle)

        var thisCommand = nextCommand!
        nextCommand = nil

        let testMachine = Magic8BallFSM()
        var step = testMachine.processNext(command: thisCommand)
        XCTAssertNotNil(step)
        XCTAssertEqual(step!.0, .preStart)

        currentExpectation = XCTestExpectation(description: "Waiting for assistant selection response")
        step!.1("")

        wait(for: [currentExpectation!], timeout: 5.0)
        XCTAssertNotNil(nextCommand)
        XCTAssertEqual(model.state, .assisting)
        XCTAssertEqual(model.currentAssistantId, AssistantsFactory.magic8BallConversationId)

        thisCommand = nextCommand!
        nextCommand = nil

        step = testMachine.processNext(command: thisCommand)
        XCTAssertNotNil(step)
        XCTAssertEqual(step!.0, .start)

        currentExpectation = XCTestExpectation(description: "Waiting for the first assistant command")
        step!.1("")

        wait(for: [currentExpectation!], timeout: 5.0)
        XCTAssertNotNil(nextCommand)
        XCTAssertEqual(model.state, .assisting)

        thisCommand = nextCommand!
        nextCommand = nil

        step = testMachine.processNext(command: thisCommand)
        XCTAssertNotNil(step)
        XCTAssertEqual(step!.0, .ask)

        currentExpectation = XCTestExpectation(description: "Waiting for command response")
        step!.1("")

        wait(for: [currentExpectation!], timeout: 5.0)
        XCTAssertNotNil(nextCommand)
        XCTAssertEqual(model.state, .assisting)

        thisCommand = nextCommand!
        nextCommand = nil

        step = testMachine.processNext(command: thisCommand)
        XCTAssertNotNil(step)
        XCTAssertEqual(step!.0, .next)

        currentExpectation = XCTestExpectation(description: "Waiting for next action command")
        step!.1("")

        wait(for: [currentExpectation!], timeout: 5.0)
        XCTAssertNotNil(nextCommand)
        XCTAssertEqual(model.state, .assisting)

        thisCommand = nextCommand!
        nextCommand = nil

        step = testMachine.processNext(command: thisCommand)
        XCTAssertNotNil(step)
        XCTAssertEqual(step!.0, .stop)

        currentExpectation = XCTestExpectation(description: "Finish assistant")
        step!.1("")

        wait(for: [currentExpectation!], timeout: 5.0)
        XCTAssertNotNil(nextCommand)
        XCTAssertEqual(model.state, .idle)

        model.stop()
        XCTAssertEqual(model.state, .off)
    }

    var model: ChatModel!
    var bag = Set<AnyCancellable>()
    var eventsQueue: DispatchQueue!
    var currentExpectation: XCTestExpectation?
}

extension AppModelTests { // 8Ball final state machine
    class Magic8BallFSM {
        func processNext(command: AppModelTestCommand) -> (Step, (String) -> Void)? {
            switch step {
            case .unknown:
                let union = command as? AppModelTestCommandUnion
                XCTAssertNotNil(union)

                let action = union?.subitems.first { $0 is AppModelTestCommandAction } as? AppModelTestCommandAction
                XCTAssertNotNil(action)
                XCTAssertFalse(action!.actions.isEmpty)

                step = .preStart
                return (step, action!.actions[0].handler)
            case .preStart:
                let data = command as? AppModelTestCommandData
                XCTAssertNotNil(data)

                step = .start
                return (step, nothing)
            case .start:
                let union = command as? AppModelTestCommandUnion
                XCTAssertNotNil(union)

                let action = union?.subitems.first { $0 is AppModelTestCommandAction } as? AppModelTestCommandAction
                XCTAssertNotNil(action)
                XCTAssertFalse(action!.actions.isEmpty)

                step = .ask
                return (step, action!.actions[0].handler)
            case .ask:
                let data = command as? AppModelTestCommandData
                XCTAssertNotNil(data)

                step = .next
                return (step, nothing)
            case .next:
                let union = command as? AppModelTestCommandUnion
                XCTAssertNotNil(union)

                let action = union?.subitems.first { $0 is AppModelTestCommandAction } as? AppModelTestCommandAction
                XCTAssertNotNil(action)
                XCTAssertFalse(action!.actions.isEmpty)

                step = .stop
                return (step, action!.actions[1].handler)
            case .stop:
                XCTAssertTrue(false, "Should not be called")
                return nil
            }
        }

        private func nothing(_ id: String) {
        }

        enum Step {
            case unknown, preStart, start, ask, next, stop
        }

        private var step: Step = .unknown
    }
}
