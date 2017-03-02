//
//  DataModel+Unbox.swift
//  Pokedex
//
//  Created by Nejc on 2.3.2017.
//  Copyright © 2017 nejc. All rights reserved.
//

import Foundation
import Unbox

extension AuthenticatedUser: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(keyPath: "id")
        email = try unboxer.unbox(keyPath: "attributes.email")
        username = try unboxer.unbox(keyPath: "attributes.username")
        authToken = try unboxer.unbox(keyPath: "attributes.auth-token")
    }
}

extension OtherUser: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(keyPath: "id")
        email = try unboxer.unbox(keyPath: "attributes.email")
        username = try unboxer.unbox(keyPath: "attributes.username")
    }
}

extension Comment: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(keyPath: "id")
        content = try unboxer.unbox(keyPath: "attributes.content")
        createdAt = try Date(jsonString: try unboxer.unbox(keyPath: "attributes.created-at"))
        authorId = try unboxer.unbox(keyPath: "relationships.author.data.id")
    }
}

extension Type: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(keyPath: "id")
        name = try unboxer.unbox(keyPath: "attributes.name")
    }
}

extension Move: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(keyPath: "id")
        name = try unboxer.unbox(keyPath: "attributes.name")
        accuracy = unboxer.unbox(keyPath: "attributes.accuracy")
        priority = unboxer.unbox(keyPath: "attributes.priority")
        power = unboxer.unbox(keyPath: "attributes.power")
        generation = unboxer.unbox(keyPath: "generation")
        typeId = try unboxer.unbox(keyPath: "relationships.type.data.id")
        
    }
}

extension Pokemon: Unboxable {
    init(unboxer: Unboxer) throws {
        id = try unboxer.unbox(keyPath: "id")
        name = try unboxer.unbox(keyPath: "attributes.name")
        baseExperience = unboxer.unbox(keyPath: "attributes.base-experience")
        height = unboxer.unbox(keyPath: "attributes.height")
        weight = unboxer.unbox(keyPath: "attributes.weight")
        createdAt = try Date(jsonString: try unboxer.unbox(keyPath: "attributes.created-at"))
        updatedAt = try Date(jsonString: try unboxer.unbox(keyPath: "attributes.updated-at"))
        imageUrl = unboxer.unbox(keyPath: "attributes.image-url")
        about = unboxer.unbox(keyPath: "attributes.description")
        voteCount = unboxer.unbox(keyPath: "attributes.total-vote-count")
        votedOn = unboxer.unbox(keyPath: "attributes.voted-on")
        gender = Gender(string: try unboxer.unbox(keyPath: "attributes.gender"))
        
        let types: Array<UnboxableDictionary> = try unboxer.unbox(keyPath: "relationships.types.data")
        typeIds = try types.map { try Id(id:$0["id"]) }
        let comments: Array<UnboxableDictionary> = try unboxer.unbox(keyPath: "relationships.comments.data")
        commentIds = try comments.map { try Id(id:$0["id"]) }
        let moves: Array<UnboxableDictionary> = try unboxer.unbox(keyPath: "relationships.moves.data")
        moveIds = try moves.map { try Id(id:$0["id"]) }
        
    }
}
