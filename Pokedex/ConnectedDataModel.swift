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
}

extension ConnectedDataModel: DataModel {
    func getPokemons(onCompleted: @escaping Completion<[Pokemon]>) {
        networkManager.retrievePokemons(onCompleted: onCompleted)
    }
    
    func getCommentsFor(pokemon: Pokemon, onCompleted: @escaping Completion<[Comment]>) {
        networkManager.retrieveCommentsFor(pokemon: pokemon, onCompleted: onCompleted)
    }
    
    func getAuthorFor(comment: Comment, onCompleted: @escaping Completion<User>) {
        networkManager.retrieveAuthorFor(comment: comment, onCompleted: onCompleted)
    }
    
    func getTypesFor(pokemon: Pokemon, onCompleted: @escaping Completion<[Type]>) {
        networkManager.retrieveTypes { result in
            do {
                let types = try result.unwrap()
                let filtered = types
                    .filter { key, value in return pokemon.typeIds.contains(key) }
                    .map { $0.value }
                onCompleted(.success(filtered))
            } catch {
                onCompleted(.error(error))
            }
            
        }
    }
    
    func getMovesFor(pokemon: Pokemon,  onCompleted: @escaping Completion<[Move]>) {
        networkManager.retrieveMoves { result in
            do {
                let moves = try result.unwrap()
                let filtered = moves
                    .filter { key, value in return pokemon.moveIds.contains(key) }
                    .map { $0.value }
                onCompleted(.success(filtered))
            } catch {
                onCompleted(.error(error))
            }
        }
    }
    
    func store(pokemon: Pokemon, onCompleted: @escaping Completion<Pokemon>) {
        networkManager.upload(pokemon: pokemon, onCompleted: onCompleted)
    }
    
    func store(comment: Comment, forPokemon: Pokemon, onCompleted: @escaping Completion<(Comment, Pokemon)>) {
        networkManager.upload(comment: comment, forPokemon: forPokemon, onCompleted: onCompleted)
    }
}
