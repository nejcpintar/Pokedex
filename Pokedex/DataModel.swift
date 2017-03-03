//
//  DataModel.swift
//  Pokedex
//
//  Created by Nejc on 27.2.2017.
//  Copyright © 2017 nejc. All rights reserved.
//

import Foundation
import UIKit

protocol DataModel {
    func getPokemons(onCompleted: @escaping Completion<[Pokemon]>)
    func getCommentsFor(pokemon: Pokemon, onCompleted: @escaping Completion<[Comment]>)
    func getAuthorFor(comment: Comment, onCompleted: @escaping Completion<User>)
    func getTypesFor(pokemon: Pokemon, onCompleted: @escaping Completion<[Type]>)
    func getMovesFor(pokemon: Pokemon, onCompleted: @escaping Completion<[Move]>)
    func store(comment: Comment, forPokemon: Pokemon, onCompleted: @escaping Completion<(Comment, Pokemon)>)
    func store(pokemon: Pokemon, onCompleted: @escaping Completion<Pokemon>)
}

typealias Id = String

enum IdError: Error {
    case idNotConvertible
}

extension Id {
    init(id: Any?) throws {
        switch id {
        case is Int, is String:
            self = "\(id)"
        default:
            throw IdError.idNotConvertible
        }
    }
}

protocol Identified {
    var id: Id { get }
}

func identifiedArrayToDictionary<T> (_ array: [T]) -> [Id: T] where T: Identified { //Couldn't constrain the array extension enough
    return array.reduce(Dictionary<Id, T>()) { result, value in
        var rval = result
        rval[value.id] = value
        return rval
        
    }
}

protocol User: Identified {
    var id: Id { get }
    var username: String { get }
    var email: String { get }
}

struct OtherUser: User {
    let id: Id
    let username: String
    let email: String
}

struct AuthenticatedUser: User {
    let id: Id
    let username: String
    let email: String
    let authToken: String
}

struct Comment: Identified {
    let id: Id
    let content: String
    let createdAt: Date
    let authorId: String
}

struct Type: Identified {
    let id: Id
    let name: String
}

struct Move: Identified {
    let id: Id
    let name: String
    let accuracy: Int?
    let priority: Int?
    let power: Int?
    let generation: String?
    let typeId: String
}

struct Pokemon: Identified {
    let id: Id
    let name: String
    let baseExperience: Int?
    let height: Double?
    let weight: Double?
    let createdAt: Date
    let updatedAt: Date
    let imageUrl: URL?
    let about: String?
    let voteCount: Int?
    let votedOn: Int?
    let gender: Gender
    let typeIds: [Id]
    let moveIds: [Id]
    let commentIds: [Id]
    
    enum Gender {
        case male
        case female
        case unknown
        
        init(string: String) {
            switch string.lowercased() {
            case "male":
                self = .male
            case "female":
                self = .female
            default:
                self = .unknown
            }
        }
    }
}

