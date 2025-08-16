//
//  ContentView.swift
//  Dance Detector
//
//  Created by Hanyi on 16/8/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            HStack {
                VStack {
                    HStack {
                        Text("Recent Dances")
                            .font(.largeTitle)
                            .scaledToFit()
                        
                    }
                    .padding()
                    HStack {
                        Text("Gangnam Style")
                        Image(systemName: "play.circle")
                    }
                    HStack {
                        Button {
                            print("NDP song!")
                        } label: {
                            Text("NDP Song")
                            Image(systemName: "play.circle")
                        }
                    }
                }
                    .padding()
                    VStack {
                        HStack {
                            Text("Leaderboard")
                                .font(.largeTitle)
                        }
                        .padding()
                        HStack {
                            Text("High Score: 100")
                        }
                        HStack {
                            Text("High Score: 70")
                        }
                    }
                }
            }
            
                Button {
                    print("Song?")
                } label: {
                    Text("Search")
                }
                .padding()
                .clipShape(.rect(cornerRadius: 10))
                .shadow(
                    color: .white.opacity(0.3),
                    radius: 10,
                    x: 0.0,
                    y: 0.0
                )
                .buttonStyle(.borderedProminent)
            }

        }
    

