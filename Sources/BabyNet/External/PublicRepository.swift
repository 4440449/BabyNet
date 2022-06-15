//
//  PublicRepository.swift
//  BabyNet
//
//  Created by Max on 10.01.2022.
//

import Foundation


public protocol BabyNetRepositoryProtocol {
    
    func connect<D: Decodable>(url: BabyNetURL,
                               request: BabyNetRequest,
                               session: BabyNetSession,
                               decoderType: D.Type?,
                               callback: @escaping (Result <D, Error>) -> ()) -> URLSessionTask?
}


public final class BabyNetRepository: BabyNetRepositoryProtocol {
    
    //Для тестирования - подменять маппер на заглушку после инициализации
    let dtoMapper: BabyNetDTOMapperProtocol
    
    public init() {
        self.dtoMapper = BabyNetDTOMapper()
    }
    
    
    public func connect<D: Decodable>(url: BabyNetURL,
                                      request: BabyNetRequest,
                                      session: BabyNetSession,
                                      decoderType: D.Type?,
                                      callback: @escaping (Result <D, Error>) -> ()) -> URLSessionTask? {
        do {
            let urlSession = session.createSession()
            let urlRequest = try request.createRequest(url: url)
            return dtoMapper.request(request: urlRequest,
                                     session: urlSession,
                                     decoderType: decoderType,
                                     callback)
        } catch let requestGenerationError {
            callback(.failure(requestGenerationError));
            return nil
        }
    }
    
}
