import Foundation
import Vision

enum PredictorError: Error {
    case failedToCreateMultiArray
    case modelNotLoaded
    case invalidObservation
}

struct AppConstants {
    static let predictionWindowSize = 60
    static let actionCooldownDuration: TimeInterval = 2.0
    static let dabbingConfidenceThreshold: Double = 50.0
    static let jointConfidenceThreshold: Float = 0.5
}
