//
//  ConnectedDataModel.swift
//  Pokedex
//
//  Created by Nejc on 2.3.2017.
//  Copyright © 2017 nejc. All rights reserved.
//

import Foundation
import UIKit

final class ConnectedDataModel {
    let networkManager = NetworkManager.shared
    
    let imageCache = NSCache<NSString, UIImage>()
    var retrievedAllPokemons = false
    var pokemons = [Id: Pokemon]()
    var comments = [Id: Comment]()
    var types = [Id: Type]()
    var moves = [Id: Move]()
    var users = [Id: User]()
}

extension ConnectedDataModel: DataModel {
    func getPokemons(onCompleted: @escaping Completion<[Pokemon]>) {
        if retrievedAllPokemons {
            onCompleted(.success(Array(pokemons.values)))
            return
        }
        
        networkManager.retrievePokemons(onCompleted: onCompleted)
    }
    
    func getCommentsFor(pokemon: Pokemon, onCompleted: @escaping Completion<[Comment]>) {
        let comments =
            self.comments
                .filter { key, comment -> Bool in pokemon.commentIds.contains(key) }
                .map { $0.value }
                .sorted { $0.createdAt > $1.createdAt }
        
        if comments.count == pokemon.commentIds.count {
            onCompleted(.success(comments))
            return
        }
        
        networkManager.retrieveCommentsFor(pokemon: pokemon, onCompleted: onCompleted)
    }
    
    func getAuthorFor(comment: Comment, onCompleted: @escaping Completion<User>) {
        if let author = users[comment.authorId] {
            onCompleted(.success(author))
            return
        }
        
        networkManager.retrieveAuthorFor(comment: comment, onCompleted: onCompleted)
    }
    
    func getTypesFor(pokemon: Pokemon, onCompleted: @escaping Completion<[Type]>) {
        func filterTypes() -> [Type] {
            return self.types
                .filter { key, value in return pokemon.typeIds.contains(key) }
                .map { $0.value }
        }
        
        var types = filterTypes()
        
        if types.count == pokemon.typeIds.count {
            onCompleted(.success(types))
            return
        }
        
        networkManager.retrieveTypes { _ in
            types = filterTypes()
            onCompleted(.success(types))
        }
    }
    
    func getMovesFor(pokemon: Pokemon,  onCompleted: @escaping Completion<[Move]>) {
        func filter(moves: [Id: Move]) -> [Move] {
            return moves
                .filter { key, value in return pokemon.moveIds.contains(key) }
                .map { $0.value }
        }
        
        let moves = filter(moves: self.moves)
        if moves.count == pokemon.moveIds.count {
            onCompleted(.success(moves))
        }
        
        networkManager.retrieveMoves { retrievedResult in
            switch retrievedResult {
            case let .success(moves):
                onCompleted(.success(filter(moves: moves)))
            case let .error(error):
                onCompleted(.error(error))
            }
        }
    }
    
    func getImageFor(pokemon: Pokemon, onCompleted: @escaping Completion<UIImage>) {
        if
            let url = pokemon.imageUrl,
            let image = imageCache.object(forKey: NSString(string: url.absoluteString)) {
            onCompleted(.success(image))
        }
        
        networkManager.retrieveImageFor(pokemon: pokemon, onCompleted: onCompleted)
    }
    
    func store(pokemon: Pokemon, onCompleted: @escaping Completion<Pokemon>) {
        networkManager.upload(pokemon: pokemon) { pokemon in
            onCompleted(pokemon)
        }
    }
    
    func store(comment: Comment, forPokemon: Pokemon, onCompleted: @escaping Completion<(Comment, Pokemon)>) {
        networkManager.upload(comment: comment, forPokemon: forPokemon, onCompleted: onCompleted)
    }
}
