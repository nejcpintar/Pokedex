//
//  DataModel.swift
//  Pokedex
//
//  Created by Nejc on 27.2.2017.
//  Copyright © 2017 nejc. All rights reserved.
//

import Foundation
import Unbox

typealias Id = String

protocol User {
    var username: String { get }
    var email: String { get }
}

struct OtherUser: User {
    let username: String
    let email: String
}

extension OtherUser: Unboxable {
    init(unboxer: Unboxer) throws {
        email = try unboxer.unbox(keyPath: "attributes.email")
        username = try unboxer.unbox(keyPath: "attributes.username")
    }
}

struct AuthenticatedUser: User {
    let username: String
    let email: String
    let authToken: String
}

extension AuthenticatedUser: Unboxable {
    init(unboxer: Unboxer) throws {
        email = try unboxer.unbox(keyPath: "attributes.email")
        username = try unboxer.unbox(keyPath: "attributes.username")
        authToken = try unboxer.unbox(keyPath: "attributes.auth-token")
    }
}

struct Comment {
    let id: Id
    let content: String
    let createdAt: Date
    let authorId: String
}

extension Comment: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(keyPath: "id")
        content = try unboxer.unbox(keyPath: "attributes.content")
        createdAt = try Date(jsonString: try unboxer.unbox(keyPath: "attributes.created-at"))
        authorId = try unboxer.unbox(keyPath: "relationships.author.data.id")
    }
}

struct Type {
    let id: Id
    let name: String
}

extension Type: Unboxable {
    init(unboxer: Unboxer) throws {
            id = try unboxer.unbox(keyPath: "id")
            name = try unboxer.unbox(keyPath: "attributes.name")
    }
}

struct Move {
    let id: Id
    let name: String
    let accuracy: Int
    let priority: Int
    let power: Int
    let generation: String
    let typeId: String
}

extension Move: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(keyPath: "id")
        name = try unboxer.unbox(keyPath: "attributes.name")
        accuracy = try unboxer.unbox(keyPath: "attributes.accuracy")
        priority = try unboxer.unbox(keyPath: "attributes.priority")
        power = try unboxer.unbox(keyPath: "attributes.power")
        generation = try unboxer.unbox(keyPath: "generation")
        typeId = try unboxer.unbox(keyPath: "relationships.type.data.id")
        
    }
}

struct Pokemon {
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
    
    let id: Id
    let name: String
    let baseExperience: Int
    let height: Double
    let weight: Double
    let createdAt: Date
    let updatedAt: Date
    let imageUrl: URL?
    let description: String
    let voteCount: Int
    let votedOn: Int
    let gender: Gender
    let typeIds: [Id]
    let moveIds: [Id]
    let commentIds: [Id]
}

extension Pokemon: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(keyPath: "id")
        name = try unboxer.unbox(keyPath: "attributes.name")
        baseExperience = try unboxer.unbox(keyPath: "attributes.base-experience")
        height = try unboxer.unbox(keyPath: "attributes.height")
        weight = try unboxer.unbox(keyPath: "attributes.width")
        createdAt = try Date(jsonString: try unboxer.unbox(keyPath: "attributes.created-at"))
        updatedAt = try Date(jsonString: try unboxer.unbox(keyPath: "attributes.updated-at"))
        imageUrl = unboxer.unbox(keyPath: "attributes.image-url")
        description = try unboxer.unbox(keyPath: "attributes.description")
        voteCount = try unboxer.unbox(keyPath: "attributes.total-vote-count")
        votedOn = try unboxer.unbox(keyPath: "attributes.voted-on")
        gender = Gender(string: try unboxer.unbox(keyPath: "attributes.gender"))
        
        let types: Array<UnboxableDictionary> = try unboxer.unbox(keyPath: "relationships.types")
        typeIds = types.map { $0["id"] as! String }
        let comments: Array<UnboxableDictionary> = try unboxer.unbox(keyPath: "relationships.comments")
        commentIds = comments.map { $0["id"] as! String }
        let moves: Array<UnboxableDictionary> = try unboxer.unbox(keyPath: "relationships.moves")
        moveIds = moves.map { $0["id"] as! String }
        
    }
}

