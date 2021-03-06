//
//  ViewController.swift
//  ViforPharma
//
//  Created by Le Thanh Nhan on 13/6/16.
//  Copyright © 2016 SwagsoftVN. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var username: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        username.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: self.username.frame.height))
        username.leftView = paddingView
        username.leftViewMode = UITextFieldViewMode.always
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Action
    
    @IBAction func login(_ sender: UIButton) {
        let usernameStr: String = username.text!
        
        // Check input validation
        if usernameStr.isEmpty {
            // Show error message
            showErrorMessage("Iron World", message: "Please input username!")
        } else {
            // Show loading
            showLoading()
            
            let body: String = "username=" + usernameStr + "&flag=login"
            
            RestApiManager.sharedInstance.callApi(LOGIN_API, body: body, onCompletion: { (json: JSON) in
                self.loginCallback(json)
            })
        }
    }
    
    @IBAction func register(_ sender: UIButton) {
        let usernameStr: String = username.text!
        
        // Check input validation
        if usernameStr.isEmpty {
            // Show error message
            showErrorMessage("Iron World", message: "Please input username!")
        } else {
            // Show loading
            showLoading()
            
            let body: String = "username=" + usernameStr + "&flag=register"
            
            RestApiManager.sharedInstance.callApi(LOGIN_API, body: body, onCompletion: { (json: JSON) in
                self.loginCallback(json)
            })
        }
    }
    
    func saveUserData(_ userId: Int, ta: String, secondary: String, primary: Int) {

        let taArr = ta.characters.split{$0 == ","}.map(String.init)
        var listTa:Array<Int> = []
        
        for i in 0 ..< taArr.count {
            listTa.append(Int(taArr[i])!)
        }
        
        let secondArr = secondary.characters.split{$0 == ","}.map(String.init)
        var listSecond:Array<Int> = []
        
        for i in 0 ..< secondArr.count {
            listSecond.append(Int(secondArr[i])!)
        }
        
        UserDefaults.standard.set(userId, forKey: USER_ID_KEY)
        UserDefaults.standard.set(listTa, forKey: USER_TA_KEY)
        UserDefaults.standard.set(primary, forKey: USER_PRIMARY_LANGUAGE_KEY)
        UserDefaults.standard.set(listSecond, forKey: USER_SECONDARY_LANGUAGE_KEY)
        
    }
    
    // MARK: - Callback Function
    func loginCallback(_ json: JSON) -> Void{
        if json.isEmpty {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: CONNECTION_ERROR)
            
            return
        }
        
        if IS_DEBUG {
            print (json)
        }
        
        let code = json["code"]
        
        if code == 1 {
            // login success
            // Save data of user
            let userId = json["user"]["id"].intValue
            let ta = json["user"]["ta_subscribed"].stringValue
            let secondaryLang = json["user"]["secondary_lang"].stringValue
            let primaryLang = json["user"]["primary_lang"].intValue
            
            saveUserData(userId, ta: ta, secondary: secondaryLang, primary: primaryLang)
            
            // move to next screen
            if ta.isEmpty || primaryLang == 0 {
                // Move to selected TA screen
                DispatchQueue.main.async {
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "ContainerSelectViewController") as! ContainerSelectViewController
                    self.present(next, animated: true, completion: nil)
                }
            } else {
                // Init menu postion
                UserDefaults.standard.set(0, forKey: MENU_POS)
                UserDefaults.standard.set(0, forKey: VIEW_FAVOURITES)
                
                // Move to Article list screen
                DispatchQueue.main.async {
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                    self.present(next, animated: true, completion: nil)
                }
            }
            
        } else {
            // Close loading
            hideLoading()
            
            // login fail --> show error message
            self.showErrorMessage("Iron World", message: String(describing: json["message"]))
        }
    }
    
    @IBAction func unwindToVC(_ segue: UIStoryboardSegue) {
        
    }
}


