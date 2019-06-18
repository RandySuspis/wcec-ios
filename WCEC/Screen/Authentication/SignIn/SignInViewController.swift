//
//  SignInViewController.swift
//  WCEC
//
//  Created by hnc on 5/7/18.
//  Copyright © 2018 hnc. All rights reserved.
//

import UIKit
import FacebookLogin
import FBSDKLoginKit
import TwitterKit
import LineSDK

class SignInViewController: BaseViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var emailViewContainer: CustomTextField!
    @IBOutlet weak var passwordViewContainer: CustomTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginWithSocialTitle: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var beMemberButton: UIButton!
    
    // MARK: - Service
    let userService = UserService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordViewContainer.isSecure = true
        LineSDKLogin.sharedInstance().delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func setupLocalized() {
        titleLabel.text = "Login".localized()
        beMemberButton.setTitle("Be a Member >".localized(), for: .normal)
        emailViewContainer.title = "E-mail Address".localized()
        passwordViewContainer.title = "Password".localized()
        loginButton.setTitle("Login".localized(), for: .normal)
        forgotPasswordButton.setTitle("Forgot Password".localized(), for: .normal)
        loginWithSocialTitle.text = "Login with your existing social media account".localized()
    }
    
    // MARK: - IBAction

    @IBAction func tapBeMember(_ sender: Any) {
        let vc = RegistrationViewController()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func onSelectForgotPass(_ sender: Any) {
        let vc = ForgotPasswordViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: Login with email
    @IBAction func onSelectLogin(_ sender: Any) {
        if verifyField() {
            loginWithEmail()
        }
    }
    
    func loginWithEmail() {
        self .showHud()
        userService.doLogin(email: emailViewContainer.text!,
                            password: passwordViewContainer.text!,
                            complete: { (result) in
            self.hideHude()
            switch result {
            case .success(let response):
                DataManager.saveUserModel(response.data)
                DataManager.saveUserToken(response.data.token)
                if response.data.firstTimeLogin {
                    self.showAgreementViewController(accountType: .email)
                } else {
                    self.controlViewController(socialId: "", accountType: .email,
                                               withVerifiedStatus: response.data.verifiedStatus)
                    break
                }
            case .failure( let error):
                self.alertWithError(error)
                break
            }
        })
    }
    
    // MARK: Facebook
    
    @IBAction func onSelectFacebook(_ sender: Any) {
        loginWithFacebook()
    }
    
    func loginWithFacebook() {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                self.getFBUserData()
            }
        }
    }
   
    func getFBUserData(){
        if((AccessToken.current) != nil){
            let parameters = ["fields": "id, name, first_name, last_name, age_range, link, gender, locale, timezone, picture.type(large), updated_time, verified, email"]
            GraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let dict : [String : AnyObject] = result as! [String : AnyObject]
                    var email: String = ""
                    if dict.keys.contains("email") {
                        email = dict["email"] as! String
                    }
                    let fileDTO = FileDTO.init(dict)
                    let url = URL(string: fileDTO.file_url)
                    // this downloads the image asynchronously if it's not cached yet
                    let imageView = UIImageView()
                    self.showHud()
                    imageView.kf.setImage(with: url,
                                          placeholder: nil,
                                          options: nil,
                                          progressBlock: nil,
                                          completionHandler: { (image, error, cache, url) in
                        if error == nil {
                            DataManager.saveSocialAvatarImage(image: image!)
                        }
                        self.userService.doSocialAuthen(email: email,
                                                        id: dict["id"] as! String,
                                                        type: AccountType.facebook.typeString(),
                                                        firstName: dict["first_name"] as! String,
                                                        lastName:  dict["last_name"] as! String,
                                                        avatarId: 0, complete: { (result) in
                            self.hideHude()
                            switch result {
                            case .success(let response):
                                self.checkFollowSocial(response.data,
                                                       socialId: dict["id"] as! String,
                                                       socialType: AccountType.facebook)
                                break
                            case .failure( let error):
                                self.alertWithError(error)
                                break
                            }
                        })
                    })
                }
            })
        }
    }
    
    // MARK: Twitter
    
    @IBAction func onSelectTwitter(_ sender: Any) {
        loginWithTwitter()
    }
    
    func loginWithTwitter() {
        TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let session = session {
                self.getTwitterData(session: session)
            }
        })
    }
    
    func getTwitterData(session: TWTRSession) {
        let client = TWTRAPIClient.withCurrentUser()
        client.loadUser(withID: session.userID) { (user, error) in
            if let error = error {
                self.alertWithTitle("Alert".localized(), message: error.localizedDescription)
            } else if let user = user {
                print(user)
                self.showHud()
                // this downloads the image asynchronously if it's not cached yet
                let imageView = UIImageView()
                let url = URL(string: user.profileImageLargeURL)
                imageView.kf.setImage(with: url,
                                      placeholder: nil,
                                      options: nil,
                                      progressBlock: nil,
                                      completionHandler: { (image, error, cache, url) in
                                        if error == nil {
                                            DataManager.saveSocialAvatarImage(image: image!)
                                        }
                })
                self.userService.doSocialAuthen(email: "",
                                                id: user.userID,
                                                type: AccountType.twitter.typeString(),
                                                firstName: user.name,
                                                lastName:  "",
                                                avatarId: 0,
                                                complete: { (result) in
                                                    self.hideHude()
                                                    switch result {
                                                    case .success(let response):
                                                        self.checkFollowSocial(response.data,
                                                                               socialId: user.userID,
                                                                               socialType: AccountType.twitter)
                                                        break
                                                    case .failure( let error):
                                                        self.alertWithError(error)
                                                        break
                                                    }
                })
            }
        }
    }
    
    // MARK: Line
    
    @IBAction func onSelectLine(_ sender: Any) {
        loginWithLine()
    }
    
    func loginWithLine() {
        LineSDKLogin.sharedInstance().startWebLogin()
    }
    
    // MARK: - Verify text field
    
    func verifyField() -> Bool {
        if emailViewContainer.text?.trim() == "" || emailViewContainer.text == nil {
            showAlert(title: "Alert".localized(), message: "Please input your email.".localized(), completeHanle: {
                
            })
            return false
        } else {
            if emailViewContainer.text?.trim().isValidEmailAddress() == false {
                showAlert(title: "Alert".localized(), message: "Wrong email format".localized(), completeHanle: {
                    
                })
                return false
            }
        }
        
        if passwordViewContainer.text?.trim() == "" || passwordViewContainer.text == nil  {
            showAlert(title: "Alert".localized(), message: "Please input your password.".localized(), completeHanle: {
                
            })
            return false
        }
        
        return true
    }
    
    // MARK: - Check Socical
    
    func checkFollowSocial(_ data: UserModel, socialId: String, socialType: AccountType) {
        data.socialType = socialType.typeString()
        data.socialId = socialId
        DataManager.saveUserModel(data)
        DataManager.saveUserToken(data.token)
        if data.firstTimeLogin {
            showAgreementViewController(accountType: socialType)
        } else {
            controlViewController(socialId: socialId, accountType: socialType, withVerifiedStatus: data.verifiedStatus)
            switch data.verifiedStatus {
            case .unverify:
                let vc = SetMobileViewController()
                vc.social_id = socialId
                vc.social_type = socialType.typeString()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .setPasswordCompleted, .otpVerified:
                Constants.appDelegate.setupIntro()
                break
            case .profileCompleted:
                Constants.appDelegate.setupRootViewController()
                break
            }
        }
    }
    
    // MARK: - Check Agreement
    func showAgreementViewController(accountType: AccountType) {
        let agreementVC = AgreementViewController()
        agreementVC.delegate = self
        agreementVC.type = accountType
        let nav = BaseNavigationController(rootViewController: agreementVC)
        present(nav, animated: true, completion: nil)
    }
    
    // MARK: - Control View controller
    func controlViewController(socialId: String, accountType: AccountType, withVerifiedStatus status: VerifiedStatus) {
        if DataManager.checkIsGuestUser() {
            Constants.appDelegate.setupRootViewController()
            Constants.appDelegate.tabbarController.selectedIndex = 2
        } else {
            switch status {
            case .unverify:
                Constants.appDelegate.setupVerifyOTP()
                break
            case .otpVerified:
                if accountType == .email {
                    Constants.appDelegate.setupPassword()
                } else {
                    Constants.appDelegate.setupIntro()
                }
                break
            case .setPasswordCompleted:
                Constants.appDelegate.setupIntro()
                break
            case .profileCompleted:
                Constants.appDelegate.setupRootViewController()
                break
            }
        }
    }
}

// MARK: - LineSDKLoginDelegate

extension SignInViewController: LineSDKLoginDelegate {
    func didLogin(_ login: LineSDKLogin, credential: LineSDKCredential?, profile: LineSDKProfile?, error: Error?) {
        if let profile = profile {
            self.showHud()
            // this downloads the image asynchronously if it's not cached yet
            let imageView = UIImageView()
            imageView.kf.setImage(with: profile.pictureURL,
                                  placeholder: nil,
                                  options: nil,
                                  progressBlock: nil,
                                  completionHandler: { (image, error, cache, url) in
                                    if let img = image, error == nil {
                                        DataManager.saveSocialAvatarImage(image: img)
                                    }
            })
            self.userService.doSocialAuthen(email: "",
                                            id: profile.userID,
                                            type: AccountType.line.typeString(),
                                            firstName:  profile.displayName,
                                            lastName:  "",
                                            avatarId: 0,
                                            complete: { (result) in
                                                self.hideHude()
                                                switch result {
                                                case .success(let response):
                                                    self.checkFollowSocial(response.data,
                                                                           socialId: profile.userID,
                                                                           socialType: AccountType.line)
                                                    break
                                                case .failure( let error):
                                                    self.alertWithError(error)
                                                    break
                                                }
            })
        }
    }
}

// MARK: - AgreementViewControllerDelegate

extension SignInViewController: AgreementViewControllerDelegate {
    func onUserAgreeTerm(_ viewController: AgreementViewController, withAccountType type: AccountType) {
        guard let verifiedStatus = DataManager.getCurrentUserModel()?.verifiedStatus else {return}
        controlViewController(socialId: "", accountType: type, withVerifiedStatus: verifiedStatus)
    }
    
    func onCloseAgrement(_ viewController: AgreementViewController) {
        showHud()
        userService.doLogOut { (result) in
            switch result {
            case .failure(let error):
                self.alertWithError(error)
                break
            case .success(_):
                self.hideHude()
                break
            }
        }
    }
}















