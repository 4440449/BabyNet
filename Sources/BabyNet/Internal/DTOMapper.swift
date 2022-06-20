//
//  DTOMapper.swift
//  BabyNet
//
//  Created by Max on 05.01.2022.
//  Copyright © 2022 Max. All rights reserved.
//

import Foundation


protocol BabyNetDTOMapperProtocol {
    
    func request<D: Decodable>(request: URLRequest,
                               session: URLSession,
                               decoderType: D.Type?,
                               responseCallback callback: @escaping (Result<D, Error>) -> (),
                               taskProgressCallback: ((Progress) -> ())?) -> URLSessionTask?
}


final class BabyNetDTOMapper: BabyNetDTOMapperProtocol {
    
    //Для тестирования - подменять клиент на заглушку после инициализации
    let client: BabyNetClientProtocol
    
    init() {
        self.client = BabyNetClient()
    }
    
    func request<D: Decodable>(request: URLRequest,
                               session: URLSession,
                               decoderType: D.Type?,
                               responseCallback callback: @escaping (Result<D, Error>) -> (),
                               taskProgressCallback: ((Progress) -> ())?) -> URLSessionTask? {
        return client.execute(request: request, session: session, responseCallback: { result in
            switch result {
                // .success
            case let .success(data):
                //Если пришел декодер, попытаться распарсить им raw data
                if let decoder = decoderType {
                    do {
                        let networkEntity = try JSONDecoder().decode(decoder, from: data)
                        callback(.success(networkEntity))
                    } catch let error {
                        callback(.failure(BabyNetError.parseToDomain("Error parse to domain, system message --> \(error)")))
                    }
                // если декодер не пришел, попытаться сопоставить тип ожидаемых данных с типом raw data
                } else if let data = data as? D {
                    callback(.success(data))
                } else {
                // если не получается сопоставить, выкидываю ошибку
                // П.С. Если декодер не положили в вызов, то ожидаемые данные могут быть только типа Result<Data, Error>)
                    callback(.failure(BabyNetError.parseToDomainResultTypeCasting("Error typecasting! The expected result type \(D.self) must be the same type as raw Data - \(data)")))
                }
                // .failure
            case let .failure(error): callback(.failure(error))
            }
        }, taskProgressCallback: taskProgressCallback)
    }
}


//        return client.execute(request: request, session: session) { result in
//            switch result {
//            case let .success(data):
//                guard let decoder = decoderType else {
//                    guard let data = data as? R else { callback(.failure(BabyNetError.parseToDomainResultTypeCasting("Error typecasting! recieved raw Data type: \(data.self) cannot be casting to expect result type: \(R.self)")));
//                        return
//                    }
//                    callback(.success(data));
//                    return
//                }
//                do {
//                    let networkEntity = try JSONDecoder().decode(decoder.self, from: data)
//                    let domainEntity = try networkEntity.parseToDomain()
//                    guard let resultDomainEntity = domainEntity as? R else { callback(.failure(BabyNetError.parseToDomainResultTypeCasting("Error typecasting! domainEntity: \(domainEntity) cannot be casting to expect result type: \(R.self)")));
//                        return
//                    }
//                    callback(.success(resultDomainEntity))
//                } catch let error {
//                    callback(.failure(error))
//                }
//            case let .failure(error): callback(.failure(error))
//            }
//        }
//    }
//}





//if let networkEntity = try? JSONDecoder().decode(D.self, from: data) {
//                        let domainEntity = try networkEntity.parseToDomain()
//                    } else {
//                        let networkEntity = try JSONDecoder().decode([D].self, from: data)
//                        let domainEntity = try networkEntity.forEach { element in
//                            try element.parseToDomain()
//                        }
//                    }
