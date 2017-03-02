//
//  CompletionResult.swift
//  Pokedex
//
//  Created by Nejc on 2.3.2017.
//  Copyright © 2017 nejc. All rights reserved.
//

import Foundation

enum CompletionResult<T> {
    case success(T)
    case error(Error)
    func unwrap() throws -> T {
        switch self {
        case let .success(value):
            return value
        case let .error(error):
            throw error
        }
    }
}

typealias Completion<T> = (CompletionResult<T>) -> ()
