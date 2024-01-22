//
//  CameraManager.swift
//  CaseTFlow
//
//  Created by Rami Mustafa on 22.01.24.
//

import AVFoundation

class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var delegate: CameraManagerDelegate?

    override init() {
        super.init()
        setupCameraSession()
    }

    private func setupCameraSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera) else {
            print("Kamera sorunları var.")
            return
        }

        captureSession.addInput(input)

        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): kCMPixelFormat_32BGRA]
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoDataOutput)
    }

    func startSession() {
        captureSession.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.didCapture(sampleBuffer: sampleBuffer)
        let croppedImage = cropToSquare(image: pixelBuffer, size: 300)

    }
}

protocol CameraManagerDelegate {
    func didCapture(sampleBuffer: CMSampleBuffer)
}
