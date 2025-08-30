//
//  AI_CameraView.swift
//

import SwiftUI
import AVFoundation
import CoreGraphics

struct AI_CameraView: View {
    @State private var videoCapture = VideoCapture()
    @State private var currentPose: Pose?
    @State private var poseNet: PoseNet?
    @State private var videoCaptureDelegate: AI_VideoCaptureDelegate?
    @State private var poseNetDelegate: AI_PoseNetDelegate?

    @Binding var overallPoints: Int

    var body: some View {
        ZStack {
            AI_CameraPreviewLayer(videoCapture: videoCapture)
                .cornerRadius(15)
                .shadow(radius: 5)

            if let pose = currentPose {
                AI_PoseOverlayView(pose: pose)
                    .cornerRadius(15)
            }
        }
        .onAppear {
            setupCamera()
        }
    }

    private func setupCamera() {
        // 1️⃣ Camera setup
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Camera setup error: \(error)")
            } else {
                videoCapture.startCapturing()
            }
        }

        // 2️⃣ Video delegate setup
        videoCaptureDelegate = AI_VideoCaptureDelegate { image in
            poseNet?.predict(image)
        }
        videoCapture.delegate = videoCaptureDelegate

        // 3️⃣ PoseNet setup
        do {
            poseNet = try PoseNet()
            guard let videoDelegate = videoCaptureDelegate else { return }
            poseNetDelegate = AI_PoseNetDelegate(videoDelegate: videoDelegate) { pose in
                self.currentPose = pose
                // Example scoring logic
                self.overallPoints += Int.random(in: 0...5)
            }
            poseNet?.delegate = poseNetDelegate
        } catch {
            print("PoseNet init error: \(error)")
        }
    }
}

// MARK: - Camera Preview Layer
struct AI_CameraPreviewLayer: UIViewRepresentable {
    let videoCapture: VideoCapture

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - Pose Overlay
struct AI_PoseOverlayView: View {
    let pose: Pose

    var body: some View {
        Canvas { context, size in
            // Draw joints
            for joint in pose.joints.values {
                if joint.isValid {
                    let circle = Path(ellipseIn: CGRect(
                        x: joint.position.x - 4,
                        y: joint.position.y - 4,
                        width: 8,
                        height: 8
                    ))
                    context.fill(circle, with: .color(.green))
                }
            }

            // Draw edges
            for edge in Pose.edges {
                let parentJoint = pose[edge.parent]
                let childJoint = pose[edge.child]
                if parentJoint.isValid && childJoint.isValid {
                    let path = Path { path in
                        path.move(to: parentJoint.position)
                        path.addLine(to: childJoint.position)
                    }
                    context.stroke(path, with: .color(.red), lineWidth: 3)
                }
            }
        }
    }
}

// MARK: - Delegates

class AI_VideoCaptureDelegate: VideoCaptureDelegate {
    private let onFrameCaptured: (CGImage) -> Void
    private var latestFrame: CGImage?

    init(onFrameCaptured: @escaping (CGImage) -> Void) {
        self.onFrameCaptured = onFrameCaptured
    }

    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame image: CGImage?) {
        guard let image = image else { return }
        self.latestFrame = image
        onFrameCaptured(image)
    }

    func getLatestFrame() -> CGImage? {
        return latestFrame
    }
}

class AI_PoseNetDelegate: PoseNetDelegate {
    private let onPoseDetected: (Pose) -> Void
    private let videoDelegate: AI_VideoCaptureDelegate

    init(videoDelegate: AI_VideoCaptureDelegate, onPoseDetected: @escaping (Pose) -> Void) {
        self.videoDelegate = videoDelegate
        self.onPoseDetected = onPoseDetected
    }

    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        // Use the latest captured frame directly
        guard let image = videoDelegate.getLatestFrame() else { return }
        let configuration = PoseBuilderConfiguration()
        let poseBuilder = PoseBuilder(output: predictions, configuration: configuration, inputImage: image)
        onPoseDetected(poseBuilder.pose)
    }
}
