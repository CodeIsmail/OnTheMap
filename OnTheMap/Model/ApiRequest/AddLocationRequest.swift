//
//  AddLocationRequest.swift
//  OnTheMap
//
//  Created by Ismail on 13/03/2021.
//

import Foundation

struct AddLocationRequest: Codable{
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
}
