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

let appStore = Store(reducer: Scoreboard.reducer, initialState: Scoreboard.State(home: 0, away: 0, apiStatus: .none), effects: [Scoreboard.postScore])

enum Scoreboard {
    
    // MARK: - State
    
    struct State: Equatable {
        // Current score state
        let home: Int
        let away: Int
        
        // Posting score to API status
        let apiStatus: ScoreAPIStatus
    }
    
    // MARK: - Memoized State Selectors
    
    static let getHomeScoreString = createSelector({ (state: State) in state.home }, transformation: { score in
        // Only runs transformation if state.home changes
        return String(score)
    })
    
    static let getAwayScoreString = createSelector({ (state: State) in state.away }, transformation: { score in
        // Only runs transformation if state.away changes
        return String(score)
    })
    
    // MARK: - State Selectors
    
    static let getAPIStatus = { (state: State) in state.apiStatus }
    
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
                return State(
                    home: state.home + 1,
                    away: state.away,
                    apiStatus: state.apiStatus
                )
            case _ as AwayScore:
                return State(
                    home: state.home,
                    away: state.away + 1,
                    apiStatus: state.apiStatus
                )
            case _ as ResetScore:
                return State(
                    home: 0,
                    away: 0,
                    apiStatus: state.apiStatus
                )
            case _ as PostScore:
                return State(
                    home: state.home,
                    away: state.away,
                    apiStatus: .posting
                )
            case _ as PostScoreSuccess:
                return State(
                    home: state.home,
                    away: state.away,
                    apiStatus: .none
                )
            case _ as PostScoreError:
                return State(
                    home: state.home,
                    away: state.away,
                    apiStatus: .error
                )
            default:
                return state
        }
    }
    
    // MARK: - Effects
    
    static let postScore = Effect(dispatch: true) { actions in
        actions
            .ofType(PostScore.self)
            .flatMap(getPostAPI)
            .receive(on: RunLoop.main)
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
