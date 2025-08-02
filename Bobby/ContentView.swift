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
            
            
            EmojiView(symbol: "🎽", size: 120, x: 0, y: -30)
            EmojiView(symbol: "🧣", size: 80, x: -5, y: -70)
            EmojiView(symbol: "🥸", size: 80, x: 0, y: -130)
            EmojiView(symbol: "🧢", size: 80, x: -10, y: -160)
            EmojiView(symbol: "", size: 0, x: 0,  y: 0)
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
