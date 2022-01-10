//
//  PrivateExtensions.swift
//  BabyNet
//
//  Created by Max on 10.01.2022.
//

import Foundation


// MARK: - Client Config

extension Encodable {
    func jsonEncode() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

// MARK: - Public Repository

extension URLRequest {
    //STUB! Т_T
    // TODO: Заменить на реализацию NSURLRequest?
    init() {
        self.init(url: URL(string: "")!)
    }
}
