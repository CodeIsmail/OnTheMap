//
//  SessionRequest.swift
//  OnTheMap
//
//  Created by Ismail on 13/03/2021.
//

import Foundation

struct SessionRequest: Codable{
    let udacity: Udacity
}

struct Udacity: Codable{
    let username: String
    let password: String
}


