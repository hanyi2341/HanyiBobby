import SwiftUI
import Vision
import CoreML
import AVFoundation

class Predictor: ObservableObject {
    @Published var bodyPoints: [CGPoint] = []
    @Published var actionLabel: String = "None"
    @Published var confidence: Double = 0.0
    @Published var isDabbing: Bool = false
    @Published var dabbingCount: Int = 0
    
    private let predictionWindowSize = 60
    private var posesWindow: [VNHumanBodyPoseObservation] = []
    private var lastActionTime: Date = Date()
    private let actionCooldown: TimeInterval = 2.0
    
    private lazy var actionClassifier: YoutubeDabbingClassifier_2? = {
        do {
            let config = MLModelConfiguration()
            return try YoutubeDabbingClassifier_2(configuration: config)
        } catch {
            return nil
        }
    }()
    
    func processFrame(sampleBuffer: CMSampleBuffer) {
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up)
        let request = VNDetectHumanBodyPoseRequest { [weak self] request, error in
            guard let observations = request.results as? [VNHumanBodyPoseObservation],
                  let observation = observations.first else { return }
            
            self?.processObservation(observation)
        }
        
        try? requestHandler.perform([request])
    }
    
    private func processObservation(_ observation: VNHumanBodyPoseObservation) {
        storeObservation(observation)
        
        DispatchQueue.main.async { [weak self] in
            self?.bodyPoints = self?.extractBodyPoints(from: observation) ?? []
        }
        
        if posesWindow.count == predictionWindowSize {
            classifyAction()
        }
    }
    
    private func storeObservation(_ observation: VNHumanBodyPoseObservation) {
        posesWindow.append(observation)
        if posesWindow.count > predictionWindowSize {
            posesWindow.removeFirst()
        }
    }
    
    private func extractBodyPoints(from observation: VNHumanBodyPoseObservation) -> [CGPoint] {
        let joints: [VNHumanBodyPoseObservation.JointName] = [
            .nose, .leftEye, .rightEye, .leftEar, .rightEar,
            .leftShoulder, .rightShoulder, .leftElbow, .rightElbow,
            .leftWrist, .rightWrist, .leftHip, .rightHip,
            .leftKnee, .rightKnee, .leftAnkle, .rightAnkle
        ]
        
        var points: [CGPoint] = []
        let screenSize = UIScreen.main.bounds.size
        
        for joint in joints {
            if let point = try? observation.recognizedPoint(joint),
               point.confidence > 0.5 {
                let convertedPoint = CGPoint(
                    x: point.location.x * screenSize.width,
                    y: (1 - point.location.y) * screenSize.height
                )
                points.append(convertedPoint)
            }
        }
        
        return points
    }
    
    private func classifyAction() {
        guard let model = actionClassifier else { return }
        
        do {
            let input = try prepareInput(from: posesWindow)
            let prediction = try model.prediction(poses: input)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.actionLabel = prediction.label
                self.confidence = (prediction.labelProbabilities[prediction.label] ?? 0.0) * 100.0
                
                let newIsDabbing = prediction.label == "dabbing" && self.confidence > 50.0
                
                if newIsDabbing && !self.isDabbing {
                    let now = Date()
                    if now.timeIntervalSince(self.lastActionTime) > self.actionCooldown {
                        self.dabbingCount += 1
                        self.lastActionTime = now
                        self.playSound()
                    }
                }
                
                self.isDabbing = newIsDabbing
            }
        } catch {
            // Silent fail for classification errors
        }
    }
    
    private func prepareInput(from observations: [VNHumanBodyPoseObservation]) throws -> MLMultiArray {
        let shape = [60, 3, 18] as [NSNumber]
        
        guard let multiArray = try? MLMultiArray(shape: shape, dataType: .double) else {
            throw PredictorError.failedToCreateMultiArray
        }
        
        for i in 0..<multiArray.count {
            multiArray[i] = 0.0
        }
        
        for frameIndex in 0..<60 {
            let obsIndex = frameIndex < observations.count ? frameIndex : observations.count - 1
            let observation = observations[obsIndex]
            
            var neckPoint: CGPoint?
            var neckConfidence: Float = 0.0
            
            if let leftShoulder = try? observation.recognizedPoint(.leftShoulder),
               let rightShoulder = try? observation.recognizedPoint(.rightShoulder),
               leftShoulder.confidence > 0.1 && rightShoulder.confidence > 0.1 {
                neckPoint = CGPoint(
                    x: (leftShoulder.location.x + rightShoulder.location.x) / 2,
                    y: (leftShoulder.location.y + rightShoulder.location.y) / 2
                )
                neckConfidence = min(leftShoulder.confidence, rightShoulder.confidence)
            }
            
            let joints: [(VNHumanBodyPoseObservation.JointName?, Int, CGPoint?, Float?)] = [
                (.nose, 0, nil, nil),
                (nil, 1, neckPoint, neckConfidence),
                (.rightShoulder, 2, nil, nil),
                (.rightElbow, 3, nil, nil),
                (.rightWrist, 4, nil, nil),
                (.leftShoulder, 5, nil, nil),
                (.leftElbow, 6, nil, nil),
                (.leftWrist, 7, nil, nil),
                (.rightHip, 8, nil, nil),
                (.rightKnee, 9, nil, nil),
                (.rightAnkle, 10, nil, nil),
                (.leftHip, 11, nil, nil),
                (.leftKnee, 12, nil, nil),
                (.leftAnkle, 13, nil, nil),
                (.rightEye, 14, nil, nil),
                (.leftEye, 15, nil, nil),
                (.rightEar, 16, nil, nil),
                (.leftEar, 17, nil, nil)
            ]
            
            for (joint, jointIndex, overridePoint, overrideConfidence) in joints {
                if let overridePoint = overridePoint, let overrideConfidence = overrideConfidence {
                    multiArray[[frameIndex, 0, jointIndex] as [NSNumber]] = NSNumber(value: overridePoint.x)
                    multiArray[[frameIndex, 1, jointIndex] as [NSNumber]] = NSNumber(value: overridePoint.y)
                    multiArray[[frameIndex, 2, jointIndex] as [NSNumber]] = NSNumber(value: overrideConfidence)
                } else if let joint = joint,
                          let point = try? observation.recognizedPoint(joint) {
                    multiArray[[frameIndex, 0, jointIndex] as [NSNumber]] = NSNumber(value: point.location.x)
                    multiArray[[frameIndex, 1, jointIndex] as [NSNumber]] = NSNumber(value: point.location.y)
                    multiArray[[frameIndex, 2, jointIndex] as [NSNumber]] = NSNumber(value: point.confidence)
                }
            }
        }
        
        return multiArray
    }
    
    private func playSound() {
        if let soundURL = Bundle.main.url(forResource: "Ding", withExtension: "mp3"),
           let player = try? AVAudioPlayer(contentsOf: soundURL) {
            player.play()
        } else {
            AudioServicesPlaySystemSound(1103)
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
}

