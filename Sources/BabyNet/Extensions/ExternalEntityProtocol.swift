//
//  File.swift
//  
//
//  Created by Max on 05.01.2022.
//


public protocol DomainRepresentable {
    associatedtype DomainEntity
    func parseToDomain() throws -> DomainEntity
}
