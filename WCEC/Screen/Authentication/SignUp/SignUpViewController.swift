//
//  SignUpViewController.swift
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

class SignUpViewController: BaseViewController {

    @IBOutlet weak var emailViewContainer: CustomTextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signupWithEmailTitle: UILabel!
    @IBOutlet weak var signupWithSocialTitle: UILabel!
    let userService = UserService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LineSDKLogin.sharedInstance().delegate = self
    }
    
    override func setupLocalized() {
        emailViewContainer.title = "E-mail Address".localized()
        signUpButton.setTitle("Sign Up".localized(), for: .normal)
        signupWithEmailTitle.text = "Sign up with e-mail address".localized()
        signupWithSocialTitle.text = "Sign up with your existing social media account".localized()
    }
    
    // MARK: IBAction
    @IBAction func onSelectSignUp(_ sender: Any) {
        if verifyField() {
            let agreementVC = AgreementViewController()
            agreementVC.delegate = self
            agreementVC.type = .email
            let nav = BaseNavigationController.init(rootViewController: agreementVC)
            navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
    // MARK: Facebook
    @IBAction func onSelectFacebook(_ sender: Any) {
        goAgreement(type: .facebook)
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
                    imageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cache, url) in
                        if let img = image, error == nil {
                            DataManager.saveSocialAvatarImage(image: img)
                        }
                        self.userService.doSocialAuthen(email: email,
                                                        id: dict["id"] as! String,
                                                        type: AccountType.facebook.typeString(),
                                                        firstName: dict["first_name"] as! String,
                                                        lastName:  dict["last_name"] as! String,
                                                        avatarId: 0,
                                                        complete: { (result) in
                            self.hideHude()
                            switch result {
                            case .success(let response):
                                self.checkFollowSocial(response.data,
                                                       socicalId: dict["id"] as! String,
                                                       socialType: AccountType.facebook.typeString())
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
        goAgreement(type: .twitter)
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
                    if let img = image, error == nil {
                        DataManager.saveSocialAvatarImage(image: img)
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
                                                                               socicalId: user.userID,
                                                                               socialType: AccountType.twitter.typeString())
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
        goAgreement(type: .line)
    }
    
    func goAgreement(type: AccountType) {
        let agreementVC = AgreementViewController()
        agreementVC.delegate = self
        agreementVC.type = type
        let nav = BaseNavigationController.init(rootViewController: agreementVC)
        navigationController?.present(nav, animated: true, completion: nil)
    }
    
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
        
        return true
    }

    // MAKR: Check Socical
    func checkFollowSocial(_ data: UserModel, socicalId: String, socialType: String) {
        DataManager.saveUserModel(data)
        DataManager.saveUserToken(data.token)
        
        guard data.status == .activate else {
            let vc = SetMobileViewController()
            vc.social_id = socicalId
            vc.social_type = socialType
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        
        if data.profileCompleted == 0 {
            Constants.appDelegate.setupIntro()
        } else {
            Constants.appDelegate.setupRootViewController()
        }
    }
}

extension SignUpViewController: AgreementViewControllerDelegate {
    func onUserAgreeTerm(_ viewController: AgreementViewController, withAccountType type: AccountType) {
        switch type {
        case .email:
            DataManager.removeSavedImage()
            let vc = SetMobileViewController()
            vc.emailRegister = emailViewContainer.textField.text!
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .facebook:
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
            break
        case .twitter:
            TWTRTwitter.sharedInstance().logIn(completion: { (session, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let session = session {
                    self.getTwitterData(session: session)
                }
            })
            break
        case .line:
            LineSDKLogin.sharedInstance().startWebLogin()
            break
        default:
            break
        }
    }
    
    func onCloseAgrement(_ viewController: AgreementViewController) {
        // Do somthing
    }
}

extension SignUpViewController: LineSDKLoginDelegate {
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
                                                                           socicalId: profile.userID,
                                                                           socialType: AccountType.line.typeString())
                                                    break
                                                case .failure( let error):
                                                    self.alertWithError(error)
                                                    break
                                                }
            })
        }
    }
}













