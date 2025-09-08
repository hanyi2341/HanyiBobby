import SwiftUI

struct ContentView: View {
    @StateObject private var videoCapture = VideoCapture()
    @StateObject private var predictor = Predictor()
    
    var body: some View {
        ZStack {
            CameraPreview(session: videoCapture.captureSession)
                .ignoresSafeArea()
            
            BodyPoseOverlay(bodyPoints: predictor.bodyPoints)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Action Detected:")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(predictor.actionLabel)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(predictor.isDabbing ? .green : .white)
                        Text("Confidence: \(predictor.confidence, specifier: "%.1f")%")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    Button(action: videoCapture.flipCamera) {
                        Image(systemName: "camera.rotate")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                HStack {
                    VStack {
                        Text("\(predictor.dabbingCount)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Dabs Detected")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: predictor.isDabbing ? "figure.dance" : "figure.stand")
                            .font(.largeTitle)
                            .foregroundColor(predictor.isDabbing ? .green : .white)
                        Text(predictor.isDabbing ? "Dabbing!" : "Waiting...")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear {
            videoCapture.predictor = predictor
            videoCapture.checkPermission()
        }
        .alert("Camera Permission Required", isPresented: $videoCapture.showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable camera access in Settings to use this app.")
        }
    }
}
