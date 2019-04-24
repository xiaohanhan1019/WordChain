//
//  EditUserNicknameViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/21.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

protocol paramNicknameDelegate {
    func returnNickname(nickname: String)
}

class EditUserNicknameViewController: UIViewController {
    
    let alertShowTime = 0.5
    var previousNickname: String? = nil
    
    var delegate: paramNicknameDelegate?
    
    @IBOutlet weak var numberOfCharsLabel: UILabel!
    
    @IBOutlet weak var nicknameTextField: UITextField!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var numberOfChars: Int{
        return nicknameTextField.text?.count ?? 0
    }
    
    @IBAction func nameTextFieldChange(_ sender: Any) {
        numberOfCharsLabel.text = String("\(numberOfChars)/12")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        nicknameTextField.text = previousNickname
        numberOfCharsLabel.text = String("\(numberOfChars)/12")
    }
    
    @objc func save() {
        if let nickname = nicknameTextField.text {
            if !nickname.isEmpty {
                if nickname.count > 12{
                    let alertToast = UIAlertController(title: "昵称不能超过12个字符！", message: nil, preferredStyle: .alert)
                    present(alertToast, animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.alertShowTime) {
                            alertToast.dismiss(animated: true, completion: nil)
                        }
                    }
                } else {
                    spinner.startAnimating()
                    editUserInfo(nickname: nicknameTextField.text!)
                }
            } else {
                let alertToast = UIAlertController(title: "昵称不能为空！", message: nil, preferredStyle: .alert)
                present(alertToast, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.alertShowTime) {
                       alertToast.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    //http://47.103.3.131:5000/editUserInfo
    func editUserInfo(nickname: String){
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let parameters = ["user_id": userId, "nickname": nickname] as [String : Any]
        let request = "http://47.103.3.131:5000/editUserInfo"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let statusCode = response.response?.statusCode {
                print("status code: \(statusCode)")
                if statusCode == 200 {
                    DispatchQueue.main.async {
                        self?.spinner.stopAnimating()
                        let alertToast = UIAlertController(title: "修改成功", message: nil, preferredStyle: .alert)
                        self?.present(alertToast, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                alertToast.dismiss(animated: true, completion: nil)
                                self?.delegate?.returnNickname(nickname: nickname)
                                self?.navigationController?.popViewController(animated:true)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.spinner.stopAnimating()
                        let alertToast = UIAlertController(title: "修改失败", message: nil, preferredStyle: .alert)
                        self?.present(alertToast, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                                alertToast.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }

}
