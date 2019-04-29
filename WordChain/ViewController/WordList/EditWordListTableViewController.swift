//
//  EditWordListTableViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/25.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

protocol paramWordListDelegate {
    func returnWordListInfo(name: String, description: String,cover: UIImage)
}

class EditWordListTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, paramWordListNameDelegate, paramWordListDescriptionDelegate {
    
    func returnName(name: String) {
        wordList?.name = name
    }
    
    func returnDescription(description: String) {
        wordList?.description = description
    }
    
    var wordList: WordList? = nil
    var wordListImage: UIImage? = nil
    
    var delegate: paramWordListDelegate?
    
    @IBOutlet weak var wordListCoverImageView: UIImageView!
    @IBOutlet weak var wordListNameLabel: UILabel!
    @IBOutlet weak var wordListDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "编辑词单信息"
        self.tableView.tableFooterView = UIView()
    }
    
    func updateUI() {
        if wordList?.image_url == "" {
            wordListCoverImageView.downloadedFrom(link: "http://47.103.3.131/default.jpg", cornerRadius: 60)
        } else {
            wordListCoverImageView.downloadedFrom(link: wordList?.image_url ?? "http://47.103.3.131/default.jpg", cornerRadius: 60)
        }
        wordListNameLabel.text = wordList?.name
        wordListDescriptionLabel.text = wordList?.description
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.delegate?.returnWordListInfo(name: wordList!.name, description: wordList!.description, cover: wordListCoverImageView.image!)
    }
    
    // 返回时取消选中
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func changeCover(_ sender: Any) {
        let alert = UIAlertController()
        let cleanAction = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel,handler:nil)
        let choosePhotoAction = UIAlertAction(title: "从手机相册选择", style: UIAlertAction.Style.default){ (action:UIAlertAction) in
            self.choosePhoto()
        }
        alert.addAction(choosePhotoAction)
        alert.addAction(cleanAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func choosePhoto(){
        let pick:UIImagePickerController = UIImagePickerController()
        pick.delegate = self
        pick.sourceType = .photoLibrary
        self.present(pick, animated: true, completion: nil)
    }
    
    // 选择图片成功后代理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //获取选择的原图
        let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let imageData = pickedImage.jpegData(compressionQuality: 0.3)
        
        if let imageBase64String = imageData?.base64EncodedString() {
            // postImage
            let wordListId = wordList?.id
            let parameters = ["image": imageBase64String, "wordList_id": wordListId!] as [String : Any]
            let request = "http://47.103.3.131:5000/postWordListImage"
            let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
            
            Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
                
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        DispatchQueue.main.async {
                            picker.dismiss(animated: true) {
                                let alertToast = UIAlertController(title: "修改成功", message: nil, preferredStyle: .alert)
                                self?.present(alertToast, animated: true) {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                                        alertToast.dismiss(animated: true) {
                                            // 修改头像
                                            self?.delegate?.returnWordListInfo(name: (self?.wordList!.name)!, description: (self?.wordList!.description)!, cover: pickedImage)
                                            self?.wordListCoverImageView.image = pickedImage.crop(ratio: 1.0)
                                            self?.wordListCoverImageView.layer.cornerRadius = 60
                                            self?.wordListCoverImageView.clipsToBounds = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            picker.dismiss(animated: true) {
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
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                }
            }
        }
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editWordListName" {
            let controller = (segue.destination) as! EditWordListNameViewController
            controller.delegate = self
            controller.previousWordListName = self.wordListNameLabel.text ?? ""
            controller.wordListId = wordList?.id
        } else if segue.identifier == "editWordListDescription" {
            let controller = (segue.destination) as! EditWordListDescriptionViewController
            controller.delegate = self
            controller.previousWordListDescription = self.wordListDescriptionLabel.text ?? ""
            controller.wordListId = wordList?.id
        }
    }

}
