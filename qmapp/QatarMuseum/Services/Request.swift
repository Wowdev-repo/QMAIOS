//
//  Request.swift
//  QatarMuseums
//
//  Created by Developer on 24/07/18.
//  Copyright © 2018 Exalture. All rights reserved.
//

import Foundation
import Alamofire
import CocoaLumberjack

public class QatarMuseumError : NSObject {
    var code: Int
    var message: String?
    
    init(data: NSDictionary) {
        self.code = data["code"] as! Int
        if let message = data["message"] as? String {
            self.message = message
        }
    }
}

enum BackendError: Error {
    case Network(error: NSError)
    case AlamofireError(error: AFError)
    case JSONSerialization(error: NSError)
    case ObjectSerialization(reason: String)
    case Internal(error: QatarMuseumError)
}

public protocol ResponseObjectSerializable {
    init?(response: HTTPURLResponse, representation: AnyObject)
}

public protocol ResponseCollectionSerializable {
    static func collection(response: HTTPURLResponse, representation: AnyObject) -> [Self]
}

extension ResponseCollectionSerializable where Self: ResponseObjectSerializable {
    static func collection(response: HTTPURLResponse, representation: AnyObject) -> [Self] {
        var collection = [Self]()
        
        if let representation = representation as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = Self(response: response, representation: itemRepresentation as AnyObject) {
                    collection.append(item)
                }
            }
        }
        return collection
    }
}

extension DataRequest {
    func responseObject<T: ResponseObjectSerializable>(
        
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            guard error == nil || !(error is AFError) else {
                return .failure(BackendError.AlamofireError(error: error as! AFError)) }
            print(request)
            guard error == nil || !(error is NSError) else {
                return .failure(BackendError.Network(error: error as! NSError)) }
            
            let jsonResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonResponseSerializer.serializeResponse(request, response, data, error)
            guard case let .success(jsonObject) = result else {
                return .failure(BackendError.JSONSerialization(error: result.error! as NSError))
            }
            
            guard let response = response, let responseObject = T(response: response, representation: jsonObject as AnyObject) else {
                return .failure(BackendError.ObjectSerialization(reason: "JSON could not be serialized: \(jsonObject)"))
            }
            return .success(responseObject)
        }
        
        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    func responseCollection<T: ResponseCollectionSerializable>(
        queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
            guard error == nil || !(error is AFError) else {
                return .failure(BackendError.AlamofireError(error: error as! AFError)) }
            
            guard error == nil || !(error is NSError) else {
                return .failure(BackendError.Network(error: error as! NSError)) }
            
            let jsonSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonSerializer.serializeResponse(request, response, data, nil)
            
            guard case let .success(jsonObject) = result else {
                return .failure(BackendError.JSONSerialization(error: result.error! as NSError))
            }
            
            guard let response = response else {
                let reason = "Response collection could not be serialized due to nil response."
                return .failure(BackendError.ObjectSerialization(reason: reason))
            }
            
            return .success(T.collection(response: response, representation: jsonObject as AnyObject))
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

