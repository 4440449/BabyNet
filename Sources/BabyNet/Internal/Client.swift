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
                 callback: @escaping (Result<Data, Error>) -> ()) -> URLSessionTask?
}


final class BabyNetClient: BabyNetClientProtocol {
    
    func execute(request: URLRequest,
                 session: URLSession,
                 callback: @escaping (Result<Data, Error>) -> ()) -> URLSessionTask? {
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                // сервер не ответил
                callback(.failure(BabyNetError.badRequest(error!)) );
                return
            }
            guard let data = data, (200...299).contains(httpResponse.statusCode) else {
                // сервер ответил неудачно
                callback(.failure(BabyNetError.badResponse("\(httpResponse.statusCode)")) );
                return
            }
            callback(.success(data))
        }
        dataTask.resume()
        return dataTask
    }
    
}
