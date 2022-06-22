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
                               observationCallback:((NSKeyValueObservation) -> ())?,
                               taskProgressCallback: ((Progress) -> ())?,
                               responseCallback: @escaping (Result<D, Error>) -> ()) -> URLSessionTask?
    
    func connectWithSessionDelegate(url: BabyNetURL,
                                    request: BabyNetRequest,
                                    session: BabyNetSession,
                                    sessionDelegate: URLSessionDataDelegate,
                                    delegateQueue: OperationQueue?) -> URLSessionTask?
}


public final class BabyNetRepository: BabyNetRepositoryProtocol {
    
    //Для тестирования - подменять маппер на заглушку после инициализации
    let dtoMapper: BabyNetDTOMapperProtocol
    
    public init() {
        self.dtoMapper = BabyNetDTOMapper()
    }
    
    
    // MARK: - With completion response

    public func connect<D: Decodable>(url: BabyNetURL,
                                      request: BabyNetRequest,
                                      session: BabyNetSession,
                                      decoderType: D.Type?,
                                      observationCallback:((NSKeyValueObservation) -> ())?,
                                      taskProgressCallback: ((Progress) -> ())?,
                                      responseCallback: @escaping (Result<D, Error>) -> ()) -> URLSessionTask? {
        do {
            let urlSession = session.createSession(delegate: nil,
                                                   queue: nil)
            let urlRequest = try request.createRequest(url: url)
            return dtoMapper.request(request: urlRequest,
                                     session: urlSession,
                                     decoderType: decoderType,
                                     observationCallback: observationCallback,
                                     taskProgressCallback: taskProgressCallback,
                                     responseCallback: responseCallback)
        } catch let requestGenerationError {
            responseCallback(.failure(requestGenerationError));
            return nil
        }
    }
    
    
    // MARK: - With delegate response

    public func connectWithSessionDelegate(url: BabyNetURL,
                                           request: BabyNetRequest,
                                           session: BabyNetSession,
                                           sessionDelegate: URLSessionDataDelegate,
                                           delegateQueue: OperationQueue?) -> URLSessionTask? {
        let urlSession = session.createSession(delegate: sessionDelegate,
                                               queue: delegateQueue)
        do {
            let urlRequest = try request.createRequest(url: url)
            return dtoMapper.requestWithSessionDelegate(request: urlRequest,
                                                        session: urlSession)
        } catch let requestGenerationError {
            //протестить возврат ошибки
            urlSession.delegate?.urlSession?(urlSession,
                                             didBecomeInvalidWithError: requestGenerationError)
            return nil
        }
    }
    
}
