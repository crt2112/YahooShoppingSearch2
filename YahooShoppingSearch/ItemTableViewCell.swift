//
//  ItemTableViewCell.swift
//  YahooShoppingSearch
//
//  Created by beakhand on 2018/10/20.
//  Copyright © 2018年 beakchild. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {


    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!

    var itemUrl: String? // 詳細ページのURL
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        // 再利用時のクリア処理
        itemImageView.image = nil
    }

}
