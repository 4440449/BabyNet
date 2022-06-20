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
                               responseCallback: @escaping (Result <D, Error>) -> (),
                               taskProgressCallback: ((Progress) -> ())?) -> URLSessionTask?
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
                                      responseCallback: @escaping (Result <D, Error>) -> (),
                                      taskProgressCallback: ((Progress) -> ())?) -> URLSessionTask? {
        do {
            let urlSession = session.createSession()
            let urlRequest = try request.createRequest(url: url)
            return dtoMapper.request(request: urlRequest,
                                     session: urlSession,
                                     decoderType: decoderType,
                                     responseCallback: responseCallback,
                                     taskProgressCallback: taskProgressCallback)
        } catch let requestGenerationError {
            responseCallback(.failure(requestGenerationError));
            return nil
        }
    }
    
}
