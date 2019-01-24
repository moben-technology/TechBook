//
//  ProfileViewController.swift
//  TechBook
//
//  Created by MacBook on 19/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import DropDown
import Alamofire


class ProfileViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    let dropDownStatus = DropDown()
    var window: UIWindow?
    var idUserReceived = String()
    var userConnected = User()
    var currentUser = User()
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var imageProfileUser: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var dateSignUpLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // prepare btn drop down menu
        self.prepareStatusDropDown()

        self.imageProfileUser.layer.cornerRadius = self.imageProfileUser.frame.size.width/2
        self.imageProfileUser.clipsToBounds = true
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("idUserReceived in viewWillAppear: ", idUserReceived)
        // get user data from UserDefaults
        let objectUser = self.defaults.dictionary(forKey: "objectUser")
        self.userConnected = User(objectUser!)
        //profile to show: user connected so get data of user from UserDefaults
        if (idUserReceived == "" || idUserReceived == self.userConnected._id) {
            print("get user from UserDefaults")
            self.currentUser = self.userConnected
            self.setUpView()
        }else{
            //profile to show: an other user so get data of user from server
            print("get user from server")
            getUserById()
        }
        
    }
    
    func getUserById(){
        let postParameters = [
            "userId":self.idUserReceived,
        ] as [String : Any]
        //print("postParameters in getUserById",postParameters)
        Alamofire.request(Constants.getUserById, method: .post, parameters: postParameters as Parameters,encoding: JSONEncoding.default).responseJSON {
            response in
            switch response.result {
            case .success:
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling POST")
                    print(response.result.error!)
                    return
                }
                
                // make sure we got some JSON since that's what we expect
                guard let json = response.result.value as? [String: Any] else {
                    print("didn't get object as JSON from URL")
                    if let error = response.result.error {
                        print("Error: \(error)")
                    }
                    return
                }
                
                //print("response from server of getUserById : ",json)
                let responseServer = json["status"] as? NSNumber
                if responseServer == 1{
                    if  let data = json["data"] as? [String:Any]{
                        if  let userDict = data["user"] as? [String : Any]{
                             self.currentUser = User(userDict)
                            self.setUpView()

                        }
                    }
                }
                break
                
            case .failure(let error):
                print("error from server : ",error)
                break
                
            }
            
        }
        
    }
//    @IBOutlet weak var imageProfileUser: UIImageView!
//    @IBOutlet weak var fullNameLabel: UILabel!
//    @IBOutlet weak var emailLabel: UILabel!
//    @IBOutlet weak var genderLabel: UILabel!
//    @IBOutlet weak var ageLabel: UILabel!
//    @IBOutlet weak var dateSignUpLabel: UILabel!
    // setup View
    func setUpView(){
        self.imageProfileUser.sd_setImage(with: URL(string: self.currentUser.pictureProfile!))
        self.fullNameLabel.text = self.currentUser.firstName! + " " + self.currentUser.lastName!
        self.emailLabel.text = self.currentUser.email!
        self.genderLabel.text = self.currentUser.gender!
        self.ageLabel.text = self.currentUser.age!
        self.dateSignUpLabel.text = self.currentUser.createdAt!

    }
    
    //dropDownBtnAction
    @IBAction func dropDownBtnAction(_ sender: Any) {
        dropDownStatus.show()
    }
    
    func prepareStatusDropDown(){
        DropDown.startListeningToKeyboard()
        dropDownStatus.anchorView = dropDownView
        dropDownStatus.direction = .bottom
        dropDownStatus.bottomOffset = CGPoint(x: 0, y:(dropDownStatus.anchorView?.plainView.bounds.height)!)
        dropDownStatus.dataSource = ["Logout"]
        dropDownStatus.selectionAction = { (index: Int, item: String) in
            
            if index == 0 {
                // change statut of user in NSUserDefaults
                let userConnected = false
                self.defaults.set(userConnected, forKey: "userStatut")
                // change statut of user in NSUserDefaults
                self.defaults.removeObject(forKey: "objectUser")
                // Init Root View
                var initialViewController : UIViewController?
                self.window = UIWindow(frame: UIScreen.main.bounds)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                var root : UIViewController?
                root = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
                initialViewController = UINavigationController(rootViewController: root!)
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
                
            }
            
        }
        
    }
    

}
