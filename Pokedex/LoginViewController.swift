//
//  LoginViewController.swift
//  Pokedex
//
//  Created by Nejc on 3.3.2017.
//  Copyright © 2017 nejc. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBAction func logInTapped(_ sender: Any) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        
        NetworkManager.shared.login(email: email, password: password) { result in
            do {
                _ = try result.unwrap()
                self.performSegue(withIdentifier: "segueToMain", sender: self)
            } catch {
                //show error
                print(error)
            }
        }
    }
}
