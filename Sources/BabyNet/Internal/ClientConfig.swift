//
//  ClientConfig.swift
//  BabyNet
//
//  Created by Max on 05.01.2022.
//  Copyright © 2022 Max. All rights reserved.
//

import Foundation


public struct BabyNetURL {
    
    private let scheme: String
    private let host: String
    private let path: String
    private let endPoint: [String : String]?
    
    
    public enum Scheme: String {
        case http  = "http"
        case https = "https"
    }
    
    //    external init
    public init(scheme: Scheme, host: String, path: String, endPoint: [String : String]?) {
        self.scheme = scheme.rawValue
        self.host = host
        self.path = path
        self.endPoint = endPoint
    }
    
    
    func createURL() throws -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        if let endPoint = endPoint { urlComponents.queryItems = []; endPoint.forEach {
            urlComponents.queryItems?.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        }
        guard let url = urlComponents.url else {
            throw BabyNetError.urlCreate("Invalid URL --- URLComponents log: \(urlComponents.debugDescription)")
        }
        return url
    }
    
}


// MARK: - Request

public struct BabyNetRequest {
    
    //    private let url: BabyNetURL
    private let method: HTTPMethod
    private var header: [String : String]?
    private var body: Encodable?
    
    
    public enum HTTPMethod: String {
        case get     = "GET"
        case post    = "POST"
        case patch   = "PATCH"
        case delete  = "DELETE"
    }
    
    // external init
    public init(method: HTTPMethod, header: [String : String]?, body: Encodable?) {
        self.method = method
        self.header = header
        self.body = body
    }
    
    
    func createRequest(url: BabyNetURL) throws -> URLRequest {
        let url = try url.createURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        if let header = header {
            header.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        }
        if let body = body {
            urlRequest.httpBody = try body.jsonEncode()
        }
        //        print("body.jsonEncode() == \(String(data: try body.jsonEncode(), encoding: .utf8)!)")
        return urlRequest
    }
    
}


// MARK: - Session

public enum BabyNetSession {
    case `default`
    
    func createSession() -> URLSession {
        switch self {
        case .default:
            return URLSession(configuration: .default)
        }
    }
}


// MARK: - Errors

public enum BabyNetError: Error {
    case urlCreate(String)
    case badRequest(Error)
    case badResponse(String)
    case parseToDomain(String)
    case parseToDomainResultTypeCasting(String)
}




