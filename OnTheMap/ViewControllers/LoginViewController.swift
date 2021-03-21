//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Ismail on 10/03/2021.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    let permissions = ["public_profile", "email"]
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    //MARK: Actions
    @IBAction func loginWithFacebook(_ sender: Any) {
        let loginManager = LoginManager()
        
        loginManager.logIn(permissions: permissions, from: self) { (loginResult, error) in
            guard error == nil else {
                self.showLoginFailure(message: error?.localizedDescription ?? "Something went wrong!")
                return
            }
            guard let result = loginResult, !result.isCancelled else {
                print("User cancelled login")
                return
            }
            
            if let token = AccessToken.current, !token.isExpired {
                ApiClient.Auth.key = UUID().uuidString
                self.performSegue(withIdentifier: Constants.toHomeScreen, sender: nil)
            }
        }
    }
    @IBAction func loginWithEmaill(_ sender: Any) {
        let username = emailTextField.text!
        let password = passwordTextField.text!
        
        setLoggingIn(true)
        ApiClient.loginRequest(username, password) { (reponse, error) in
            
            self.setLoggingIn(false)
            
            guard let _ = reponse else{
                self.showLoginFailure(message: error?.localizedDescription ?? "Something went wrong!")
                return
            }
            self.performSegue(withIdentifier: Constants.toHomeScreen, sender: nil)
            
        }
        
    }
    
    //MARK: Utils
    func setLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            progressIndicator.startAnimating()
        }else{
            progressIndicator.stopAnimating()
        }
        setUIState(!loggingIn)
    }
    
    func setUIState(_ isLoading: Bool){
        emailTextField.isEnabled = isLoading
        passwordTextField.isEnabled = isLoading
        loginButton.isEnabled = isLoading
        facebookLoginButton.isEnabled = isLoading
    }
    
    func showLoginFailure(message: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
}
