import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Overall Points: 23")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.yellow)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.orange, lineWidth: 2)
                )
                .padding(.horizontal)
            
            Text("Song Lyrics: ........")
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
}

#Preview {
    ContentView()
}
