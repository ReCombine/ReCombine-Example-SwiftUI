//
//  ContentView.swift
//  ReCombine Scoreboard
//
//  Created by Crowson, John on 12/10/19.
//  Copyright © 2019 Crowson, John.
//  Licensed under Apache License 2.0
//

import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var viewModel = ScoreboardViewModel()
    
    var body: some View {
        VStack(alignment: .center, spacing: 50.0) {
            Text("ReCombine Scoreboard")
            HStack(alignment: .center, spacing: 35.0) {
                VStack(alignment: .center, spacing: 15.0) {
                    Text("Home")
                    Text(viewModel.homeScore)
                    Button(action: {
                        self.viewModel.homeScoreTapped()
                    }, label: {
                        Text("Score")
                    })
                }
                VStack(alignment: .center, spacing: 15.0) {
                    Text("Away")
                    Text(viewModel.awayScore)
                    Button(action: {
                        self.viewModel.awayScoreTapped()
                    }, label: {
                        Text("Score")
                    })
                }
            }
            Button(action: {
                self.viewModel.postScoreTapped()
            }, label: {
                Text("Post Score")
            })
        }.alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Scoreboard Posted Successfully"), message: Text("The current scoreboard will be reset."), dismissButton: .default(Text("Got it!")))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView()
    }
}
