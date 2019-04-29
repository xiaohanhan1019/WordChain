//
//  EditUserStatusViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/22.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

protocol paramStatusDelegate {
    func returnStatus(status: String)
}

class EditUserStatusViewController: UIViewController {
    
    let alertShowTime = 0.5
    var previousStatus: String? = nil
    
    var delegate: paramStatusDelegate?
    
    @IBOutlet weak var numberOfCharsLabel: UILabel!
    
    @IBOutlet weak var statusTextField: UITextField!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var numberOfChars: Int{
        return statusTextField.text?.count ?? 0
    }
    
    @IBAction func statusTextFieldChange(_ sender: Any) {
        numberOfCharsLabel.text = String("\(numberOfChars)/30")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "修改签名"

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        statusTextField.text = previousStatus
        numberOfCharsLabel.text = String("\(numberOfChars)/30")
    }
    
    @objc func save() {
        if let nickname = statusTextField.text {
            if nickname.count > 30{
                let alertToast = UIAlertController(title: "不能超过30个字符！", message: nil, preferredStyle: .alert)
                present(alertToast, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.alertShowTime) {
                        alertToast.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                spinner.startAnimating()
                editUserInfo(status: statusTextField.text!)
            }
        }
    }
    
    //http://47.103.3.131:5000/editUserInfo
    func editUserInfo(status: String){
        let userId = UserDefaults.standard.integer(forKey: "userId")
        let parameters = ["user_id": userId, "status": status] as [String : Any]
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
                                self?.delegate?.returnStatus(status: status)
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
