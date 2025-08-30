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
    @State private var poseSmoother = PoseSmoother()

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
        // Set up camera normally
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Camera setup error: \(error)")
            } else {
                videoCapture.startCapturing()
            }
        }

        videoCaptureDelegate = AI_VideoCaptureDelegate { image in
            poseNet?.predict(image)
        }
        videoCapture.delegate = videoCaptureDelegate

        do {
            poseNet = try PoseNet()
            guard let videoDelegate = videoCaptureDelegate else { return }
            poseNetDelegate = AI_PoseNetDelegate(videoDelegate: videoDelegate, smoother: poseSmoother) { pose, confidenceScore in
                self.currentPose = pose
                self.overallPoints += Int(confidenceScore * 10)
            }
            poseNet?.delegate = poseNetDelegate
        } catch {
            print("PoseNet init error: \(error)")
        }
    }

}

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

struct AI_PoseOverlayView: View {
    let pose: Pose
    let confidenceThreshold: CGFloat = 0.5

    var body: some View {
        Canvas { context, size in
           
            for joint in pose.joints.values where joint.isValid && joint.confidence > confidenceThreshold {
                let circle = Path(ellipseIn: CGRect(
                    x: joint.position.x - 4,
                    y: joint.position.y - 4,
                    width: 8,
                    height: 8
                ))
                context.fill(circle, with: .color(.green))
            }

            for edge in Pose.edges {
                let parentJoint = pose[edge.parent]
                let childJoint = pose[edge.child]
                if parentJoint.isValid && childJoint.isValid &&
                   parentJoint.confidence > confidenceThreshold && childJoint.confidence > confidenceThreshold {
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


class AI_VideoCaptureDelegate: VideoCaptureDelegate {
    private let onFrameCaptured: (CGImage) -> Void
    private var latestFrame: CGImage?

    // Throttle predictions to 5 FPS
    private var lastPredictionTime = Date()
    private let predictionInterval: TimeInterval = 0.2

    init(onFrameCaptured: @escaping (CGImage) -> Void) {
        self.onFrameCaptured = onFrameCaptured
    }

    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame image: CGImage?) {
        guard let image = image else { return }
        let now = Date()
        if now.timeIntervalSince(lastPredictionTime) >= predictionInterval {
            lastPredictionTime = now
            self.latestFrame = image
            onFrameCaptured(image)
        }
    }

    func getLatestFrame() -> CGImage? {
        return latestFrame
    }
}

class AI_PoseNetDelegate: PoseNetDelegate {
    private let onPoseDetected: (Pose, CGFloat) -> Void
    private let videoDelegate: AI_VideoCaptureDelegate
    private let smoother: PoseSmoother

    init(videoDelegate: AI_VideoCaptureDelegate, smoother: PoseSmoother, onPoseDetected: @escaping (Pose, CGFloat) -> Void) {
        self.videoDelegate = videoDelegate
        self.smoother = smoother
        self.onPoseDetected = onPoseDetected
    }

    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        guard let image = videoDelegate.getLatestFrame() else { return }
        let configuration = PoseBuilderConfiguration()
        let poseBuilder = PoseBuilder(output: predictions, configuration: configuration, inputImage: image)

        // Smooth pose
        let smoothedPose = smoother.smooth(current: poseBuilder.pose)

        // Average confidence score for scoring
        let validJoints = smoothedPose.joints.values.filter { $0.isValid }
        let averageConfidence = validJoints.isEmpty ? 0 : validJoints.map { $0.confidence }.reduce(0, +) / CGFloat(validJoints.count)

        onPoseDetected(smoothedPose, averageConfidence)
    }
}

// Smooth poses across frames to reduce jitter
class PoseSmoother {
    private var previousPose: Pose?

    func smooth(current: Pose) -> Pose {
        guard let prev = previousPose else {
            previousPose = current
            return current
        }

        let alpha: CGFloat = 0.7
        var smoothedJoints: [Joint.Name: Joint] = [:]

        for (name, joint) in current.joints {
            if let prevJoint = prev.joints[name], joint.isValid && prevJoint.isValid {
                let x = alpha * joint.position.x + (1 - alpha) * prevJoint.position.x
                let y = alpha * joint.position.y + (1 - alpha) * prevJoint.position.y
                let confidence = alpha * joint.confidence + (1 - alpha) * prevJoint.confidence
                smoothedJoints[name] = Joint(name: name, position: CGPoint(x: x, y: y), confidence: confidence)
            } else {
                smoothedJoints[name] = joint
            }
        }

        let smoothedPose = Pose(joints: smoothedJoints)
        previousPose = smoothedPose
        return smoothedPose
    }
}

