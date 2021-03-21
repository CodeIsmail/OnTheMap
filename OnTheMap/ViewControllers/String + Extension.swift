//
//  String + Extension.swift
//  OnTheMap
//
//  Created by Ismail on 19/03/2021.
//

import Foundation
import UIKit

extension String{
    
    var canOpenUrl: Bool{
        let regEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regEx)
        return predicate.evaluate(with:self)
    }
    
    var validUrlString: String{
        let urlToOpen:String
        
        if !(self.lowercased().contains("https://") || self.lowercased().contains("http://")) {
            urlToOpen = "https://\(self.lowercased())"
        }else{
            urlToOpen = self.lowercased()
        }
        
        return urlToOpen
    }
    
}
