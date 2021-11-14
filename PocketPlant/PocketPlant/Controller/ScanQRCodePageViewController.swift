//
//  ScanQRCodePageViewController.swift
//  PocketPlant
//
//  Created by 邱瀚平 on 2021/10/28.
//

import UIKit
import AVFoundation

class ScanQRCodePageViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarController?.tabBar.isHidden = true
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                          for: .video,
                                                          position: .back)
        else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self,
                                                             queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            guard let videoPreviewLayer = videoPreviewLayer else {
                return
            }
            view.layer.addSublayer(videoPreviewLayer)
            captureSession.startRunning()
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
        } catch {
            print(error)
            return
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
}

extension ScanQRCodePageViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            print("No QRcode is detected")
            return
        }
        
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else { return }
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            
            if let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj) {
                
                qrCodeFrameView?.frame = barCodeObject.bounds
                
                if metadataObj.stringValue != nil,
                   let plantID = metadataObj.stringValue {
                    
                    FirebaseManager.shared.fetchPlants(plantID: plantID) { result in
                        switch result {
                        case .success(let plant):
                            self.showSharePlant(plant: plant)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    func showSharePlant(plant: Plant) {
        let storyBoard = UIStoryboard(name: "ScanQRCodePage", bundle: nil)
        guard let remindVC = storyBoard.instantiateViewController(
            withIdentifier: String(describing: QRCodePlantDetailViewController.self))
                as? QRCodePlantDetailViewController else { return }
        remindVC.modalTransitionStyle = .crossDissolve
        remindVC.modalPresentationStyle = .overCurrentContext
        remindVC.plant = plant
        remindVC.delegate = self
        present(remindVC, animated: true, completion: nil)
        captureSession.stopRunning()
    }
}

extension ScanQRCodePageViewController: SharePlantDetailDelegate {
    
    func cancelAction() {
        captureSession.startRunning()
    }
    
    func goToSharePlantPage() {
        
        let parentVC = self.navigationController?.viewControllers.first
        
        guard let homepageVC = parentVC as? HomePageViewController else { return }
        
        homepageVC.isSelectedAt = .sharePlants
        
        homepageVC.buttonCollectionView.selectItem(at: IndexPath(row: 2, section: 0),
                                                   animated: false,
                                                   scrollPosition: .top)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
}
