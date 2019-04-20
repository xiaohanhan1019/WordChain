//
//  WordListCell.swift
//  WordChain
//
//  Created by xiaohanhan on 2019/4/14.
//  Copyright © 2019 xiaohanhan. All rights reserved.
//

import UIKit

class WordListCell: UITableViewCell {
    
    @IBOutlet weak var wordListCoverImage: UIImageView!
    @IBOutlet weak var wordListName: UILabel!
    @IBOutlet weak var wordListInfo: UILabel!
    
    var wordList: WordList? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        wordListName.text = wordList!.name
        wordListInfo.text = String(wordList!.words.count)
        wordListCoverImage.downloadedFrom(link: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555944871&di=45dccd9aa19e79602a26e866d9f0c283&imgtype=jpg&er=1&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201610%2F21%2F20161021114501_kKusd.jpeg", cornerRadius: 10)
    }
    
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit, cornerRadius: CGFloat) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image.crop(ratio: 1)
                // 圆角图片
                self.layer.cornerRadius = cornerRadius
                self.clipsToBounds = true
            }
            }.resume()
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
