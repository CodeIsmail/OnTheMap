//
//  ApiClient.swift
//  OnTheMap
//
//  Created by Ismail on 13/03/2021.
//

import Foundation

class ApiClient {
    
    struct Auth {
        static var key = ""
        static var sessionId = ""
        static var sessionExpiration = ""
    }
    enum Endpoints{
        static let baseUrl = "https://onthemap-api.udacity.com/v1/"
        static let requestLimit = 100
        static let sessionPath = "session"
        static let studentLocationPath = "StudentLocation"
        
        case requestSession
        case getStudentInformation
        case deleteSession
        case addLocation
        case updateLocation(String)
        
        
        var stringValue: String{
            switch self {
            case .requestSession:
                return Endpoints.baseUrl + Endpoints.sessionPath
            case .getStudentInformation:
                return Endpoints.baseUrl + Endpoints.studentLocationPath +
                    "?order=-updatedAt&limit=\(Endpoints.requestLimit)"
            case .deleteSession:
                return Endpoints.baseUrl + Endpoints.sessionPath
            case .addLocation:
                return Endpoints.baseUrl + Endpoints.studentLocationPath
            case .updateLocation(let userId):
                return Endpoints.baseUrl + Endpoints.studentLocationPath +
                    "/\(userId)"
            }
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
        
    }
    
    //MARK: API Client Request
    
    class func loginRequest(_ username: String, _ password:String, completion: @escaping (SessionResponse?, Error?) -> Void){
        let body = SessionRequest(udacity: Udacity(username: username, password: password))
        taskForPOSTRequest(url: Endpoints.requestSession.url, responseType: SessionResponse.self, body: body) { (response, error) in
            if let response = response{
                Auth.sessionExpiration = response.session.expiration
                Auth.sessionId =  response.session.id
                Auth.key = response.account.key
                completion(response, nil)
            }else{
                completion(nil, error)
            }
        }
    }
    
    class func getStudentInformation(completion: @escaping ([StudentInformation], Error?) -> Void){
        taskForGETRequest(url: Endpoints.getStudentInformation.url, responseType: StudentInformationResponse.self) { (response, error) in
            if let response = response {
                completion(response.results, nil)
            }else{
                completion([], error)
            }
        }
    }
    
    class func addLocationRequest(requestBody: AddLocationRequest,
                                  completion: @escaping (AddLocationResponse?, Error?) -> Void){
        taskForPOSTLocationRequest(url: Endpoints.addLocation.url, responseType: AddLocationResponse.self, body: requestBody, httpMethod: "POST") { (response, error) in
            if let response = response{
                completion(response, nil)
            }else{
                completion(nil, error)
            }
        }
    }
    
    class func updateLocationRequest(userId: String, requestBody: AddLocationRequest,
                                  completion: @escaping (UpdateLocationResponse?, Error?) -> Void){

        taskForPOSTLocationRequest(url: Endpoints.updateLocation(userId).url, responseType: UpdateLocationResponse.self, body: requestBody, httpMethod: "PUT") { (response, error) in
            if let response = response{
                completion(response, nil)
            }else{
                completion(nil, error)
            }
        }
    }
    
    class func logoutRequest(completion: @escaping (DeleteSessionResponse?, Error?) -> Void){
        taskForDELETERequest(url: Endpoints.deleteSession.url) { (response, error) in
            if let response = response{
                completion(response, nil)
            }else{
                completion(nil, error)
            }
        }
    }
    
    class func taskForPOSTRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, completion: @escaping (ResponseType?, Error?) -> Void){
        
        let data = try! JSONEncoder().encode(body)
        var request =  URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let range = 5..<data.count
            let newData = data.subdata(in: range)
            let decoder = JSONDecoder()
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: newData)
                print(responseObject)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }catch{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
//                do{
//                    let errorResponse = try decoder.decode(SessionResponse.self, from: data)
////                    DispatchQueue.main.async {
////                        completion(nil, errorResponse)
////                    }
//                }catch{
//                    DispatchQueue.main.async {
//                        completion(nil, error)
//                    }
//                }
            }
            
        }
        task.resume()
    }
    
    class func taskForPOSTLocationRequest<RequestType: Encodable, ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, body: RequestType, httpMethod: String, completion: @escaping (ResponseType?, Error?) -> Void){
        
        let data = try! JSONEncoder().encode(body)
        var request =  URLRequest(url: url)
        request.httpMethod = httpMethod
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = data
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }catch{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
//                do{
//                    let errorResponse = try decoder.decode(SessionResponse.self, from: data)
////                    DispatchQueue.main.async {
////                        completion(nil, errorResponse)
////                    }
//                }catch{
//                    DispatchQueue.main.async {
//                        completion(nil, error)
//                    }
//                }
            }
            
        }
        task.resume()
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void){
        
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            do{
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }catch{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
//                do{
//                    let errorResponse = try decoder.decode(TMDBResponse.self, from: data)
//                    DispatchQueue.main.async {
//                        completion(nil, errorResponse)
//                    }
//                }catch{
//                    DispatchQueue.main.async {
//                        completion(nil, error)
//                    }
//                }
            }
            
        }
        task.resume()
    }
    
    class func taskForDELETERequest(url: URL, completion: @escaping (DeleteSessionResponse?, Error?) -> Void){
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
          if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
          request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = URLSession.shared.dataTask(with: request){
            data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let range = 5..<data.count
            let newData = data.subdata(in: range) /* subset response data! */
            print(String(data: newData, encoding: .utf8)!)
            let decoder = JSONDecoder()
            
            do{
                
                let responseObject = try decoder.decode(DeleteSessionResponse.self, from: newData)
                print(responseObject)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            }catch{
                
                DispatchQueue.main.async {
                    completion(nil, error)
                }
//                do{
//                    let errorResponse = try decoder.decode(TMDBResponse.self, from: data)
//                    DispatchQueue.main.async {
//                        completion(nil, errorResponse)
//                    }
//                }catch{
//                    DispatchQueue.main.async {
//                        completion(nil, error)
//                    }
//                }
            }
            
        }
        task.resume()
        
    }
}
