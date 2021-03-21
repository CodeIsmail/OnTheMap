//
//  AddLocationResponse.swift
//  OnTheMap
//
//  Created by Ismail on 13/03/2021.
//

import Foundation

struct AddLocationResponse: Codable {
    let objectId: String
    let createdAt: String
}

struct UpdateLocationResponse : Codable{
    let updateAt: String
}
