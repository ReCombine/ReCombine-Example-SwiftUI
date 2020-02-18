//
//  ActivityIndicator.swift
//  ReCombine Scoreboard
//
//  Created by Kristin on 2/17/20.
//  Copyright © 2020 JohnCrowson. All rights reserved.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView()
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
}
