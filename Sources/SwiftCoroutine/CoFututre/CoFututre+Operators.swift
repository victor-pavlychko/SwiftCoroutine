//
//  CoFututre+Operators.swift
//  SwiftCoroutine
//
//  Created by Alex Belozierov on 20.12.2019.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

import Foundation

extension CoFuture {
    
    // MARK: - Transform
    
    public func transform<T>(_ transformer: @escaping (OutputResult) throws -> T) -> CoFuture<T> {
        CoTransformFuture(parent: self, transformer: transformer)
    }
    
    // MARK: - Map output
    
    @inlinable public func transformValue<T>(_ transformer: @escaping (Output) throws -> T) -> CoFuture<T> {
        transform { result in try transformer(result.get()) }
    }
    
    // MARK: - On result
    
    @discardableResult
    public func onResult(on dispatcher: Dispatcher? = nil, execute completion: @escaping Completion) -> CoFuture<Output> {
        let completion = dispatcher.map { dispatcher in
            { result in dispatcher.perform { completion(result) }}
        } ?? completion
        mutex.lock()
        if let result = result {
            mutex.unlock()
            completion(result)
        } else {
            addCompletion(completion: completion)
            mutex.unlock()
        }
        return self
    }
    
    @inlinable @discardableResult
    public func onResult(on dispatcher: Dispatcher? = nil, execute completion: @escaping () -> Void) -> CoFuture<Output> {
        onResult(on: dispatcher) { _ in completion() }
    }
    
    // MARK: - On success
    
    @inlinable @discardableResult
    public func onSuccess(on dispatcher: Dispatcher? = nil, execute handler: @escaping (Output) -> Void) -> CoFuture<Output> {
        onResult(on: dispatcher) {
            if case .success(let output) = $0 { handler(output) }
        }
    }
    
    // MARK: - On error
    
    @inlinable @discardableResult
    public func onError(on dispatcher: Dispatcher? = nil, execute handler: @escaping (Error) -> Void) -> CoFuture<Output> {
        onResult(on: dispatcher) {
            if case .failure(let error) = $0 { handler(error) }
        }
    }
    
}
