//
//  ScoreAPIManager.swift
//  ReCombine Scoreboard
//
//  Created by Crowson, John on 12/10/19.
//  Copyright © 2019 Crowson, John.
//  Licensed under Apache License 2.0
//

import Combine
import Foundation

protocol ScoreAPIManager {
    func postScore(home: String, away: String) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure>
}

extension URLSession: ScoreAPIManager {
    func postScore(home: String, away: String) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure> {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        return dataTaskPublisher(for: urlRequest).eraseToAnyPublisher()
    }
}
