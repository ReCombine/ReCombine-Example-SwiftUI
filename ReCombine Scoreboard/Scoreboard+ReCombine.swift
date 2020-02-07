//
//  Scoreboard+ReCombine.swift
//  ReCombine Scoreboard
//
//  Created by Crowson, John on 12/10/19.
//  Copyright © 2019 Crowson, John.
//  Licensed under Apache License 2.0
//

import Combine
import Foundation
import ReCombine

// MARK: - Store

let appStore = Store(reducer: Scoreboard.reducer, initialState: Scoreboard.State(), effects: [Scoreboard.postScore])

enum Scoreboard {
    
    // MARK: - State
    
    struct State: Equatable {
        var home = 0
        var away = 0
    }
    
    // MARK: - Memoized State Selectors
    
    static let getHomeScoreString = createSelector({ (state: State) in state.home }, transformation: { score in
        // Only runs if state.home changes
        return String(score)
    })
    
    static let getAwayScoreString = createSelector({ (state: State) in state.away }, transformation: { score in
        // Only runs if state.away changes
        return String(score)
    })
    
    // MARK: - Actions
    
    struct HomeScore: Action {}
    struct AwayScore: Action {}
    struct ResetScore: Action {}
    struct PostScore: Action {
        var home: String
        var away: String
    }
    struct PostScoreSuccess: Action {}
    struct PostScoreError: Action {}
    
    // MARK: - Reducers
    
    static func reducer(state: State, action: Action) -> State {
        switch action {
            case _ as HomeScore:
                return State(home: state.home + 1, away: state.away)
            case _ as AwayScore:
                return State(home: state.home, away: state.away + 1)
            case _ as ResetScore:
                return State(home: 0, away: 0)
            default:
                return state
        }
    }
    
    // MARK: - Effects
    
    static let postScore = Effect(dispatch: true) { actions in
        actions
            .ofType(PostScore.self)
            .flatMap(getPostAPI)
            .eraseToAnyPublisher()
    }
    
    // MARK: - API Calls
    
    static var apiManager: ScoreAPIManager = URLSession.shared

    static func getPostAPI(action: PostScore) -> AnyPublisher<Action, Never> {
        return apiManager.postScore(home: action.home, away: action.away)
            .map({ _ in PostScoreSuccess() })
            .replaceError(with: PostScoreError())
            .eraseToAnyPublisher()
    }
}
