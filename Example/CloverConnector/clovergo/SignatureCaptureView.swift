//
//  SignatureCaptureView.swift
//  CloverConnector_Example
//
//  Created by Rajan Veeramani on 10/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

class SignatureCaptureView: UIView
{
    var delegate: SignatureViewDelegate?
    
    func midpoint(p0: CGPoint, p1: CGPoint) -> CGPoint
    {
        return CGPoint(x: (p0.x + p1.x) / 2.0, y: (p0.y + p1.y) / 2.0)
    }
    
    private var path: UIBezierPath?
    private var previousPoint = CGPoint.zero
    private var currentPoint = CGPoint.zero
    private var currentPath = NSMutableArray()
    
    private var internalPaths:[NSMutableArray] = [NSMutableArray]()
    
    private var gesture: UIGestureRecognizer?
    
//    init() {
//        super.
//        sharedInstance.commonInit()
//    }
    
    func commonInit() {
        path = UIBezierPath()
        // Capture touches
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = pan.minimumNumberOfTouches
        addGestureRecognizer(pan)
        gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.erase))
        internalPaths = [NSMutableArray]()
        self.accessibilityTraits = UIAccessibilityTraitAllowsDirectInteraction
        isAccessibilityElement = true
        accessibilityLabel = "Sign with your finger"
    }
    
    
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
        
    }
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
        
    }
    
    func enableEraseSignatureOnLongPress(enable: Bool) {
        if enable {
            self.addGestureRecognizer(gesture!)
        }
        else {
            self.removeGestureRecognizer(gesture!)
        }
    }
    
    
    @objc func erase() {
        if internalPaths.count > 0 {
            path = UIBezierPath()
            internalPaths.removeAll()
            self.setNeedsDisplay()
            if self.delegate?.isSignaturePresent != nil {
                self.delegate!.isSignaturePresent(valid: false)
            }
            print("Signature erased !")
        }
    }
    
    @objc func pan(pan: UIPanGestureRecognizer) {
        self.computeInternalPaths(view: self, pan: pan)
    }
    
    
    func computeInternalPaths(view: UIView, pan: UIPanGestureRecognizer) {
        currentPoint = pan.location(in: view)
        let midPoint = midpoint(p0: previousPoint, p1: currentPoint)
        if pan.state == .began {
            path!.move(to: currentPoint)
            currentPath = NSMutableArray()
            currentPath.add(NSValue(cgPoint: currentPoint))
        }
        else if pan.state == .changed {
            path!.addQuadCurve(to: midPoint, controlPoint: previousPoint)
            currentPath.add(NSValue(cgPoint: currentPoint))
        }
        else if pan.state == .ended {
            var dotPoint = currentPoint
            // give our dot a little more size so it will stroke
            dotPoint.x += 1
            dotPoint.y += 1
            currentPath.add(NSValue(cgPoint: dotPoint))
        }
        
        previousPoint = currentPoint
        internalPaths.append(currentPath)
        view.setNeedsDisplay()
        if internalPaths.count != 0
        {
            if self.delegate?.isSignaturePresent != nil {
                self.delegate!.isSignaturePresent(valid: true)
            }
        }
    }
    
    func getSignatureForCloverGo(pan: UIPanGestureRecognizer, inView view: UIView) -> NSDictionary {
        self.computeInternalPaths(view: view, pan: pan)
        if internalPaths.count != 0 {
            return self.jsonDescription()
        }
        else {
            return [:]
        }
    }
    
    func signaturePoints(pointArray: NSArray) -> NSArray {
        let points = NSMutableArray()
        for v in pointArray {
            if let p = (v as AnyObject).cgPointValue {
                points.add([Int(Int(p.x)), Int(Int(p.y))])
            }
        }
        return points
    }
    
    func jsonDescription() -> NSDictionary {
        // multiple arrays of strokes
        let pointSets = NSMutableArray()
        for pathe in internalPaths {
            let points = self.signaturePoints(pointArray: pathe as NSArray)
            pointSets.add(["points": points])
        }
        let pathDict = ["signature": ["strokes": pointSets]]
        print("Signature JSON (contains stokes-points info) ! : \(pathDict)")
        return pathDict as NSDictionary
    }
    
    internal func getSignaturePoints() -> NSArray {
        let pointSets = NSMutableArray()
        for pathe in internalPaths {
            let points: NSArray = self.signaturePoints(pointArray: pathe as NSArray)
            pointSets.add(points)
        }
        return pointSets
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.black.setStroke()
        path!.stroke()
    }
    
}
