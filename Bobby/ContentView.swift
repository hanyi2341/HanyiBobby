//
//  ContentView.swift
//  stick-figure
//
//  Created by YJ Soon on 1/8/25.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            StickMan()
                .stroke(lineWidth: 4)
                .foregroundColor(.black)

            // Add more EmojiViews to decorate your Bobby
           
            
            
            
            
            
            
            
            
            
            
            
            EmojiView(symbol: "✌️", size: 50, x: -60,  y: -60)
            EmojiView(symbol: "🎃", size: 50, x: 60,  y: -40)
            EmojiView(symbol: "👢", size: 40, x: 50,  y: 70)
            EmojiView(symbol: "🦶", size: 40, x: -50,  y: 80)
            
            EmojiView(symbol: "🩳", size: 70, x: 0,  y: 10)
            EmojiView(symbol: "🎽", size: 80, x: 0, y: -40)
            EmojiView(symbol: "🧣", size: 80, x: -5, y: -70)
            EmojiView(symbol: "🥸", size: 80, x: 0, y: -130)
            EmojiView(symbol: "🧢", size: 80, x: -10, y: -160)
           
        }
        .frame(width: 200, height: 320)
    }
}


/// Reusable emoji decorator
struct EmojiView: View {
    let symbol: String
    let size: CGFloat
    let x: CGFloat
    let y: CGFloat
    var body: some View {
        Text(symbol)
            .font(.system(size: size))
            .offset(x: x, y: y)
    }
}


#Preview {
    ContentView()
}
