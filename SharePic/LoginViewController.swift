//
//  LoginViewController.swift
//  SharePic
//
//  Created by Patrick Boyle on 4/21/17.
//  Copyright © 2017 Patrick Boyle. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func loginPressed(_ sender: Any) {
        guard emailField.text != "", passwordField.text != "" else
        {
            let alert = UIAlertController(title: "Error", message: "Please enter an Email and Password", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil));
            self.present(alert, animated: true, completion: nil);
            
            return;
        }
        
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            
            if let error = error
            {
                print(error.localizedDescription);
                return;
            }
            
            if (user != nil)
            {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC");
                self.present(vc, animated: true, completion: nil);
            }
        })
    }

}
