//
//  SignatureCloverGoViewController.swift
//  CloverConnector_Example
//
//  Created by Rajan Veeramani on 10/9/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import GoConnector

class SignatureCloverGoViewController: UIViewController, SignatureViewDelegate {
    
    @IBOutlet weak var signLabel: UILabel?
    var signingBox: SignatureCaptureView!
    var doneButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        (UIApplication.shared.delegate as? AppDelegate)?.cloverConnectorListener?.viewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.signLabel?.isHidden = false
        self.setSigningBox()
    }
    
    func setSigningBox() {
        let x = CGFloat((self.signLabel?.frame.origin.x)!)
        var y = CGFloat((self.signLabel?.frame.origin.y)!)
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && UIScreen.main.traitCollection.userInterfaceIdiom == .phone{
            y = y - 100
        }
        else{
            y = y + 100
        }
        let width = CGFloat((self.signLabel?.frame.size.width)!)
        let height = CGFloat(250)
        self.signingBox = SignatureCaptureView(frame: CGRect(x: x, y: y, width: width, height: height))
        self.signingBox.backgroundColor = UIColor.groupTableViewBackground
        self.signingBox.delegate = self
        self.signingBox.enableEraseSignatureOnLongPress(enable: true)
        var frame = self.signingBox.frame
        frame.origin.y = frame.origin.y + frame.size.height
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && UIScreen.main.traitCollection.userInterfaceIdiom == .phone{
            frame.origin.y = frame.origin.y + 5
        }
        else{
            frame.origin.y = frame.origin.y + 50
        }
        frame.size.height = 49
        self.doneButton = UIButton(frame: frame)
        self.doneButton.addTarget(self, action: #selector(self.doneClicked), for: .touchUpInside)
        self.doneButton.setTitle("Done", for: .normal)
        self.doneButton.backgroundColor = UIColor.darkGray
        self.doneButton.setTitleColor(UIColor.groupTableViewBackground, for: .normal)
        self.doneButton.layer.cornerRadius = 8
        self.doneButton.layer.masksToBounds = true
        self.signingBox.layer.cornerRadius = 8
        self.signingBox.layer.masksToBounds = true
        self.view.addSubview(self.signingBox)
        self.view.addSubview(self.doneButton)
        self.view.bringSubview(toFront: self.signingBox)
        self.view.bringSubview(toFront: self.doneButton)
        self.doneButton.isHidden = true
    }
    
    @objc func doneClicked() {
            let strokeArray = signingBox.getSignaturePoints()
            
            let signature = Signature()
            signature.strokes = []
            var _ : [Signature.Stroke] = []
            for stroke in strokeArray {
                if let s = stroke as? [[Int]] {
                    let signStroke = Signature.Stroke()
                    signStroke.points = []
                    for points in s {
                        if let pts = points as? [Int] {
                            let point = Point()
                            point.x = pts[0]
                            point.y = pts[1]
                            signStroke.points?.append(point)
                        }
                    }
                    signature.strokes?.append(signStroke)
                }
            }

            ((UIApplication.shared.delegate as! AppDelegate).cloverConnector as? CloverGoConnector)?.captureSignature(signature: signature)

    }
    
    func isSignaturePresent(valid: Bool) {
        self.doneButton.isHidden = !valid
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
}
