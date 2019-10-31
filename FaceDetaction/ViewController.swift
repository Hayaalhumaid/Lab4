//
//  ViewController.swift
//  FaceDetaction
//
//  Created by Haya Alhumaid on 30/10/19.
//  Copyright © 2019 Haya Alhumaid. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage

class ViewController: UIViewController {

    fileprivate lazy var detector: CIDetector = {
        let context = CIContext()
        let options: [String : Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh,
            CIDetectorTracking: true
        ]
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: options)!
        return detector
    }()
    fileprivate var featureDetectorOptions = [String : Any]()
    fileprivate lazy var layersView: LayersView = {
        let view = LayersView(frame: self.view.frame)
        return view
    }()
     
    private lazy var device: AVCaptureDevice? = {
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        return device
    }()
    private lazy var deviceInput: AVCaptureDeviceInput? = {
        do {
            return try AVCaptureDeviceInput(device: self.device!)
        } catch {
            print("Failed to initialize AVCaptureDeviceInput." ); return nil
        }
    }()
    private lazy var videoDataOutput: AVCaptureVideoDataOutput = {
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: self.sampleBufferQueue)
        return videoDataOutput
    }()
    private lazy var session: AVCaptureSession? = {
        guard let deviceInput = self.deviceInput else { return nil }
        let session = AVCaptureSession()
        session.addInput(deviceInput)
        session.addOutput(self.videoDataOutput)
        return session
    }()
    private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer? = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session!)
        layer.frame = self.view.bounds
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    private lazy var sampleBufferQueue: DispatchQueue = {
        return DispatchQueue(label: "sample.queue")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setup()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] granted in
                guard let strongSelf = self else { return }
                guard granted else { print("You need to authorize camera access in this app."); return }
                
                strongSelf.setup()
            })
        default:
            print("You need to authorize camera access in this app."); break
        }
    }
    
    fileprivate func setup() {
        guard let session = session else { print("Failed to prepare session."); return }
        guard let videoPreviewLayer = videoPreviewLayer else { print("Failed to prepare videoPreviewLayer."); return }
        
        view.layer.addSublayer(videoPreviewLayer)
        view.addSubview(layersView)
        session.startRunning()
    }


}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cvImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: cvImageBuffer)
        let cvImageHeight = CGFloat(CVPixelBufferGetHeight(cvImageBuffer))
        var ratio = CGFloat()
        DispatchQueue.main.async {
            ratio = self.view.frame.width / cvImageHeight
        }
        featureDetectorOptions = [CIDetectorImageOrientation: exifOrientation(orientation: UIDevice.current.orientation), CIDetectorSmile: true, CIDetectorEyeBlink: true]

        let faceAreas = detector
            .features(in: ciImage, options: featureDetectorOptions)
            .compactMap { $0 as? CIFaceFeature }
            .map { FaceArea(faceFeature: $0, applyingRatio: ratio, hasSmile: $0.hasSmile, leftEyeClosed: $0.leftEyeClosed, rightEyeClosed: $0.rightEyeClosed) }
        
        let mouthAreas = detector
        .features(in: ciImage, options: featureDetectorOptions)
        .compactMap { $0 as? CIFaceFeature }
        .map { MouthArea(faceFeature: $0, applyingRatio: ratio) }
        
        let leftEyeAreas = detector
        .features(in: ciImage, options: featureDetectorOptions)
        .compactMap { $0 as? CIFaceFeature }
        .map { LeftEyeArea(faceFeature: $0, applyingRatio: ratio) }
        
        let rightEyeAreas = detector
        .features(in: ciImage, options: featureDetectorOptions)
        .compactMap { $0 as? CIFaceFeature }
        .map { RightEyeArea(faceFeature: $0, applyingRatio: ratio) }
        
        DispatchQueue.main.async {
            self.layersView.update(with: faceAreas)
            self.layersView.update(with: mouthAreas)
            self.layersView.update(with: leftEyeAreas)
            self.layersView.update(with: rightEyeAreas)
        }
    }
    
    func exifOrientation(orientation: UIDeviceOrientation) -> Int {
        switch orientation {
        case .portraitUpsideDown:
            return 8
        case .landscapeLeft:
            return 3
        case .landscapeRight:
            return 1
        default:
            return 6
        }
    }
}


