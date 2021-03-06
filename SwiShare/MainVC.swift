//
//  ViewController.swift
//  SwiShare
//
//  Created by Turcu Ciprian on 16/04/2017.
//  Copyright © 2017 ToolAxy One S.R.L. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

var xref = FIRDatabase.database().reference()

class MainVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView!
    
    
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var gotoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QRCodeView()
    }
    //when changing orientation this function fires:
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("orientation changed")
        
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            // Your code here
            self.videoPreviewLayer = nil
            
            
            
            
            
            
            
            self.QRCodeView()
            
            
            
        }
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    //create the QR code view reader that opens the camera:
    //
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        
        self.videoPreviewLayer?.frame = self.view.bounds
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection =  self.videoPreviewLayer?.connection  {
            
            let currentDevice: UIDevice = UIDevice.current
            
            let orientation: UIDeviceOrientation = currentDevice.orientation
            
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                    
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                
                    break
                    
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                
                    break
                    
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                
                    break
                    
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                
                    break
                }
            }
        }
    }

    func QRCodeView(){
        // Do any additional setup after loading the view, typically from a nib.
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            self.captureSession = AVCaptureSession()
            
            self.captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            self.captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            self.videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            self.videoPreviewLayer?.frame = self.view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            captureSession?.startRunning()
            
            // Move the message label and top bar to the front
            self.view.bringSubview(toFront: messageLabel)
            self.view.bringSubview(toFront: gotoLabel)
            
            
            
            
            // Initializing the green box
            
            qrCodeFrameView = UIView()
            if let qrCodeFrameView  = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 8
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch{
            print (error)
            return
        }

    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
//        check if the metadata objects array is not nil and it contains at least one object
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
//            messageLabel.text = "No QR code detected"
            return
        }
        
        //get the metadata object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObjectTypeQRCode {
            //if foundmetadata is equal to QR code metadata then update status 1
            let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barcodeObject!.bounds
            
            //get data from the clipboard
            if metadataObj.stringValue != nil{
                let QRVal:String =  metadataObj.stringValue
                let ssGlobal = ssGeneral()
                let theString = ssGlobal.clipboardData(QRVal: QRVal)
//                messageLabel.text = QRVal
                xref.child(QRVal).setValue(["val": theString])
                
                
            }
        }
        
        
    }


}

