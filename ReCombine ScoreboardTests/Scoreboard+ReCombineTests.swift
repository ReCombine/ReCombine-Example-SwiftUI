//
//  Scoreboard+ReCombineTests.swift
//  ReCombine ScoreboardTests
//
//  Created by Crowson, John on 12/10/19.
//  Copyright © 2019 Crowson, John.
//  Licensed under Apache License 2.0
//

import Combine
import ReCombine
@testable import ReCombine_Scoreboard
import ReCombineTest
import XCTest

class Scoreboard_ReCombineTests: XCTestCase {
    
    let mockState = Scoreboard.State(home: 2, away: 1)
    var cancellable: AnyCancellable?
    
    // MARK: - Selectors
    
    func testGetHomeScoreString_StringifyHomeScore() {
        let result = Scoreboard.getHomeScoreString(mockState)
        XCTAssertEqual("2", result)
    }
    
    func testGetAwayScoreString_StringifyAwayScore() {
        let result = Scoreboard.getAwayScoreString(mockState)
        XCTAssertEqual("1", result)
    }
    
    // MARK: - Reducer
    
    func testReducer_HomeScoreAction_IncrementsHomeState() {
        let expect = Scoreboard.State(home: 3, away: 1)
        let result = Scoreboard.reducer(state: mockState, action: Scoreboard.HomeScore())
        XCTAssertEqual(expect, result)
    }
    
    func testReducer_AwayScoreAction_IncrementsAwayState() {
        let expect = Scoreboard.State(home: 2, away: 2)
        let result = Scoreboard.reducer(state: mockState, action: Scoreboard.AwayScore())
        XCTAssertEqual(expect, result)
    }
    
    func testReducer_ResetScoreAction_ResetsState() {
        let expect = Scoreboard.State(home: 0, away: 0)
        let result = Scoreboard.reducer(state: mockState, action: Scoreboard.ResetScore())
        XCTAssertEqual(expect, result)
    }
    
    // MARK: - PostScoreEffect
    
    func testPostScoreEffect_OnRequestSuccess_DispatchPostScoreSuccess() {
        Scoreboard.apiManager = MockSuccessScoreAPIManager()
        let actions = PassthroughSubject<Action, Never>()
        
        let expectationReceiveAction = expectation(description: "receiveAction")
        cancellable = Scoreboard.postScore.source(actions.eraseToAnyPublisher()).sink { resultAction in
            XCTAssertTrue(resultAction is Scoreboard.PostScoreSuccess)
            expectationReceiveAction.fulfill()
        }
        
        actions.send(Scoreboard.PostScore(home: "0", away: "0"))
        
        wait(for: [expectationReceiveAction], timeout: 10.0)
    }
    
    func testPostScoreEffect_OnRequestFailure_DispatchPostScoreSuccess() {
        Scoreboard.apiManager = MockFailureScoreAPIManager()
        let actions = PassthroughSubject<Action, Never>()
        
        let expectationReceiveAction = expectation(description: "receiveAction")
        cancellable = Scoreboard.postScore.source(actions.eraseToAnyPublisher()).sink { resultAction in
            XCTAssertTrue(resultAction is Scoreboard.PostScoreError)
            expectationReceiveAction.fulfill()
        }
        
        actions.send(Scoreboard.PostScore(home: "0", away: "0"))
        
        wait(for: [expectationReceiveAction], timeout: 10.0)
    }
}


class MockSuccessScoreAPIManager: ScoreAPIManager {
    func postScore(home: String, away: String) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure> {
        let output: URLSession.DataTaskPublisher.Output = (data: Data(), response: URLResponse())
        return Just(output).setFailureType(to: URLSession.DataTaskPublisher.Failure.self).eraseToAnyPublisher()
    }
}

class MockFailureScoreAPIManager: ScoreAPIManager {
    func postScore(home: String, away: String) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure> {
        return Fail(outputType: URLSession.DataTaskPublisher.Output.self, failure: URLSession.DataTaskPublisher.Failure(.badURL)).eraseToAnyPublisher()
    }
}
