//
//  SignUpViewController.swift
//  TechBook
//
//  Created by MacBook on 19/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var ageTxtField: UITextField!
    @IBOutlet weak var genderTxtField: UITextField!
    @IBOutlet weak var validationFormLabel: UILabel!
    
    var arrayGender = ["Male","Female"]
    let genderPickerView = UIPickerView()
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // delegate max length
        self.firstNameTxtField.delegate = self
        self.lastNameTxtField.delegate = self
        // make text field secure
        passwordTxtField.isSecureTextEntry = true
        // create pickerView for to choose gender
        createGenderPickerView()
        
    }
    
    func createGenderPickerView() {
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
        self.genderTxtField.inputView = genderPickerView
        
        // create a toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // add a done button on this toolbar
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClickedGender))
        toolbar.setItems([doneButton], animated: true)
        self.genderTxtField.inputAccessoryView = toolbar
    }
    
    @objc func doneClickedGender() {
        self.view.endEditing(true)
        if(self.genderTxtField.text == ""){
            self.genderTxtField.text = arrayGender[0]
        }
    }
    
    @IBAction func btnSignupAction(_ sender: Any) {
//        if (self.emailTxtField.text!.isValidEmail()){
//            guard let _ = firstNameTxtField.text , (firstNameTxtField.text?.count)! >= 4 else {
//                validationFormLabel.text = "First name must have 4 caracters"
//                return
//            }
//            guard let _ = lastNameTxtField.text , (lastNameTxtField.text?.count)! >= 4 else {
//                validationFormLabel.text = "Last name must have 4 caracters"
//                return
//            }
//            guard let _ = passwordTxtField.text , (passwordTxtField.text?.count)! >= 4 else {
//                validationFormLabel.text = "Password must have 4 caracters"
//                return
//            }
//            guard let _ = ageTxtField.text , Int((ageTxtField.text)!) ?? 0 >= 10 ,  Int((ageTxtField.text)!) ?? 0 <= 99 else {
//                validationFormLabel.text = "Age invalid : Must be in 10..99 years"
//                return
//            }
//            guard let _ = genderTxtField.text, (genderTxtField.text?.count)! >= 2 else {
//                validationFormLabel.text = "Gender required"
//                return
//            }
//            print("execute web service for signup")
//            self.validationFormLabel.text = ""
//
//        }else{
//            validationFormLabel.text = "Email invalid"
//        }
        // save statut of login user in NSUserDefaults
        let userConnected = true
        self.defaults.set(userConnected, forKey: "userStatut")
        self.performSegue(withIdentifier: "ShowHomeViaSignUp", sender: self)
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return textField.text!.count < 30 || string == ""
        
    }
    
}

extension SignUpViewController: UIPickerViewDataSource,UIPickerViewDelegate {
    //UIPickerViewDataSource
    // number of colums
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // number of rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.arrayGender.count
    }
    
    //UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderTxtField.text = arrayGender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.arrayGender[row]
    }
    
    
}

