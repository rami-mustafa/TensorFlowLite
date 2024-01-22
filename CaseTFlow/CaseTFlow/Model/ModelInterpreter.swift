//
//  ModelInterpreter.swift
//  CaseTFlow
//
//  Created by Rami Mustafa on 22.01.24.
//

 
import TensorFlowLite
import VideoToolbox
import CoreImage
import Accelerate

class ModelInterpreter {
    private var interpreter: Interpreter
    private var labels: [String]
    private let batchSize = 1
    private let inputChannels = 3
    private let inputWidth = 300
    private let inputHeight = 300

    init?() {
        guard let modelPath = Bundle.main.path(forResource: "ssd_mobilenet_v1", ofType: "tflite"),
              let labelsPath = Bundle.main.path(forResource: "labels", ofType: "txt") else {
            print("Model veya etiket dosyası bulunamadı.")
            return nil
        }

        do {
            interpreter = try Interpreter(modelPath: modelPath)
            try interpreter.allocateTensors()
        } catch {
            print("Interpreter oluşturulurken hata: \(error)")
            return nil
        }

        do {
            let labelsContent = try String(contentsOfFile: labelsPath, encoding: .utf8)
            labels = labelsContent.components(separatedBy: "\n")
        } catch {
            print("Etiket dosyası okunurken hata: \(error)")
            return nil
        }
    }

    func runModel(on pixelBuffer: CVPixelBuffer) -> [String] {
        guard let rgbData = rgbDataFromBuffer(pixelBuffer, byteCount: batchSize * inputWidth * inputHeight * inputChannels) else {
            print("Failed to convert the image buffer to RGB data.")
            return []
        }

        do {
            try interpreter.copy(rgbData, toInputAt: 0)
            try interpreter.invoke()

            let outputTensor = try interpreter.output(at: 0)
            return processOutput(outputTensor)
        } catch {
            print("Modeli çalıştırırken hata: \(error)")
            return []
        }
    }

    private func rgbDataFromBuffer(_ buffer: CVPixelBuffer, byteCount: Int) -> Data? {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        guard let sourceData = CVPixelBufferGetBaseAddress(buffer) else {
            return nil
        }

        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        let sourceBytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        let destinationChannelCount = 3
        let destinationBytesPerRow = destinationChannelCount * width

//        var sourceBuffer = vImage_Buffer(data: sourceData, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: sourceBytesPerRow)
        var sourceBuffer = vImage_Buffer(data: sourceData, height: UInt(height), width: UInt(width), rowBytes: sourceBytesPerRow)

        guard let destinationData = malloc(height * destinationBytesPerRow) else {
            print("Memory allocation error.")
            return nil
        }
        defer { free(destinationData) }

        var destinationBuffer = vImage_Buffer(data: destinationData, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: destinationBytesPerRow)

        let error = vImageConvert_BGRA8888toRGB888(&sourceBuffer, &destinationBuffer, 0)
        if error != kvImageNoError {
            print("Error in vImageConvert_BGRA8888toRGB888: \(error)")
            return nil
        }

        let data = Data(bytes: destinationBuffer.data, count: destinationBytesPerRow * height)
        return data
    }


    private func processOutput(_ outputTensor: Tensor) -> [String] {
        return outputTensor.data.withUnsafeBytes { rawPointer in
            guard let pointer = rawPointer.bindMemory(to: Float.self).baseAddress else {
                print("Failed to bind memory")
                return []
            }

            let outputSize = outputTensor.shape.dimensions.count / MemoryLayout<Float>.stride
            var results = [String]()
            for index in stride(from: 0, to: outputSize, by: 2) { // Örnek: her çift indeks konfidans değeri, her tek indeks etiket indeksi
                let confidence = pointer[index]
                if confidence > 0.5 { // Örnek eşik değeri
                    let labelIndex = Int(pointer[index + 1])
                    let label = labels[labelIndex]
                    results.append(label)
                }
            }
            return results
        }
    }



}
