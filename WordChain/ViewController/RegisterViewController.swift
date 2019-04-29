//
//  RegisterViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/20.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController {
    
    var alertToast: UIAlertController? = nil

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "注册"
    }
    
    @IBAction func register(_ sender: Any) {
        resignFirstResponder()
        if let account = accountTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text {
            if account.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                alertToast = UIAlertController(title: "请填写用户名和密码", message: nil, preferredStyle: .alert)
                present(alertToast!, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.alertToast!.dismiss(animated: true, completion: nil)
                }
            } else {
                if password != confirmPassword {
                    alertToast = UIAlertController(title: "两次密码不一致", message: nil, preferredStyle: .alert)
                    present(alertToast!, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                        self.alertToast!.dismiss(animated: true, completion: nil)
                    }
                } else {
                    register(account: account, password: password)
                }
            }
        }
    }
    
    func register(account: String, password: String){
        let parameters = ["account": account, "password":password]
        let request = "http://47.103.3.131:5000/register"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let statusCode = response.response?.statusCode {
                if statusCode == 200 {
                    DispatchQueue.main.async {
                        let alertToast = UIAlertController(title: "注册成功", message: nil, preferredStyle: .alert)
                        self?.present(alertToast, animated: true, completion: nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                            alertToast.dismiss(animated: true, completion: nil)
                            // 回到登录界面
                            self?.navigationController?.popViewController(animated:true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.alertToast?.dismiss(animated: false) {
                            //告知失败
                            let failAlertToast = UIAlertController(title: "注册失败", message: nil, preferredStyle: .alert)
                            self?.present(failAlertToast, animated: true, completion: nil)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                failAlertToast.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }

}
