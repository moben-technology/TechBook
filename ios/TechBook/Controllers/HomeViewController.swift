//
//  HomeViewController.swift
//  TechBook
//
//  Created by MacBook on 19/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var window: UIWindow?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnLogoutAction(_ sender: Any) {
        // change statut of user in NSUserDefaults
        let userConnected = false
        self.defaults.set(userConnected, forKey: "userStatut")
        // change statut of user in NSUserDefaults
        defaults.removeObject(forKey: "objectUser")
        // Init Root View
        var initialViewController : UIViewController?
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //initialViewController = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        var root : UIViewController?
        root = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        initialViewController = UINavigationController(rootViewController: root!)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()

    }
    


}
