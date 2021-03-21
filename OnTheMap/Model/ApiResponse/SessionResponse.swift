//
//  SessionResponse.swift
//  OnTheMap
//
//  Created by Ismail on 13/03/2021.
//

import Foundation

struct SessionResponse: Codable{
    let account: Account
    let session: Session
    
}

struct Account: Codable{
    let registered: Bool
    let key: String
}

struct Session: Codable{
    let id: String
    let expiration: String
}

struct DeleteSessionResponse: Codable{
    let session: Session
}


//{"status":403,"error":"Account not found or invalid credentials."}

//{"code":101,"error":"Object not found."} 

//{"updatedAt":"2021-03-18T06:08:57.171Z"}
