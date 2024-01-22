 
import UIKit
import AVFoundation
import VideoToolbox
import SnapKit
import TensorFlowLite

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var resultsLabel: UILabel!

    private var interpreter: Interpreter!
    private var labels: [String] = []

    let batchSize = 1
    let inputChannels = 3
    let inputWidth = 300
    let inputHeight = 300

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInterpreter()
        setupLabels()
        setupCameraSession()
        setupResultsLabel()
    }

    func setupInterpreter() {
        guard let modelPath = Bundle.main.path(forResource: "ssd_mobilenet_v1", ofType: "tflite") else {
            print("Model dosyası bulunamadı.")
            return
        }

        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter.allocateTensors()
        } catch let error {
            print("Interpreter oluşturulurken hata: \(error.localizedDescription)")
            return
        }
    }

    func setupLabels() {
        guard let labelsPath = Bundle.main.path(forResource: "labels", ofType: "txt") else {
            print("Etiket dosyası bulunamadı.")
            return
        }

        do {
            let labelsContent = try String(contentsOfFile: labelsPath, encoding: .utf8)
            labels = labelsContent.components(separatedBy: "\n")
        } catch {
            print("Etiket dosyası okunurken hata oluştu.")
        }
    }

    func setupCameraSession() {
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

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func setupResultsLabel() {
        resultsLabel = UILabel()
        resultsLabel.numberOfLines = 0
        resultsLabel.backgroundColor = .white
        resultsLabel.textColor = .black
        view.addSubview(resultsLabel)
        resultsLabel.frame = CGRect(x: 0, y: view.frame.size.height - 100, width: view.frame.size.width, height: 100)
        
        
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        runModel(pixelBuffer: pixelBuffer)
    }

    func runModel(pixelBuffer: CVPixelBuffer) {
        let scaledSize = CGSize(width: inputWidth, height: inputHeight)
        guard let thumbnailPixelBuffer = pixelBuffer.centerThumbnail(ofSize: scaledSize) else {
            return
        }

        do {
            let inputTensor = try interpreter.input(at: 0)

            guard let rgbData = rgbDataFromBuffer(
                thumbnailPixelBuffer,
                byteCount: batchSize * inputWidth * inputHeight * inputChannels,
                isModelQuantized: inputTensor.dataType == .uInt8
            ) else {
                print("Failed to convert the image buffer to RGB data.")
                return
            }

            try interpreter.copy(rgbData, toInputAt: 0)
            try interpreter.invoke()

            let outputTensor = try interpreter.output(at: 0)
            let results = processOutput(outputTensor)
            showResults(results)
        } catch let error {
            print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
        }
    }

    func processOutput(_ outputTensor: Tensor) -> [String] {
        let output: [Float]
        switch outputTensor.dataType {
        case .uInt8:
            guard let quantization = outputTensor.quantizationParameters else {
                print("No results returned because the quantization values for the output tensor are nil.")
                return []
            }
            let quantizedResults = [UInt8](outputTensor.data)
            output = quantizedResults.map {
                quantization.scale * Float(Int($0) - quantization.zeroPoint)
            }
        case .float32:
            output = outputTensor.data.withUnsafeBytes { (pointer) -> [Float32] in
                   let bufferPointer = pointer.bindMemory(to: Float32.self).baseAddress!
                   return [Float32](UnsafeBufferPointer(start: bufferPointer, count: outputTensor.data.count / MemoryLayout<Float32>.stride))
               }
        default:
            print("Output tensor data type \(outputTensor.dataType) is unsupported for this example app.")
            return []
        }

        let zippedResults = zip(labels.indices, output)
        let sortedResults = zippedResults.sorted { $0.1 > $1.1 }.prefix(1)

        return sortedResults.map { labels[$0.0] }
    }

    func showResults(_ results: [String]) {
        DispatchQueue.main.async {
            self.resultsLabel.text = results.joined(separator: "\n")
        }
    }

}



