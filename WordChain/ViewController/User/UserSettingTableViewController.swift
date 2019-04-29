//
//  UserSettingTableViewController.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/21.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

class UserSettingTableViewController: UITableViewController, paramNicknameDelegate, paramStatusDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func returnStatus(status: String) {
        user?.status = status
    }
    
    func returnNickname(nickname: String) {
        user?.nickname = nickname
    }
    
    var user: User? = nil
    // 多余的
    var userImage: UIImage? = nil
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var userStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "设置"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let userId = UserDefaults.standard.integer(forKey: "userId")
        getUserInfo(userId: userId)
    }
    
    @IBAction func logout(_ sender: Any) {
        // TODO 这样退出登录后 如果按左上角叉 获取不到userId会闪退
        UserDefaults.standard.removeObject(forKey: "userId")
        // 显示登录页
        let sb = UIStoryboard(name: "Main", bundle:nil)
        let vc = sb.instantiateViewController(withIdentifier: "login") as! UINavigationController
        self.present(vc, animated: true, completion: nil)
    }
    
    func updateUI() {
        if user?.image_url == "" {
            userImageView.downloadedFrom(link: "http://47.103.3.131/default.jpg", cornerRadius: 60)
        } else {
            userImageView.downloadedFrom(link: user?.image_url ?? "http://47.103.3.131/default.jpg", cornerRadius: 60)
        }
        userNicknameLabel.text = user?.nickname
        userStatusLabel.text = user?.status
    }
    
    @IBAction func changeImage(_ sender: Any) {
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
            let userId = UserDefaults.standard.integer(forKey: "userId")
            let parameters = ["image": imageBase64String, "user_id": userId] as [String : Any]
            let request = "http://47.103.3.131:5000/postUserImage"
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
                                            self?.userImageView.image = pickedImage.crop(ratio: 1.0)
                                            self?.userImageView.layer.cornerRadius = 60
                                            self?.userImageView.clipsToBounds = true
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNickname" {
            let controller = (segue.destination) as! EditUserNicknameViewController
            controller.delegate = self
            controller.previousNickname = self.userNicknameLabel.text ?? ""
        } else if segue.identifier == "editStatus" {
            let controller = (segue.destination) as! EditUserStatusViewController
            controller.delegate = self
            controller.previousStatus = self.userStatusLabel.text ?? ""
        }
    }
    
    // 返回时取消选中
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //http://47.103.3.131:5000/getUserInfo
    func getUserInfo(userId: Int) {
        let parameters = ["user_id": userId]
        let request = "http://47.103.3.131:5000/getUserInfo"
        let queue = DispatchQueue(label: "com.wordchain.api", qos: .userInitiated, attributes: .concurrent)
        
        Alamofire.request(request, method: .post, parameters: parameters).responseJSON(queue: queue) { [weak self] response in
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
                self?.user = try! JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self?.updateUI()
                }
            }
        }
    }
    
}
