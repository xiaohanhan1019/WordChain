//
//  EditWordListDescriptionViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/26.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

protocol paramWordListDescriptionDelegate {
    func returnDescription(description: String)
}

class EditWordListDescriptionViewController: UIViewController {

    var delegate: paramWordListDescriptionDelegate?
    var previousWordListDescription: String? = nil
    var wordListId: Int? = nil

    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var numberOfCharsLabel: UILabel!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var numberOfChars: Int{
        return descriptionTextField.text?.count ?? 0
    }
    
    @IBAction func wordListDescriptionChange(_ sender: Any) {
        numberOfCharsLabel.text = String("\(numberOfChars)/50")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "修改词单简介"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.save))
        descriptionTextField.text = previousWordListDescription
        numberOfCharsLabel.text = String("\(numberOfChars)/50")
    }
    
    @objc func save() {
        if let wordListDescription = descriptionTextField.text {
            if wordListDescription.count > 50{
                let alertToast = UIAlertController(title: "不能超过50个字符！", message: nil, preferredStyle: .alert)
                present(alertToast, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        alertToast.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                spinner.startAnimating()
                editWordList(description: wordListDescription, wordListId: wordListId!)
            }
        }
    }
    
    //http://47.103.3.131:5000/editWordList
    func editWordList(description: String, wordListId: Int){
        let parameters = ["wordList_id": wordListId, "description": description] as [String : Any]
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
                                self?.delegate?.returnDescription(description: description)
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
