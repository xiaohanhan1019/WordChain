//
//  WordListCell.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/29.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit
import Alamofire

class WordListCell: UITableViewCell {

    @IBOutlet weak var wordListCoverImage: UIImageView!
    @IBOutlet weak var wordListName: UILabel!
    @IBOutlet weak var wordListInfo: UILabel!
    @IBOutlet weak var wordListCellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        wordListCellView.layer.cornerRadius = 8
    }
    
    var wordList: WordList? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI() {
        wordListName.text = wordList?.name
        wordListInfo.text = String("共\(wordList?.words.count ?? 0)个单词")
        if wordList?.image_url == "" {
            wordListCoverImage.downloadedFrom(link: "http://47.103.3.131/default.jpg", cornerRadius: 10)
        } else {
            wordListCoverImage.downloadedFrom(link: wordList?.image_url ?? "http://47.103.3.131/default.jpg", cornerRadius: 10)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //wordListCoverImage.image = nil
    }
    
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit, cornerRadius: CGFloat) {
        contentMode = mode
        
        DispatchQueue.global(qos: .background).async {
            Alamofire.request(url).responseData { response in
                guard
                    let data = response.result.value,
                    response.response?.statusCode == 200,
                    let mimeType = response.response?.mimeType, mimeType.hasPrefix("image"),
                    let image = UIImage(data: data)
                    else { return }
                DispatchQueue.main.async() {
                    self.image = image.crop(ratio: 1)
                    // 圆角图片
                    self.layer.cornerRadius = cornerRadius
                    self.clipsToBounds = true
                }
            }
        }
    }
    func downloadedFrom(link: String, cornerRadius: CGFloat, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode, cornerRadius: cornerRadius)
    }
}

extension UIImage {
    //将图片裁剪成指定比例（多余部分自动删除）
    func crop(ratio: CGFloat) -> UIImage {
        //计算最终尺寸
        var newSize:CGSize!
        if size.width/size.height > ratio {
            newSize = CGSize(width: size.height * ratio, height: size.height)
        }else{
            newSize = CGSize(width: size.width, height: size.width / ratio)
        }
        
        ////图片绘制区域
        var rect = CGRect.zero
        rect.size.width  = size.width
        rect.size.height = size.height
        rect.origin.x    = (newSize.width - size.width ) / 2.0
        rect.origin.y    = (newSize.height - size.height ) / 2.0
        
        //绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}
