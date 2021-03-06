//
//  ContentViewModel.swift
//  ReCombine Scoreboard
//
//  Created by Crowson, John on 12/10/19.
//  Copyright © 2019 Crowson, John.
//  Licensed under Apache License 2.0
//

import Combine
import ReCombine
import SwiftUI

class ScoreboardViewModel: ObservableObject {
    @Published var homeScore = ""
    @Published var awayScore = ""
    @Published var apiStatus: ScoreAPIStatus = .none
    @Published var showAPISuccessAlert = false
    private var cancellableSet: Set<AnyCancellable> = []
    
    init() {
        // Bind selectors
        store.select(Scoreboard.getHomeScoreString).assign(to: \.homeScore, on: self).store(in: &cancellableSet)
        store.select(Scoreboard.getAwayScoreString).assign(to: \.awayScore, on: self).store(in: &cancellableSet)
        store.select(Scoreboard.getAPIStatus).assign(to: \.apiStatus, on: self).store(in: &cancellableSet)
        
        // Register PostScoreSuccess Effect
        let showAlert = Effect(dispatch: true) { actions in
            actions.ofType(Scoreboard.PostScoreSuccess.self)
                .receive(on: RunLoop.main)
                .handleEvents(receiveOutput: { [weak self] _ in
                    self?.showAPISuccessAlert = true
                })
                .map { _ in Scoreboard.ResetScore() }
                .eraseActionType()
                .eraseToAnyPublisher()
        }
        store.register(showAlert).store(in: &cancellableSet)
    }
    
    func homeScoreTapped() {
        store.dispatch(action: Scoreboard.HomeScore())        
    }
    
    func awayScoreTapped() {
        store.dispatch(action: Scoreboard.AwayScore())
    }
    
    func postScoreTapped() {
        store.dispatch(action: Scoreboard.PostScore(home: homeScore, away: awayScore))
    }
}
