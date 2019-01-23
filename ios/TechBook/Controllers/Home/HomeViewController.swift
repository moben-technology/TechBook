//
//  HomeViewController.swift
//  TechBook
//
//  Created by MacBook on 19/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import DropDown
import Alamofire

class HomeViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var userConnected = User()
    let dropDownStatus = DropDown()
    var window: UIWindow?
    
    var arrayPublications: [Publication] = []
    var currentPageNumber: Int = 1
    var totalNbrPages: Int = 1
    @IBOutlet weak var timeLineTableView: UITableView!
    @IBOutlet weak var dropDownView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // prepare btn drop down menu
        self.prepareStatusDropDown()
        // prepare nibCell of TableView
        let nibCell = UINib(nibName: "PublicationTableViewCell", bundle: nil)
        self.timeLineTableView.register(nibCell, forCellReuseIdentifier: "PublicationTableViewCell")
        // remove extra empty cells
        self.timeLineTableView.tableFooterView = UIView()
        // get user data from UserDefaults
        let objectUser = self.defaults.dictionary(forKey: "objectUser")
        self.userConnected = User(objectUser!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getTimeLine(pageNumber: self.currentPageNumber)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
    
    func getTimeLine(pageNumber:Int){
        let postParameters = [
            "userIdConnected":self.userConnected._id!,
            "perPage": Constants.perPageForListing,
            "page": pageNumber,
        ] as [String : Any]
        //print("postParameters in getTimeLine",postParameters)
        Alamofire.request(Constants.getTimeLine, method: .post, parameters: postParameters as Parameters,encoding: JSONEncoding.default).responseJSON {
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
                
                //print("response from server of getTimeLine : ",json)
                let responseServer = json["status"] as? NSNumber
                if responseServer == 1{
                    if  let data = json["data"] as? [String:Any]{
                        if  let listePublicationsData = data["publications"] as? [[String : Any]]{
                            for publicationDic in listePublicationsData {
                                let pub = Publication(publicationDic)
                                self.arrayPublications.append(pub)
                            }
                            
                        }
                        if let nbrTotalOfPages = data["Totalpages"] as? Int{
                            self.totalNbrPages = nbrTotalOfPages
                        }
                        self.currentPageNumber += 1
                        // refresh tableView
                        self.timeLineTableView.reloadData()
                    }
                }
                break
                
            case .failure(let error):
                print("error from server : ",error)
                break
                
            }
            
        }
        
    }
    

}

extension HomeViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 460.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayPublications.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PublicationTableViewCell", for: indexPath) as! PublicationTableViewCell
        cell.delegatePublication = self // lisener to action btn
        cell.loadData(publication: arrayPublications[indexPath.row], indexPathCell: indexPath, tableView: tableView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // for pagination
        if indexPath.row == arrayPublications.count - 1 && (self.totalNbrPages >= self.currentPageNumber) {
            getTimeLine(pageNumber: self.currentPageNumber)
        }
    }
    
}


extension HomeViewController : PublicationTableViewCellDelegate {
    func didBtnLikeClicked(publication: Publication, cell: UITableViewCell, indexPathCell: IndexPath, tableView: UITableView) {
        if (publication.isLiked!){
            // dislike pub
            let postParameters = [
                "userId":self.userConnected._id!,
                "publicationId": publication._id!,
                ] as [String : Any]
            //print("postParameters in dislikePublication",postParameters)
            Alamofire.request(Constants.dislikePublication, method: .post, parameters: postParameters as Parameters,encoding: JSONEncoding.default).responseJSON {
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
                    
                    print("response from server of dislikePublication : ",json)
                    let responseServer = json["status"] as? NSNumber
                    if responseServer == 1{
                        let publicationCell = cell as! PublicationTableViewCell
                        publication.isLiked = false
                        publication.nbrLikes = publication.nbrLikes! - 1
                        publicationCell.loadData(publication: publication, indexPathCell: indexPathCell, tableView: tableView)
                    }
                    break
                    
                case .failure(let error):
                    print("error from server : ",error)
                    break
                    
                }
                
            }
        }else{
            // like pub
            let postParameters = [
                "userId":self.userConnected._id!,
                "publicationId": publication._id!,
                ] as [String : Any]
            //print("postParameters in likePublication",postParameters)
            Alamofire.request(Constants.likePublication, method: .post, parameters: postParameters as Parameters,encoding: JSONEncoding.default).responseJSON {
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
                    
                    print("response from server of likePublication : ",json)
                    let responseServer = json["status"] as? NSNumber
                    if responseServer == 1{
                        let publicationCell = cell as! PublicationTableViewCell
                        publication.isLiked = true
                        publication.nbrLikes = publication.nbrLikes! + 1
                        publicationCell.loadData(publication: publication, indexPathCell: indexPathCell, tableView: tableView)
    
                    }
                    break
                    
                case .failure(let error):
                    print("error from server : ",error)
                    break
                    
                }
                
            }
        }
    }
    
    func didBtnGetCommentsClicked(_id: String, cell: UITableViewCell, indexPathCell: IndexPath, tableView: UITableView) {
        // navigate between Views from Identifier of Storyboard
        let MainStory:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let desVC = MainStory.instantiateViewController(withIdentifier: "ListCommentsViewController") as! ListCommentsViewController
        
        desVC.publication = arrayPublications[indexPathCell.row]
        // push navigationController
        self.navigationController?.pushViewController(desVC, animated: true)
        
    }
    
    
}
