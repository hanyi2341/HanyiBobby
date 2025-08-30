import SwiftUI

struct ContentView: View {
    @State private var overallPoints: Int = 0
    @State private var dances: [String] = ["Gangnam Style", "NDP Song"]
    @State private var cameraViewModel = CameraViewModel()
    @State private var poseViewModel = PoseEstimationViewModel()
    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraViewModel.session)
                .edgesIgnoringSafeArea(.all)
            
            PoseOverlayView(
                bodyParts: poseViewModel.detectedBodyParts,
                connections: poseViewModel.bodyConnections
            )
        }
        .task {
            await cameraViewModel.checkPermission()
            cameraViewModel.delegate = poseViewModel
        }
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Dances")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 5)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(dances, id: \.self) { dance in
                        HStack {
                            Text(dance)
                            Spacer()
                            Image(systemName: "play.circle")
                                .foregroundColor(.blue)
                        }
                        .padding(8)
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        
        
        VStack(alignment: .leading, spacing: 10) {
            Text("Leaderboard")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 5)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("High Score: 100")
                Text("High Score: 70")
            }
            .padding(8)
            .background(Color.orange.opacity(0.3))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity)
        
        
        Button {
            print("Search button tapped!")
        } label: {
            Text("Search")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 3)
        }
        .padding(.horizontal)
        
        Text("Overall Points: \(overallPoints)")
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
        
    }}
#Preview {
    ContentView()
}
