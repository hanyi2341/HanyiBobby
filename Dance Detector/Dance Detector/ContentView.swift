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
        Text("Overall Points: (will be determined with another variable)")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.yellow)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.orange, lineWidth: 2)
            )
            .padding(.horizontal)
        
        Text("Song Lyrics: (will add something here later)")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.yellow)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.green, lineWidth: 2)
            )
            .padding(.horizontal)
            
        Spacer()
        Rectangle()
                    .fill(Color.blue)
                    .frame(width: 1, height: 1000)
        Spacer()
            }

        }

#Preview {
    ContentView()
}
