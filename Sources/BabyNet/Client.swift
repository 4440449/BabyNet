//
//  Client.swift
//  BabyNet
//
//  Created by Max on 05.01.2022.
//  Copyright © 2022 Max. All rights reserved.
//

import Foundation


public protocol BabyNetClientProtocol {
    
    func execute(callback: @escaping (Result<Data, Error>) -> ())
}


public final class BabyNetClient: BabyNetClientProtocol {
    
    private let requestConfig: BabyNetRequest
    private let sessionConfig: BabyNetSession
    
    public init(requestConfig: BabyNetRequest, sessionConfig: BabyNetSession) {
        self.requestConfig = requestConfig
        self.sessionConfig = sessionConfig
    }
    
    public func execute(callback: @escaping (Result<Data, Error>) -> ()) {
        do {
            let request = try self.requestConfig.createRequest()
            let session = self.sessionConfig.createSession()
            
            let dataTask = session.dataTask(with: request) { data, response, error in
                guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                    // сервер не ответил
                    callback(.failure(BabyNetError.badRequest(error!)) ); return }
                guard let data = data, (200...299).contains(httpResponse.statusCode) else {
                    // сервер ответил неудачно
                    callback(.failure(BabyNetError.badResponse("\(httpResponse.statusCode)")) ); return }
                //                        -- \(httpResponse.allHeaderFields)")) ); return }
                callback(.success(data))
            }
            dataTask.resume()
            
        } catch let requestGeneration {
            callback(.failure(requestGeneration))
        }
    }
    
}
