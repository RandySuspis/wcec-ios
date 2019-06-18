//
//  ScanQRCodeViewController.swift
//  WCEC
//
//  Created by GEM on 5/18/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import SnapKit

protocol ScanQRCodeViewControllerDelegate: NSObjectProtocol {
    func successScanQrCode(userId: String)
}

class ScanQRCodeViewController: BaseViewController {
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnMyQrCode: UIButton!
    
    weak var delegate: ScanQRCodeViewControllerDelegate?
    let scannerView: LBXScanViewController = LBXScanViewController()
    
    var isOpenMyQR: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScan()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isOpenMyQR = false
    }

    func setupUI() {
        self.view.backgroundColor = AppColor.colorBlack54()
    }
    
    override func setupLocalized() {
        self.navigationItem.title = "Scan QR Code".localized()
        self.lblDesc.text = "Align QR Code to scan".localized()
        btnMyQrCode.setTitle("My QR Code".localized(), for: .normal)
    }
    
    func setupScan() {
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.On
        style.photoframeLineW = 6
        style.photoframeAngleW = 24
        style.photoframeAngleH = 24
        style.isNeedShowRetangle = true
        style.anmiationStyle = LBXScanViewAnimationStyle.LineMove
        style.animationImage = UIImage(named: "qrcode_scan_light_green")
        scannerView.scanStyle = style
        
        self.view.insertSubview(scannerView.view, at: 0)
        self.addChildViewController(scannerView)

        scannerView.scanResultDelegate = self
        scannerView.view.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    @IBAction func onPressMyQRCode(_ sender: Any) {
        if isOpenMyQR {
            return
        }
        
        isOpenMyQR = true
        let vc = MyQRCodeViewController()
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ScanQRCodeViewController: LBXScanViewControllerDelegate {
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        let connectionService = ConnectionsService()
        guard let qr_code_id = scanResult.strScanned  else {
            return
        }
        
        guard let user = DataManager.getCurrentUserModel() else {
            return
        }
        
        self.showHud()
        connectionService.sendConnectionQrCode(qrCode: qr_code_id, currentUserId: String(user.id)) { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                let popup = PopupConnectedViewController.init(PopupConnectedViewController.classString())
                popup.user = response.data
                popup.delegate = self
                Constants.appDelegate.tabbarController.present(popup, animated: true, completion: nil)
                break
            case .failure( let error):
                self.alertWithError(error)
//                showAlertAndWithAction(title: "Alert".localized(),
//                                       message: error._userInfo?["message"] as? String ,
//                                       completeHanle: {
//                                        self.scannerView.startScan()
//                                        
//                })
                break
            }
        }
    }
    
}

extension ScanQRCodeViewController: PopupSendRequestDelegate {
    func popupSendRequest(_ controller: PopupSendRequest, didClose sender: UIButton, success: Bool) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension ScanQRCodeViewController: PopupConnectedViewControllerDelegate {
    func popupConnectedViewController(userId: String) {
        delegate?.successScanQrCode(userId: userId)
    }
}












