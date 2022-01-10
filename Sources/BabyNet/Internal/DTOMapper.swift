//
//  DTOMapper.swift
//  BabyNet
//
//  Created by Max on 05.01.2022.
//  Copyright © 2022 Max. All rights reserved.
//

import Foundation


protocol BabyNetDTOMapperProtocol {
    
    func request<D: Decodable & DomainRepresentable, R>(request: URLRequest,
                                                        session: URLSession,
                                                        decoderType: D.Type,
                                                        _ callback: @escaping (Result<R, Error>) -> ()) -> URLSessionTask?
}


final class BabyNetDTOMapper: BabyNetDTOMapperProtocol {
    
    private let client: BabyNetClientProtocol
    
    init() {
        self.client = BabyNetClient()
    }
    
    func request<D: Decodable & DomainRepresentable, R>(request: URLRequest,
                                                        session: URLSession,
                                                        decoderType: D.Type,
                                                        _ callback: @escaping (Result<R, Error>) -> ()) -> URLSessionTask? {
        return client.execute(request: request, session: session) { result in
            switch result {
            case let .success(data):
                do {
                    let networkEntity = try JSONDecoder().decode(D.self, from: data)
                    let domainEntity = try networkEntity.parseToDomain()
                    guard let resultDomainEntity = domainEntity as? R else { callback(.failure(BabyNetError.parseToDomainResultTypeCasting("Error typecasting! domainEntity: \(domainEntity) cannot be casting to expect result type: \(R.self)"))); return
                    }
                    callback(.success(resultDomainEntity))
                } catch {
                    callback(.failure(error))
                }
            case let .failure(error): callback(.failure(error))
            }
        }
    }
}

