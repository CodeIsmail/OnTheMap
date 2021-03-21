//
//  UIViewController+Extension.swift
//  OnTheMap
//
//  Created by Ismail on 14/03/2021.
//

import UIKit
import FBSDKLoginKit

extension UIViewController{
    //MARK: Action
    @IBAction func logoutTapped(_ sender: Any) {
        if let token = AccessToken.current, !token.isExpired {
            //Facebook logout
            print("Facebook logout")
            LoginManager().logOut()
            self.dismiss(animated: true, completion: nil)
        }else{
            ApiClient.logoutRequest { (session, error) in
                print(ApiClient.Auth.sessionId)
                if session != nil {
                    ApiClient.Auth.sessionId = ""
                    ApiClient.Auth.key = ""
                    self.dismiss(animated: true, completion: nil)
                }else{
                    print(error!)
                }
            }
        }
        
    }
}
