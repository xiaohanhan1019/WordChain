//
//  EditWordListNameViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/26.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

protocol paramWordListNameDelegate {
    func returnName(name: String)
}

class EditWordListNameViewController: UIViewController {
    
    var delegate: paramWordListNameDelegate?
    var previousWordListName: String? = nil
    var wordListId: Int? = nil

    @IBOutlet weak var wordListNameTextField: UITextField!
    
    @IBOutlet weak var numberOfCharsLabel: UILabel!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var numberOfChars: Int{
        return wordListNameTextField.text?.count ?? 0
    }
    
    @IBAction func wordListNameChange(_ sender: Any) {
        numberOfCharsLabel.text = String("\(numberOfChars)/20")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "修改词单名称"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        wordListNameTextField.text = previousWordListName
        numberOfCharsLabel.text = String("\(numberOfChars)/20")
    }
    
    @objc func save() {
        if let wordListName = wordListNameTextField.text {
            if wordListName.count > 20{
                let alertToast = UIAlertController(title: "不能超过20个字符！", message: nil, preferredStyle: .alert)
                present(alertToast, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        alertToast.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                spinner.startAnimating()
                editWordList(wordListName: wordListName, wordListId: wordListId!)
            }
        }
    }
    
    //http://47.103.3.131:5000/editWordList
    func editWordList(wordListName: String, wordListId: Int){
        let parameters = ["wordList_id": wordListId, "name": wordListName] as [String : Any]
        let request = "http://47.103.3.131:5000/editWordList"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let statusCode = response.response?.statusCode {
                print("status code: \(statusCode)")
                if statusCode == 200 {
                    DispatchQueue.main.async {
                        self?.spinner.stopAnimating()
                        let alertToast = UIAlertController(title: "修改成功", message: nil, preferredStyle: .alert)
                        self?.present(alertToast, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                                alertToast.dismiss(animated: true, completion: nil)
                                print("wordlistname")
                                self?.delegate?.returnName(name: wordListName)
                                self?.navigationController?.popViewController(animated:true)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.spinner.stopAnimating()
                        let alertToast = UIAlertController(title: "修改失败", message: nil, preferredStyle: .alert)
                        self?.present(alertToast, animated: true) {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                                alertToast.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
}
