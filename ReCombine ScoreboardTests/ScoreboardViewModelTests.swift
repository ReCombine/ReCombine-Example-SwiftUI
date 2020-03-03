//
//  ScoreboardViewModelTests.swift
//  ReCombine ScoreboardTests
//
//  Created by Crowson, John on 12/10/19.
//  Copyright © 2019 Crowson, John.
//  Licensed under Apache License 2.0
//

import Combine
@testable import ReCombine_Scoreboard
import ReCombineTest
import XCTest

class ScoreboardViewModelTests: XCTestCase {
    var mockStore: MockStore<Scoreboard.State>!
    var vm: ScoreboardViewModel!
    var cancellableSet: Set<AnyCancellable> = []

    override func setUp() {
        mockStore = MockStore(state: Scoreboard.State(home: 0, away: 0, apiStatus: .none))
        store = mockStore // override global store, used by view model.
        vm = ScoreboardViewModel()
    }

    override func tearDown() {
        cancellableSet = []
    }
    
    // MARK: - Property bindings
    
    func testPropertyBindings() {
        let expectationReceiveHomeScore = expectation(description: "receiveHomeScore")
        vm.$homeScore.sink { score in
            XCTAssertEqual("0", score)
            expectationReceiveHomeScore.fulfill()
        }.store(in: &cancellableSet)
        
        let expectationReceiveAwayScore = expectation(description: "receiveAwayScore")
        vm.$awayScore.sink { score in
            XCTAssertEqual("0", score)
            expectationReceiveAwayScore.fulfill()
        }.store(in: &cancellableSet)
        
        let expectationReceiveAPIStatus = expectation(description: "receiveAPIStatus")
        vm.$apiStatus.sink { apiStatus in
            XCTAssertEqual(.none, apiStatus)
            expectationReceiveAPIStatus.fulfill()
        }.store(in: &cancellableSet)
                
        wait(for: [expectationReceiveHomeScore, expectationReceiveAwayScore, expectationReceiveAPIStatus], timeout: 10.0)
    }
    
    // MARK: - showAlert Effect
    
    func testShowAlert_UpdatesShowAlert_OnPostScoreSuccess() {
        let expectationReceiveValues = expectation(description: "receiveValue")
        vm.$showAPISuccessAlert.collect(2).sink { showAlertValues in
            guard let firstAlertValue = showAlertValues.first,
                let secondAlertValue = showAlertValues.last else { return XCTFail() }
            XCTAssertFalse(firstAlertValue)
            XCTAssertTrue(secondAlertValue)
            expectationReceiveValues.fulfill()
        }.store(in: &cancellableSet)
        
        let expectationReceiveActions = expectation(description: "receiveAction")
        mockStore.dispatchedActions.collect(2).sink { actions in
            guard let firstAction = actions.first,
                let secondAction = actions.last else { return XCTFail() }
            XCTAssertTrue(firstAction is Scoreboard.PostScoreSuccess)
            XCTAssertTrue(secondAction is Scoreboard.ResetScore)
            expectationReceiveActions.fulfill()
        }.store(in: &cancellableSet)
        
        mockStore.dispatch(action: Scoreboard.PostScoreSuccess())
        
        wait(for: [expectationReceiveValues, expectationReceiveActions], timeout: 10.0)
    }
    
    // MARK: - Action dispatching functions

    func testHomeScoreTapped_DispatchesHomeScoreAction() {
        let expectationReceiveAction = expectation(description: "receiveAction")
        mockStore.dispatchedActions.sink { action in
            XCTAssertTrue(action is Scoreboard.HomeScore)
            expectationReceiveAction.fulfill()
        }.store(in: &cancellableSet)
        
        vm.homeScoreTapped()
        
        wait(for: [expectationReceiveAction], timeout: 10.0)
    }
    
    func testAwayScoreTapped_DispatchesAwayScoreAction() {
        let expectationReceiveAction = expectation(description: "receiveAction")
        mockStore.dispatchedActions.sink { action in
            XCTAssertTrue(action is Scoreboard.AwayScore)
            expectationReceiveAction.fulfill()
        }.store(in: &cancellableSet)
        
        vm.awayScoreTapped()

        wait(for: [expectationReceiveAction], timeout: 10.0)
    }
    
    func testPostScoreTapped_DispatchesPostScoreAction() {
        let expectationReceiveAction = expectation(description: "receiveAction")
        mockStore.dispatchedActions.sink { action in
            XCTAssertTrue(action is Scoreboard.PostScore)
            expectationReceiveAction.fulfill()
        }.store(in: &cancellableSet)
        
        vm.postScoreTapped()
        
        wait(for: [expectationReceiveAction], timeout: 10.0)
    }
}
