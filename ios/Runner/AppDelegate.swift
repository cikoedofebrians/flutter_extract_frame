import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let imageChannel = FlutterMethodChannel(name: "imageChannel", binaryMessenger: controller.binaryMessenger)
        imageChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let args = call.arguments as? [String: Any],
                  let imageData = args["image"] as? FlutterStandardTypedData,
                  let fps = args["fps"] as? Int,
                  let width = args["width"] as? Int,
                  let height = args["height"] as? Int,
                  let duration = args["duration"] as? Double else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                return
            }
            
            if call.method == "processVideo" {
                self.convertImagesToMP4(from: imageData.data, fps: fps, width: width, height: height, duration: duration) { videoPath in
                    result(videoPath)
                }
            } else if call.method == "processImage" {
                self.generateFrames(imageData: imageData.data, fps: fps, width: width, height: height, duration: duration) { filePaths in
                    result(filePaths)
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        let deviceChannel = FlutterMethodChannel(name: "deviceChannel", binaryMessenger: controller.binaryMessenger)
        
        deviceChannel.setMethodCallHandler {(call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "deviceInfo" {
                result(self.getDeviceInfo())
            }
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    private func getDeviceInfo() -> [String: String] {
        let device = UIDevice.current
        let systemVersion = device.systemVersion
        let deviceName = device.name
        
        return ["systemVersion": systemVersion, "deviceName": deviceName]
    }
    
    private func convertImagesToMP4(from imageData: Data, fps: Int, width: Int, height: Int, duration: Double, completion: @escaping (String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = UIImage(data: imageData) else {
                completion(nil)
                return
            }
            
            let totalFrames = Int(duration * Double(fps))
            let tempDir = NSTemporaryDirectory()
            let videoOutputURL = URL(fileURLWithPath: tempDir).appendingPathComponent("output.mp4")
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: videoOutputURL.path) {
                do {
                    try fileManager.removeItem(at: videoOutputURL)
                } catch {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
            }
            
            do {
                let writer = try AVAssetWriter(outputURL: videoOutputURL, fileType: .mp4)
                let settings: [String: Any] = [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: width,
                    AVVideoHeightKey: height
                ]
                let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
                let sourcePixelBufferAttributes: [String: Any] = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                    kCVPixelBufferWidthKey as String: width,
                    kCVPixelBufferHeightKey as String: height
                ]
                let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
                
                writer.add(writerInput)
                writer.startWriting()
                writer.startSession(atSourceTime: .zero)
                
                let frameDuration = CMTimeMake(value: 1, timescale: Int32(fps)) // Each frame duration
                
                var frameCount: Int64 = 0
                for _ in 0..<totalFrames {
                    let scaleFactor = 1.0 - (0.05 * Double(frameCount) / Double(fps))
                    let scaledSize = CGSize(width: Double(width) * scaleFactor, height: Double(height) * scaleFactor)
                    let origin = CGPoint(x: (image.size.width - scaledSize.width) / 2, y: (image.size.height - scaledSize.height) / 2)
                    let cropRect = CGRect(origin: origin, size: scaledSize)
                    
                    if let cgImage = image.cgImage?.cropping(to: cropRect),
                       let resizedImage = UIImage(cgImage: cgImage).resized(toWidth: CGFloat(width), toHeight: CGFloat(height)),
                       let pixelBuffer = resizedImage.pixelBuffer(width: width, height: height) {
                        
                        while !writerInput.isReadyForMoreMediaData {
                            Thread.sleep(forTimeInterval: 0.1)
                        }
                        adaptor.append(pixelBuffer, withPresentationTime: CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))) // Append frame with correct timing
                        frameCount += 1
                    }
                }
                
                writerInput.markAsFinished()
                writer.finishWriting {
                    DispatchQueue.main.async {
                        completion(videoOutputURL.path)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    
    
    private func generateFrames(imageData: Data, fps: Int, width: Int, height: Int, duration: Double, completion: @escaping ([String]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = UIImage(data: imageData) else {
                completion([])
                return
            }
            
            let totalFrames = Int(duration * Double(fps))
            var filePaths: [String] = []
            let tempDir = NSTemporaryDirectory()
            
            for i in 0..<totalFrames {
                print(i)
                let scaleFactor = 1.0 - (0.05 * Double(i) / Double(fps))
                let scaledSize = CGSize(width: Double(width) * scaleFactor, height: Double(height) * scaleFactor)
                let origin = CGPoint(x: (image.size.width - scaledSize.width) / 2, y: (image.size.height - scaledSize.height) / 2)
                let cropRect = CGRect(origin: origin, size: scaledSize)
                
                if let cgImage = image.cgImage?.cropping(to: cropRect),
                   let resizedImage = UIImage(cgImage: cgImage).resized(toWidth: CGFloat(width), toHeight: CGFloat(height)),
                   let resizedImageData = resizedImage.jpegData(compressionQuality: 1.0) {
                    
                    let filePath = tempDir + "/frame_\(i).jpg"
                    let fileUrl = URL(fileURLWithPath: filePath)
                    
                    if FileManager.default.fileExists(atPath: filePath) {
                        try? FileManager.default.removeItem(at: fileUrl)
                    }
                    
                    
                    try? resizedImageData.write(to: fileUrl)
                    filePaths.append(filePath)
                }
            }
            
            DispatchQueue.main.async {
                completion(filePaths)
            }
        }
    }
    
}



extension UIImage {
    func resized(toWidth width: CGFloat, toHeight height: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0.0)
        draw(in: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attributes as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()
        
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        
        return buffer
    }
}
