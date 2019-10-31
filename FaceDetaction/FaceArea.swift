//
//  FaceArea.swift
//  FaceDetaction
//
//  Created by Haya Alhumaid on 30/10/19.
//  Copyright © 2019 Haya Alhumaid. All rights reserved.
//

import UIKit
import CoreImage

struct FaceArea {
    let trackingID: Int32
    let bounds: CGRect
    let hasSmile: Bool
    let leftEyeClosed: Bool
    let rightEyeClosed: Bool
    let mouthBounds: CGRect
    
    init (faceFeature: CIFaceFeature, applyingRatio ratio: CGFloat, hasSmile: Bool, leftEyeClosed: Bool, rightEyeClosed: Bool) {
        
        let bounds = CGRect(
            x: faceFeature.bounds.origin.y * ratio,
            y: faceFeature.bounds.origin.x * ratio,
            width: faceFeature.bounds.size.height * ratio,
            height: faceFeature.bounds.size.width * ratio
        )
        self.trackingID = faceFeature.trackingID
        self.bounds = bounds
        self.hasSmile = hasSmile
        self.leftEyeClosed = leftEyeClosed
        self.rightEyeClosed = rightEyeClosed
        
        let mouthBounds = CGRect(
            x: faceFeature.mouthPosition.y * ratio,
            y: faceFeature.mouthPosition.x * ratio,
            width: 50 * ratio,
            height: 50 * ratio
        )
        self.mouthBounds = mouthBounds
        
        let featureDetails = " has smile: \(self.hasSmile)\n has closed left eye: \(self.leftEyeClosed)\n has closed right eye: \(self.rightEyeClosed)"
        print("=====")
        print(featureDetails)
        print("=====")
    }
}

struct MouthArea {
    let trackingID: Int32
    let bounds: CGRect
    
    init (faceFeature: CIFaceFeature, applyingRatio ratio: CGFloat) {
        
        let bounds = CGRect(
            x: faceFeature.mouthPosition.y * ratio,
            y: faceFeature.mouthPosition.x * ratio,
            width: 50 * ratio,
            height: 50 * ratio
        )
        self.trackingID = faceFeature.trackingID
        self.bounds = bounds
    }
}

struct LeftEyeArea {
    let trackingID: Int32
    let bounds: CGRect
    
    init (faceFeature: CIFaceFeature, applyingRatio ratio: CGFloat) {
        
        let bounds = CGRect(
            x: faceFeature.leftEyePosition.y * ratio,
            y: faceFeature.leftEyePosition.x * ratio,
            width: 50 * ratio,
            height: 50 * ratio
        )
        self.trackingID = faceFeature.trackingID
        self.bounds = bounds
    }
}

struct RightEyeArea {
    let trackingID: Int32
    let bounds: CGRect
    
    init (faceFeature: CIFaceFeature, applyingRatio ratio: CGFloat) {
        
        let bounds = CGRect(
            x: faceFeature.rightEyePosition.y * ratio,
            y: faceFeature.rightEyePosition.x * ratio,
            width: 50 * ratio,
            height: 50 * ratio
        )
        self.trackingID = faceFeature.trackingID
        self.bounds = bounds
    }
}
