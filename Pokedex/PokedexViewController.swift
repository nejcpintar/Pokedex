//
//  PokedexViewController.swift
//  Pokedex
//
//  Created by Nejc on 3.3.2017.
//  Copyright © 2017 nejc. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage

class PokedexTableViewCell: UITableViewCell {
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonName: UILabel!
}

class PokedexViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let dataSource = PokedexDataSource()
    
    override func viewDidLoad() {
        tableView.dataSource = dataSource
        
        dataSource.onRefresh = {
            [weak tableView] in
            tableView?.reloadData()
        }
    }
}

class PokedexDataSource: NSObject, UITableViewDataSource {
    let model = ConnectedDataModel()
    var pokemons: [Pokemon]? = nil
    var onRefresh: (() -> ())? = nil
    
    override init() {
        super.init()
        refresh()
    }
    
    func refresh() {
        model.getPokemons { result in
            do {
                self.pokemons = try result.unwrap()
                if let onRefresh = self.onRefresh {
                    onRefresh()
                }
            } catch {
                //show error
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PokedexTableViewCell
        guard let pokemon = pokemons?[indexPath.row] else {
            cell.pokemonName.text = ""
            cell.pokemonImageView.image = nil
            return cell
        }
        
        cell.pokemonName.text = pokemon.name
        if let imageUrl = pokemon.imageUrl {
            cell.pokemonImageView.af_setImage(withURL: imageUrl)
        }
        return cell
    }
}
