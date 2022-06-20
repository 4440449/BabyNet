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
                 responseCallback: @escaping (Result<Data, Error>) -> (),
                 taskProgressCallback: ((Progress) -> ())?) -> URLSessionTask?
}


final class BabyNetClient: BabyNetClientProtocol {
    
    func execute(request: URLRequest,
                 session: URLSession,
                 responseCallback: @escaping (Result<Data, Error>) -> (),
                 taskProgressCallback: ((Progress) -> ())?) -> URLSessionTask? {
        
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
        let _ = dataTask.progress.observe(\.fractionCompleted) { progress, changedValue in
            print("progress == \(progress)")
            print("changedValue == \(changedValue)")
            taskProgressCallback?(progress)
        }
        dataTask.resume()
        return dataTask
    }
    
}
