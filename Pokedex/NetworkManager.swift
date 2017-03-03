//
//  NetworkManager.swift
//  Pokedex
//
//  Created by Nejc on 28.2.2017.
//  Copyright © 2017 nejc. All rights reserved.
//

import Foundation
import Unbox
import Alamofire
import AlamofireImage
import Locksmith

enum NetworkManagerError: Error {
    case noUser
    case noToken
    case noImageUrl
    case couldntRetrieveImage
    case expectedDictionary
    case expectedData
    case apiErrors(errors: [APIError])
}

struct APIError: Unboxable {
    let title: String?
    let detail: String?
    
    init(unboxer: Unboxer) throws {
        title = unboxer.unbox(key: "title")
        detail = unboxer.unbox(key: "detail")
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    init() {
        guard let rootUrl = Bundle.main.infoDictionary?["PokedexApiUrl"] as? String else {
            fatalError("PokedexApiUrl should be set in Info.plist")
        }
        self.rootUrl = rootUrl
        
        user = nil
        
        self.headers = [:]
        self.headers["Accept"] = "application/json"
    }
    
    func isLoggedIn() -> Bool {
        guard
            UserDefaults.standard.value(forKey: Constant.loggedInUserEmail) is String,
            UserDefaults.standard.value(forKey: Constant.loggedInUserId) is Id
        else {
                return false
        }
        return true
    }
    
    func authenticate(onCompleted: @escaping Completion<AuthenticatedUser>) {
        guard
            let email = UserDefaults.standard.value(forKey: Constant.loggedInUserEmail) as? String,
            let id = UserDefaults.standard.value(forKey: Constant.loggedInUserId) as? Id
            else {
                onCompleted(.error(NetworkManagerError.noUser))
                return
        }
        
        guard let token = Locksmith.loadDataForUserAccount(userAccount: email, inService: Constant.serviceName)?["token"] as? String else {
            onCompleted(.error(NetworkManagerError.noToken))
            return
        }
        
        
        setAuthorizationHeader(token: token, email: email)
        
        retrieveUser(id: id) { retrievedResult in
            switch retrievedResult {
            case let .success(user):
                let authUser = AuthenticatedUser(id: id, username: user.username, email: email, authToken: token)
                onCompleted(.success(authUser))
            case let .error(error):
                onCompleted(.error(error))
            }
        }
    }
    
    func login(email: String, password: String, onCompleted: @escaping Completion<AuthenticatedUser>) {
        let params: [String : Any] = ["data": ["type": "session", "attributes": ["email": email, "password": password]]]
        
        retrieve(endpoint: "/api/v1/users/login", method: .get, params: params, onCompleted: onCompleted) { unboxer in
            let user: AuthenticatedUser = try unboxer.unbox(key: "data")
            self.user = user
            
            UserDefaults.standard.set(user.email, forKey: Constant.loggedInUserEmail)
            UserDefaults.standard.set(user.id, forKey: Constant.loggedInUserId)
            UserDefaults.standard.synchronize()
            
            do {
                try Locksmith.saveData(data: ["token": user.authToken], forUserAccount: user.email, inService: Constant.serviceName)
            } catch LocksmithError.duplicate {
                try Locksmith.updateData(data: ["token": user.authToken], forUserAccount: user.email, inService: Constant.serviceName)
            }
            
            self.setAuthorizationHeader(token: user.authToken, email: user.email)
            return user
        }
    }
    
    func register(nickname: String, email: String, password: String, passwordConfirmaton: String, onCompleted: @escaping Completion<AuthenticatedUser>) {
        let params: [String : Any] = ["data": ["type": "users",
                                               "attributes": ["username": nickname,
                                                              "email": email,
                                                              "password": password,
                                                              "password_confirmation": passwordConfirmaton]]]
        
        retrieve(endpoint: "/api/v1/users", method: .post, params: params, onCompleted: onCompleted) { unboxer in
            let user: AuthenticatedUser = try unboxer.unbox(key: "data")
            self.user = user
            
            UserDefaults.standard.set(user.email, forKey: Constant.loggedInUserEmail)
            UserDefaults.standard.set(user.id, forKey: Constant.loggedInUserId)
            UserDefaults.standard.synchronize()
            try Locksmith.saveData(data: ["token": user.authToken], forUserAccount: user.email, inService: Constant.serviceName)
            self.setAuthorizationHeader(token: user.authToken, email: user.email)
            return user
        }
    }
    
    func retrievePokemons( onCompleted: @escaping Completion<[Pokemon]>) {
        retrieve(endpoint: "/api/v1/pokemons", onCompleted: onCompleted) { unboxer in
            let pokemonsArray: [Pokemon] = try unboxer.unbox(key: "data")
            return pokemonsArray
        }
    }
    
    func retrieveCommentsFor(pokemon: Pokemon, onCompleted: @escaping Completion<[Comment]>) {
        retrieve(endpoint: "/api/v1/pokemons/\(pokemon.id)/comments", onCompleted: onCompleted) { unboxer in
            let commentsArray: [Comment] = try unboxer.unbox(key: "data")
            return commentsArray
        }
    }
    
    func retrieveAuthorFor(comment: Comment, onCompleted: @escaping Completion<User>) {
        retrieveUser(id: comment.authorId, onCompleted: onCompleted)
    }
    
    func retrieveTypes(onCompleted: @escaping Completion<[Id: Type]>) {
        retrieve(endpoint: "/api/v1/types", onCompleted: onCompleted) { unboxer in
            let typesArray: [Type] = try unboxer.unbox(key: "data")
            return identifiedArrayToDictionary(typesArray)
        }
    }
    
    func retrieveMoves(onCompleted: @escaping Completion<[Id: Move]>) {
        retrieve(endpoint: "/api/v1/moves", onCompleted: onCompleted) { unboxer in
            let movesArray: [Move] = try unboxer.unbox(key: "data")
            return identifiedArrayToDictionary(movesArray)
        }
    }
    
    func retrieveUser(id: Id, onCompleted: @escaping Completion<User>) {
        retrieve(endpoint: "/api/v1/users/\(id)", onCompleted: onCompleted) { unboxer in
            let user: OtherUser = try unboxer.unbox(key: "data")
            return user
        }
    }
    
    func upload(pokemon: Pokemon, onCompleted: @escaping Completion<Pokemon>) {
        let url = buildUrl(endpoint: "/api/v1/pokemons")
        
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding(), headers: nil).validate().responseJSON { response in
            
        }
    }
    
    func upload(comment: Comment, forPokemon: Pokemon, onCompleted: Completion<(Comment, Pokemon)>) {
        
    }
    
    // MARK: Private
    private let rootUrl: String
    private var user: AuthenticatedUser?
    private var headers: HTTPHeaders
    
    private func buildUrl(endpoint: String) -> URL {
        guard let url = URL(string: rootUrl + endpoint) else {
            fatalError("Endpoint \"\(endpoint)\" is invalid")
        }
        return url
    }
    
    private func setAuthorizationHeader(token: String, email:String) {
        headers["Authorization"] = "Token token=\(token), email=\(email)"
    }
    
    //I know that's a bit hard to read, but it really results in simplicity in other calls
    private func retrieve<T>(endpoint: String, method: HTTPMethod = .get, params: [String: Any]? = nil, onCompleted: @escaping Completion<T>, process: @escaping (Unboxer) throws -> (T)) {
        let url = buildUrl(endpoint: endpoint)
        Alamofire
            .request(url, method: .get, parameters: params, encoding: JSONEncoding(), headers: headers)
            .validate()
            .responseJSON { response in
                do {
                    guard let dictionary = response.result.value as? Dictionary<String, Any> else {
                        throw NetworkManagerError.expectedDictionary
                    }
                    let unboxer = Unboxer(dictionary: dictionary)
                    do {
                        guard dictionary["data"] != nil else {
                            throw NetworkManagerError.expectedData
                        }
                        let result = try process(unboxer)
                        onCompleted(.success(result))
                    } catch NetworkManagerError.expectedData {
                        let errors: [APIError] = try unboxer.unbox(key: "errors")
                        onCompleted(.error(NetworkManagerError.apiErrors(errors: errors)))
                    } catch {
                        onCompleted(.error(error))
                    }
                } catch {
                    onCompleted(.error(error))
                }
        }
    }
}


