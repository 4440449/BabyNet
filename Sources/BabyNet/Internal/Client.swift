//
//  Client.swift
//  BabyNet
//
//  Created by Max on 05.01.2022.
//  Copyright © 2022 Max. All rights reserved.
//

import Foundation


protocol BabyNetClientProtocol {
    
    func execute(request: URLRequest,
                 session: URLSession,
                 observationCallback:((NSKeyValueObservation) -> ())?,
                 taskProgressCallback: ((Progress) -> ())?,
                 responseCallback: @escaping (Result<Data, Error>) -> ()) -> URLSessionTask?
    
    func executeWithSessionDelegate(request: URLRequest,
                                    session: URLSession) -> URLSessionTask?
}


final class BabyNetClient: BabyNetClientProtocol {
    
    
    // MARK: - With completion response

    func execute(request: URLRequest,
                 session: URLSession,
                 observationCallback:((NSKeyValueObservation) -> ())?,
                 taskProgressCallback: ((Progress) -> ())?,
                 responseCallback: @escaping (Result<Data, Error>) -> ()) -> URLSessionTask? {
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                // сервер не ответил
                responseCallback(.failure(BabyNetError.badRequest(error!)) );
                return
            }
            guard let data = data, (200...299).contains(httpResponse.statusCode) else {
                // сервер ответил неудачно
                responseCallback(.failure(BabyNetError.badResponse("\(httpResponse.statusCode)")) );
                return
            }
            responseCallback(.success(data))
        }
        
        if let _ = taskProgressCallback, let _ = observationCallback {
            let observation = dataTask.progress.observe(\.fractionCompleted) { progress, _ in
                taskProgressCallback!(progress)
            }
            observationCallback!(observation)
        }
        dataTask.resume()
        return dataTask
    }
    
    
    // MARK: - With delegate response

    func executeWithSessionDelegate(request: URLRequest,
                                    session: URLSession) -> URLSessionTask? {
        let dataTask = session.dataTask(with: request)
        dataTask.resume()
        return dataTask
    }
    
}
