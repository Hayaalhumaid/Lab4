//
//  LayersView.swift
//  FaceDetaction
//
//  Created by Haya Alhumaid on 30/10/19.
//  Copyright © 2019 Haya Alhumaid. All rights reserved.
//

import UIKit

struct FaceLayer {
    let layer: CAShapeLayer
    let area: FaceArea
}

struct MouthLayer {
    let layer: CAShapeLayer
    let area: MouthArea
}

struct LeftEyeLayer {
    let layer: CAShapeLayer
    let area: LeftEyeArea
}

struct RightEyeLayer {
    let layer: CAShapeLayer
    let area: RightEyeArea
}

final class LayersView: UIView {
    private let layerColor = UIColor(red: 0.78, green: 0.13, blue: 0.16, alpha: 0.5)
    private var drawnFaceLayers = [FaceLayer]()
    private var drawnMouthLayers = [MouthLayer]()
    private var drawnLeftEyeLayers = [LeftEyeLayer]()
    private var drawnRightEyeLayers = [RightEyeLayer]()
       
   
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //face
    func update(with areas: [FaceArea]) {
        let drawnAreas = drawnFaceLayers.map { $0.area }
        let drawnTrackingIDs: Set<Int32> = Set(drawnAreas.map { $0.trackingID })
        let newTrackingIDs: Set<Int32> = Set(areas.map { $0.trackingID })

        let trackingIDsToBeAdded: Set<Int32> = newTrackingIDs.subtracting(drawnTrackingIDs)
        let trackingIDsToBeMoved: Set<Int32> = drawnTrackingIDs.intersection(newTrackingIDs)
        let trackingIDsToBeRemoved: Set<Int32> = drawnTrackingIDs.subtracting(newTrackingIDs)
        
        let areasToBeAdded: [FaceArea] = trackingIDsToBeAdded.compactMap { trackingID in
            areas.first { $0.trackingID == trackingID }
        }
        let areasToBeMoved: [FaceArea] = trackingIDsToBeMoved.compactMap { trackingID in
            areas.first { $0.trackingID == trackingID }
        }

        drawCircles(of: areasToBeAdded)
        moveCircles(of: areasToBeMoved)
        removeCircles(of: Array(trackingIDsToBeRemoved))
    }
    
    //mouth
    func update(with areas: [MouthArea]) {
        let drawnAreas = drawnMouthLayers.map { $0.area }
        let drawnTrackingIDs: Set<Int32> = Set(drawnAreas.map { $0.trackingID })
        let newTrackingIDs: Set<Int32> = Set(areas.map { $0.trackingID })

        let trackingIDsToBeAdded: Set<Int32> = newTrackingIDs.subtracting(drawnTrackingIDs)
        let trackingIDsToBeMoved: Set<Int32> = drawnTrackingIDs.intersection(newTrackingIDs)
        let trackingIDsToBeRemoved: Set<Int32> = drawnTrackingIDs.subtracting(newTrackingIDs)
        
        let areasToBeAdded: [MouthArea] = trackingIDsToBeAdded.compactMap { trackingID in
            areas.first { $0.trackingID == trackingID }
        }
        let areasToBeMoved: [MouthArea] = trackingIDsToBeMoved.compactMap { trackingID in
            areas.first { $0.trackingID == trackingID }
        }

        drawCircles(of: areasToBeAdded)
        moveCircles(of: areasToBeMoved)
        removeCircles(of: Array(trackingIDsToBeRemoved))
    }
    
    //left eye
    func update(with areas: [LeftEyeArea]) {
        let drawnAreas = drawnLeftEyeLayers.map { $0.area }
        let drawnTrackingIDs: Set<Int32> = Set(drawnAreas.map { $0.trackingID })
        let newTrackingIDs: Set<Int32> = Set(areas.map { $0.trackingID })

        let trackingIDsToBeAdded: Set<Int32> = newTrackingIDs.subtracting(drawnTrackingIDs)
        let trackingIDsToBeMoved: Set<Int32> = drawnTrackingIDs.intersection(newTrackingIDs)
        let trackingIDsToBeRemoved: Set<Int32> = drawnTrackingIDs.subtracting(newTrackingIDs)
        
        let areasToBeAdded: [LeftEyeArea] = trackingIDsToBeAdded.compactMap { trackingID in
            areas.first { $0.trackingID == trackingID }
        }
        let areasToBeMoved: [LeftEyeArea] = trackingIDsToBeMoved.compactMap { trackingID in
            areas.first { $0.trackingID == trackingID }
        }

        drawCircles(of: areasToBeAdded)
        moveCircles(of: areasToBeMoved)
        removeCircles(of: Array(trackingIDsToBeRemoved))
    }
    
    //right eye
    func update(with areas: [RightEyeArea]) {
        let drawnAreas = drawnRightEyeLayers.map { $0.area }
        let drawnTrackingIDs: Set<Int32> = Set(drawnAreas.map { $0.trackingID })
        let newTrackingIDs: Set<Int32> = Set(areas.map { $0.trackingID })

        let trackingIDsToBeAdded: Set<Int32> = newTrackingIDs.subtracting(drawnTrackingIDs)
        let trackingIDsToBeMoved: Set<Int32> = drawnTrackingIDs.intersection(newTrackingIDs)
        let trackingIDsToBeRemoved: Set<Int32> = drawnTrackingIDs.subtracting(newTrackingIDs)
        
        let areasToBeAdded: [RightEyeArea] = trackingIDsToBeAdded.compactMap { trackingID in
            areas.first { $0.trackingID == trackingID }
        }
        let areasToBeMoved: [RightEyeArea] = trackingIDsToBeMoved.compactMap { trackingID in
            areas.first { $0.trackingID == trackingID }
        }

        drawCircles(of: areasToBeAdded)
        moveCircles(of: areasToBeMoved)
        removeCircles(of: Array(trackingIDsToBeRemoved))
    }
    
    //
    
    
    
    ///
    ///Face
    ///
    private func moveCircles(of areas: [FaceArea]) {
        areas.forEach { moveCircle(of: $0) }
    }
    
    private func moveCircle(of area: FaceArea) {
        guard let drawnLayerIndex = (drawnFaceLayers.firstIndex { $0.area.trackingID == area.trackingID }) else {
            return
        }
        let drawnLayer = drawnFaceLayers[drawnLayerIndex]
        let fromCentroid = drawnLayer.layer.position
        let toCentroid = area.bounds.center
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.fromValue = NSValue(cgPoint: fromCentroid)
        moveAnimation.toValue = NSValue(cgPoint: toCentroid)
        moveAnimation.duration = 0.3
        moveAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        drawnLayer.layer.position = toCentroid
        drawnLayer.layer.add(moveAnimation, forKey: "position")
    }

    private func drawCircles(of areas: [FaceArea]) {
        areas.forEach { drawCircle(of: $0) }
    }
    
    private func drawCircle(of area: FaceArea) {
        let bounds = area.bounds
        let radius: CGFloat = (bounds.maxX - bounds.minX) / 2.0
        let circleLayer = CAShapeLayer.circle(radius: radius)
        circleLayer.frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        circleLayer.position = bounds.center
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.borderColor = UIColor.red.cgColor
        circleLayer.borderWidth = 5.0
        layer.addSublayer(circleLayer)
        drawnFaceLayers.append(FaceLayer(layer: circleLayer, area: area))
    }
    
    private func removeCircles(of indexes: [Int32]) {
        indexes.forEach { index in
            guard let drawnLayer = (drawnFaceLayers.first { $0.area.trackingID == index }) else { return }
            drawnLayer.layer.removeFromSuperlayer()
            drawnFaceLayers = drawnFaceLayers.filter { $0.area.trackingID != index }
            
            guard let drawnMouthLayer = (drawnMouthLayers.first { $0.area.trackingID == index }) else { return }
            drawnMouthLayer.layer.removeFromSuperlayer()
            drawnMouthLayers = drawnMouthLayers.filter { $0.area.trackingID != index }
            
            guard let drawnLeftEyeLayer = (drawnLeftEyeLayers.first { $0.area.trackingID == index }) else { return }
            drawnLeftEyeLayer.layer.removeFromSuperlayer()
            drawnLeftEyeLayers = drawnLeftEyeLayers.filter { $0.area.trackingID != index }
            
            guard let drawnRightEyeLayer = (drawnRightEyeLayers.first { $0.area.trackingID == index }) else { return }
            drawnRightEyeLayer.layer.removeFromSuperlayer()
            drawnRightEyeLayers = drawnRightEyeLayers.filter { $0.area.trackingID != index }
        }
    }
    
    
    
    ///
    ///Mouth
    ///
    private func moveCircles(of areas: [MouthArea]) {
            areas.forEach { moveCircle(of: $0) }
    }
        
    private func moveCircle(of area: MouthArea) {
        guard let drawnLayerIndex = (drawnMouthLayers.firstIndex { $0.area.trackingID == area.trackingID }) else {
            return
        }
        let drawnLayer = drawnMouthLayers[drawnLayerIndex]
        let fromCentroid = drawnLayer.layer.position
        let toCentroid = area.bounds.center
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.fromValue = NSValue(cgPoint: fromCentroid)
        moveAnimation.toValue = NSValue(cgPoint: toCentroid)
        moveAnimation.duration = 0.3
        moveAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        drawnLayer.layer.position = toCentroid
        drawnLayer.layer.add(moveAnimation, forKey: "position")
    }

    private func drawCircles(of areas: [MouthArea]) {
        areas.forEach { drawCircle(of: $0) }
    }
    
    private func drawCircle(of area: MouthArea) {
        let bounds = area.bounds
        let radius: CGFloat = (bounds.maxX - bounds.minX) / 2.0
        let circleLayer = CAShapeLayer.circle(radius: radius)
        circleLayer.frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        circleLayer.position = bounds.center
//        circleLayer.fillColor = layerColor.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.borderColor = UIColor.red.cgColor
        circleLayer.borderWidth = 5.0
        layer.addSublayer(circleLayer)
        drawnMouthLayers.append(MouthLayer(layer: circleLayer, area: area))
    }
    
    
    ///
    ///Left Eye
    ///
    private func moveCircles(of areas: [LeftEyeArea]) {
            areas.forEach { moveCircle(of: $0) }
    }
        
    private func moveCircle(of area: LeftEyeArea) {
        guard let drawnLayerIndex = (drawnLeftEyeLayers.firstIndex { $0.area.trackingID == area.trackingID }) else {
            return
        }
        let drawnLayer = drawnLeftEyeLayers[drawnLayerIndex]
        let fromCentroid = drawnLayer.layer.position
        let toCentroid = area.bounds.center
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.fromValue = NSValue(cgPoint: fromCentroid)
        moveAnimation.toValue = NSValue(cgPoint: toCentroid)
        moveAnimation.duration = 0.3
        moveAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        drawnLayer.layer.position = toCentroid
        drawnLayer.layer.add(moveAnimation, forKey: "position")
    }

    private func drawCircles(of areas: [LeftEyeArea]) {
        areas.forEach { drawCircle(of: $0) }
    }
    
    private func drawCircle(of area: LeftEyeArea) {
        let bounds = area.bounds
        let radius: CGFloat = (bounds.maxX - bounds.minX) / 2.0
        let circleLayer = CAShapeLayer.circle(radius: radius)
        circleLayer.frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        circleLayer.position = bounds.center
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.borderColor = UIColor.red.cgColor
        circleLayer.borderWidth = 5.0
        layer.addSublayer(circleLayer)
        drawnLeftEyeLayers.append(LeftEyeLayer(layer: circleLayer, area: area))
    }
    
    ///
    ///Right Eye
    ///
    private func moveCircles(of areas: [RightEyeArea]) {
            areas.forEach { moveCircle(of: $0) }
    }
        
    private func moveCircle(of area: RightEyeArea) {
        guard let drawnLayerIndex = (drawnRightEyeLayers.firstIndex { $0.area.trackingID == area.trackingID }) else {
            return
        }
        let drawnLayer = drawnRightEyeLayers[drawnLayerIndex]
        let fromCentroid = drawnLayer.layer.position
        let toCentroid = area.bounds.center
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.fromValue = NSValue(cgPoint: fromCentroid)
        moveAnimation.toValue = NSValue(cgPoint: toCentroid)
        moveAnimation.duration = 0.3
        moveAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        drawnLayer.layer.position = toCentroid
        drawnLayer.layer.add(moveAnimation, forKey: "position")
    }

    private func drawCircles(of areas: [RightEyeArea]) {
        areas.forEach { drawCircle(of: $0) }
    }
    
    private func drawCircle(of area: RightEyeArea) {
        let bounds = area.bounds
        let radius: CGFloat = (bounds.maxX - bounds.minX) / 2.0
        let circleLayer = CAShapeLayer.circle(radius: radius)
        circleLayer.frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        circleLayer.position = bounds.center
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.borderColor = UIColor.red.cgColor
        circleLayer.borderWidth = 5.0
        layer.addSublayer(circleLayer)
        drawnRightEyeLayers.append(RightEyeLayer(layer: circleLayer, area: area))
    }
}
