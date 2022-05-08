//
//  ScanQRCodeViewController.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/3.
//

import UIKit
import AVFoundation

class ScanQRCodeViewController: UIViewController {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet var scanOutlineView: [UIView]!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var viewLabelPassport: UIStackView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var btnImport: UIButton!
    private var sleepTime = Date().timeIntervalSince1970
    
    private func setViewConstraint() {
        scanOutlineView.forEach({
            $0.layer.cornerRadius = 5
        })
        
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let viewQRCodeSize = width - (rightView.frame.width * 2)
        
        let viewHeight = (height - viewQRCodeSize) / 2
        bottomView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
        topView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewLabelPassport.layer.cornerRadius = viewLabelPassport.frame.height / 2
        self.setViewConstraint()
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            self.showCameraErrorAlert()
            return
        }

        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {
                if !$0 {
                    self.showCameraErrorAlert()
                }
            })
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)

            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)

            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.global())
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)

            captureSession.startRunning()

            view.bringSubviewToFront(topView)
            view.bringSubviewToFront(rightView)
            view.bringSubviewToFront(leftView)
            view.bringSubviewToFront(bottomView)
            view.bringSubviewToFront(btnBack)
            view.bringSubviewToFront(btnImport)
            view.bringSubviewToFront(stackView)

            scanOutlineView.forEach({
                view.bringSubviewToFront($0)
            })
        } catch {
            print("\(error)")
            return
        }
    }
    
    @IBAction func btnBackEvent(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnImportEvent(_ sender: Any) {
        self.selectQRCodeImage()
    }
    
    private func showCameraErrorAlert() {
        let errorMsg = NSLocalizedString("CameraNotUse", comment: "")
        let importMsg = NSLocalizedString("ImportPassport", comment: "")
        
        let alertController = UIAlertController(title: "Error", message: errorMsg, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Back", style: .cancel, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        })
        
        let importAction = UIAlertAction(title: importMsg, style: .default, handler: { _ in
            self.selectQRCodeImage()
        })
        
        alertController.addAction(importAction)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
    }
    
    private func selectQRCodeImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
}

extension ScanQRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Delay
        if (Date().timeIntervalSince1970 - self.sleepTime) < 0.5 {
            return
        }
        self.sleepTime = Date().timeIntervalSince1970
        
        if metadataObjects.count <= 0 {
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type != .qr {
            return
        }
        
        DispatchQueue.main.async {
            let maxX = self.rightView.frame.origin.x + self.leftView.frame.width
            let minX = self.leftView.frame.origin.x
            let minY = self.rightView.frame.origin.y
            let maxY = self.rightView.frame.origin.y + self.rightView.frame.height
            
            guard let barCodeObject = self.videoPreviewLayer?.transformedMetadataObject(for: metadataObj) else {
                return
            }
            
            let barCodeSize = barCodeObject.bounds

            
            if barCodeSize.origin.x > minX && (barCodeSize.origin.x + barCodeSize.width) < maxX {
                if barCodeSize.origin.y > minY && (barCodeSize.origin.y + barCodeSize.height) < maxY {
                    self.sleepTime = Date().timeIntervalSince1970
                    
                    let loadingViewController = LoadingGetPassportViewController()
                    loadingViewController.hc1Code = metadataObj.stringValue ?? ""
                    self.navigationController?.pushViewController(loadingViewController, animated: true)
                }
            }
        }
    }
}

extension ScanQRCodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickerImage = info[.originalImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true, completion: nil)
        
        let loadingViewController = LoadingGetPassportViewController()
        loadingViewController.hc1Code = QRCodeUtil.decodeQRCode(pickerImage)
        self.navigationController?.pushViewController(loadingViewController, animated: true)
    }
}
