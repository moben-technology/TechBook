//
//  AddPublicationViewController.swift
//  TechBook
//
//  Created by MacBook on 19/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import DropDown
import Alamofire

import AVKit
import AVFoundation
import MobileCoreServices

class AddPublicationViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let defaults = UserDefaults.standard
    var userConnected = User()
    let dropDownStatus = DropDown()
    var window: UIWindow?
    var controller = UIImagePickerController()
    var player : AVPlayer?
    var videoUrlFromLibrary : URL?
    let placeholderPublicationTextView = "Add your text here..."
    var arrayAllSectors: [Sector] = []
    var sectorId: String?
    var typeFileToAdded = ""

    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var sectorTextField: UITextField!
    @IBOutlet weak var textPublication: UITextView!
    @IBOutlet weak var videoSelected: UIView!
    @IBOutlet weak var imageSelected: UIImageView!
    @IBOutlet weak var messageValidationFormLabel: UILabel!
    @IBOutlet weak var btnRemoveFile: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get user data from UserDefaults
        let objectUser = self.defaults.dictionary(forKey: "objectUser")
        self.userConnected = User(objectUser!)
        // prepare btn drop down menu
        self.prepareStatusDropDown()
        // delegate sector text field
        self.sectorTextField.delegate = self
        // set up  text view
        self.textPublication.layer.borderWidth = 1.0
        self.textPublication.layer.cornerRadius = 10
        self.textPublication.text = self.placeholderPublicationTextView
        self.textPublication.textColor = UIColor.lightGray
        self.textPublication.font = UIFont(name: "verdana", size: 13.0)
        self.textPublication.returnKeyType = .done
        self.textPublication.delegate = self
        // get allSectors
        self.getAllSectors()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.typeFileToAdded == "image") {
            self.videoSelected = nil
        }else if (self.typeFileToAdded == "video"){
            self.imageSelected.image = nil
        }else{
            self.videoSelected = nil
            self.imageSelected.image = nil
            self.btnRemoveFile.isHidden = true
        }
        self.typeFileToAdded = ""
    }

    
    func getAllSectors(){
        Alamofire.request(Constants.getAllSectors, method: .get,encoding: JSONEncoding.default).responseJSON {
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
                
                //print("response from server of getAllSectors : ",json)
                let responseServer = json["status"] as? NSNumber
                if responseServer == 1{
                    if  let data = json["data"] as? [String:Any]{
                        if  let listeSectorsData = data["sectors"] as? [[String : Any]]{
                            for sectorDic in listeSectorsData {
                                let sectorObj = Sector(sectorDic)
                                self.arrayAllSectors.append(sectorObj)
                            }
                            
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
    
    @IBAction func btnSelectFileAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Select File", message: nil, preferredStyle: .actionSheet)
        
        let getImageAction = UIAlertAction(title: "Image", style: .default) { action in
            // Display Photo Library to get image
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary;
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let getVideoAction = UIAlertAction(title: "Video", style: .default) { action in
            // Display Photo Library to get video
            self.controller.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.controller.mediaTypes = [kUTTypeMovie as String]
            self.controller.delegate = self
            self.present(self.controller, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        actionSheet.addAction(getImageAction)
        actionSheet.addAction(getVideoAction)
        actionSheet.addAction(cancelAction)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(actionSheet, animated: true, completion: nil)

    }
    
    @IBAction func btnRemoveFile(_ sender: Any) {
        
        // show alerte
        let alert = UIAlertController(title: "Attention",message: "You are sure to delete this file?" ,preferredStyle: .alert)
        // YES button
        let btnYes = UIAlertAction(title: "YES", style: .default, handler: { (action) -> Void in
            if (self.typeFileToAdded == "image") {
                self.imageSelected.image = nil
            }else if (self.typeFileToAdded == "video"){
                self.videoSelected = nil
            }
            self.typeFileToAdded = ""
            self.btnRemoveFile.isHidden = true
        })
        
        // NO button
        let btnNo = UIAlertAction(title: "NO", style: .destructive, handler: { (action) -> Void in
            
        })
        alert.addAction(btnNo)
        alert.addAction(btnYes)
        self.present(alert, animated: true, completion: nil)

    }
    
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.typeFileToAdded = "image"
            self.imageSelected.image = pickedImage
            self.videoSelected = nil
            picker.dismiss(animated: true, completion: nil)
        }else{
            videoUrlFromLibrary = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            // Setup view player
            if let urlVideo = videoUrlFromLibrary {
                self.imageSelected = nil
                self.typeFileToAdded = "video"
                player = AVPlayer(url: urlVideo)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.videoSelected.bounds
                self.videoSelected.layer.addSublayer(playerLayer)
            }
        }
        self.btnRemoveFile.isHidden = false
        
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if (self.typeFileToAdded == "image") {
            self.videoSelected = nil
            self.btnRemoveFile.isHidden = false
        }else if (self.typeFileToAdded == "video"){
            self.imageSelected.image = nil
            self.btnRemoveFile.isHidden = false
        }else{
            self.videoSelected = nil
            self.imageSelected.image = nil
            self.btnRemoveFile.isHidden = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func btnSubmitAddPublication(_ sender: Any) {
        guard let _ = titleTextField.text , (titleTextField.text?.count)! >= 3 else {
            messageValidationFormLabel.text = "Title must contain at least 3 caracters"
            return
        }
        guard let _ = sectorTextField.text , (sectorTextField.text?.count)! >= 1 else {
            messageValidationFormLabel.text = "You must choose a sector"
            return
        }
        
        var txtPubToSend = textPublication.text
        if (txtPubToSend == self.placeholderPublicationTextView) {
            txtPubToSend = ""
        }
        if(self.typeFileToAdded == "" && (txtPubToSend?.count)! <= 5){
            messageValidationFormLabel.text = "Text required & must contain at least 5 caracters"
        }else {
            
            // show alerte
            let alert = UIAlertController(title: "Attention",message: "You are sure to add this publication?" ,preferredStyle: .alert)
            // YES button
            let btnYes = UIAlertAction(title: "YES", style: .default, handler: { (action) -> Void in
                // execute web service
                self.messageValidationFormLabel.text = ""
                let postParameters = [
                    "title": self.titleTextField.text!,
                    "text": txtPubToSend!,
                    "sectorId": self.sectorId!,
                    "ownerId": self.userConnected._id!,
                    "type_file": self.typeFileToAdded,
                    ] as [String : Any]
                //print("postParameters in addPublication",postParameters)
                
                Alamofire.upload(multipartFormData: { (multipartFormData) in
                    for (key, value) in postParameters {
                        if value is String {
                            multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                        }
                        
                    }
                    if (self.typeFileToAdded == "image") {
                        multipartFormData.append(self.imageSelected.image!.jpegData(compressionQuality: 0.75)!, withName: "file", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
                    }
                    if (self.typeFileToAdded == "video") {
                        var videoData  = Data()
                        do {
                            videoData =  try Data(contentsOf: self.videoUrlFromLibrary!)
                        }
                        catch{}
                        multipartFormData.append(videoData, withName: "file", fileName: "swift_file.mp4", mimeType: "video/mp4")
                    }
                    
                    
                }, to:Constants.addPublication , headers: nil)
                { (result) in
                    switch result {
                    case .success(let upload, _, _):
                        
                        upload.uploadProgress(closure: { (progress) in
                            // print (progress)
                        })
                        
                        upload.responseJSON { response in
                            
                            if response.result.isFailure == true {
                                print("errror upload")
                            }
                            
                            if let result = response.result.value as? [String:Any] {
                                let responseServer = result["status"] as? NSNumber
                                if responseServer == 1 {
                                    self.messageValidationFormLabel.text = ""
                                    self.titleTextField.text = ""
                                    self.sectorTextField.text = ""
                                    self.sectorId = ""
                                    self.typeFileToAdded = ""
                                    self.textPublication.text = self.placeholderPublicationTextView
                                    self.imageSelected.image = nil
                                    self.videoSelected = nil
                                    self.btnRemoveFile.isHidden = true
                                    // publication added successfully
                                    self.showToast(message: (result["message"] as? String)!)
                                    
                                    // navigate to HomePage
                                    self.performSegue(withIdentifier: "ShowHomeViaAddPub", sender: self)
                                    
                                }
                            }
                            
                        }
                        
                    case .failure(let error):
                        print("error from server : ",error)
                        break
                        
                    }
                    
                }
            })
            
            // NO button
            let btnNo = UIAlertAction(title: "NO", style: .destructive, handler: { (action) -> Void in
                
            })
            alert.addAction(btnNo)
            alert.addAction(btnYes)
            self.present(alert, animated: true, completion: nil)
            

        
        
        }
        


    }
    
    

}

extension AddPublicationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.endEditing(true)
        let alert = UIAlertController(title: "Choose Sector", message: nil, preferredStyle: UIAlertController.Style.alert)
        for sectorDic in self.arrayAllSectors{
            
            let action = UIAlertAction(title: sectorDic.nameSector, style: .default, handler: { (action) -> Void in
                self.sectorId = sectorDic._id
                self.sectorTextField.text = sectorDic.nameSector
                
            })
            alert.addAction(action)
        }
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension AddPublicationViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == self.placeholderPublicationTextView {
            textView.text = ""
            textView.textColor = UIColor.black
            textView.font = UIFont(name: "verdana", size: 13.0)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            self.textPublication.text = self.placeholderPublicationTextView
            self.textPublication.textColor = UIColor.lightGray
            self.textPublication.font = UIFont(name: "verdana", size: 13.0)
        }
    }
    
}


// show drop down menu to logout
extension AddPublicationViewController {
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

// show toast
extension AddPublicationViewController {
    func showToast(message: String) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        let toastLbl = UILabel()
        toastLbl.text = message
        toastLbl.textAlignment = .center
        toastLbl.font = UIFont.systemFont(ofSize: 18)
        toastLbl.textColor = UIColor.white
        toastLbl.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLbl.numberOfLines = 0
        
        
        let textSize = toastLbl.intrinsicContentSize
        let labelHeight = ( textSize.width / window.frame.width ) * 30
        let labelWidth = min(textSize.width, window.frame.width - 40)
        let adjustedHeight = max(labelHeight, textSize.height + 20)
        
        toastLbl.frame = CGRect(x: 20, y: (window.frame.height - 90 ) - adjustedHeight, width: labelWidth + 20, height: adjustedHeight)
        toastLbl.center.x = window.center.x
        toastLbl.layer.cornerRadius = 10
        toastLbl.layer.masksToBounds = true
        
        window.addSubview(toastLbl)
        
        UIView.animate(withDuration: 5.0, animations: {
            toastLbl.alpha = 0
        }) { (_) in
            toastLbl.removeFromSuperview()
        }
        
    }
    
}
