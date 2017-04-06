//
//  RegistrationVC.swift
//  Pact-iOS
//
//  Created by matt on 2017-04-06.
//  Copyright © 2017 matt. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import KeychainSwift

class RegistrationVC: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func signUpBtnPressed(_ sender: Any) {
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    print("you're logged in")
                    self.emailField.text = ""
                    self.passwordField.text = ""
                    self.performSegue(withIdentifier: "HealthKitSegue", sender: nil)
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            print(error as Any)
                        } else {
                            self.emailField.text = ""
                            self.passwordField.text = ""
                            print("you've created a new account")
                            self.performSegue(withIdentifier: "HealthKitSegue", sender: nil)
                        }
                    }
                }
            }
        }
    }
    
}
