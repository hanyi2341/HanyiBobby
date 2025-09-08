import SwiftUI
import AVFoundation
import Combine

class VideoCapture: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var showPermissionAlert = false
    @Published var isUsingFrontCamera = false
    
    let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInitiated)
    private var currentInput: AVCaptureDeviceInput?
    
    weak var predictor: Predictor?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.startSession()
                } else {
                    DispatchQueue.main.async {
                        self?.showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async { [weak self] in
                self?.showPermissionAlert = true
            }
        default:
            break
        }
    }
    
    private func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else { return }
        
        currentInput = videoInput
        captureSession.addInput(videoInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        if let connection = videoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
            if isUsingFrontCamera {
                connection.isVideoMirrored = true
            }
        }
        
        captureSession.commitConfiguration()
    }
    
    func flipCamera() {
        captureSession.beginConfiguration()
        
        if let currentInput = currentInput {
            captureSession.removeInput(currentInput)
        }
        
        isUsingFrontCamera.toggle()
        let position: AVCaptureDevice.Position = isUsingFrontCamera ? .front : .back
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            isUsingFrontCamera.toggle()
            if let currentInput = currentInput {
                captureSession.addInput(currentInput)
            }
            captureSession.commitConfiguration()
            return
        }
        
        currentInput = videoInput
        captureSession.addInput(videoInput)
        
        if let connection = videoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
            connection.isVideoMirrored = isUsingFrontCamera
        }
        
        captureSession.commitConfiguration()
    }
    
    private func startSession() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        predictor?.processFrame(sampleBuffer: sampleBuffer)
    }
}
