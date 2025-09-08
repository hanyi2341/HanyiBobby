import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
      
    }
}

struct BodyPoseOverlay: View {
    let bodyPoints: [CGPoint]
    
    var body: some View {
        Canvas { context, size in
            let scale = size.width / UIScreen.main.bounds.width
            
            for point in bodyPoints {
                let scaledPoint = CGPoint(
                    x: point.x * scale,
                    y: point.y * scale
                )
                
                let circle = Path(ellipseIn: CGRect(
                    x: scaledPoint.x - 5,
                    y: scaledPoint.y - 5,
                    width: 10,
                    height: 10
                ))
                
                context.fill(circle, with: .color(.yellow))
                context.stroke(circle, with: .color(.orange), lineWidth: 2)
            }
        }
    }
}
