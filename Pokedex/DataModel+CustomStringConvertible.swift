//
//  DataModel+CustomStringConvertible.swift
//  Pokedex
//
//  Created by Nejc on 2.3.2017.
//  Copyright © 2017 nejc. All rights reserved.
//

import Foundation

extension OtherUser: CustomStringConvertible {
    var description: String {
        return "user: [id: \(id), username: \(username), email: \(email)]"
    }
}

extension AuthenticatedUser: CustomStringConvertible {
    var description: String {
        return "user: [id: \(id), username: \(username), email: \(email)]"
    }
}

extension Comment: CustomStringConvertible {
    var description: String {
        return "comment: [id: \(id), content: \(content), createdAt: \(createdAt), author: \(authorId)]"
    }
}

extension Type: CustomStringConvertible {
    var description: String {
        return "type: [id: \(id), name: \(name)]"
    }
}

extension Move: CustomStringConvertible {
    var description: String {
        return "move: [id: \(id), name:\(name), accuracy: \(accuracy), priority: \(priority), power: \(power), generation: \(generation), typeId: \(typeId)]"
    }
}

extension Pokemon: CustomStringConvertible {
    var description: String {
        return "pokemon: [id: \(id), name: \(name), baseExperience: \(baseExperience), height: \(height), weight: \(weight), createdAt: \(createdAt), updatedAt: \(updatedAt), imageUrl: \(imageUrl), description: \(about), voteCount: \(voteCount), votedOn: \(votedOn), gender: \(gender), types: \(typeIds), moves: \(moveIds), comments: \(commentIds)]"
    }
}
