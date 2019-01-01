//
//  ItemSearchResultSet.swift
//  YahooShoppingSearch
//
//  Created by beakhand on 2018/10/19.
//  Copyright © 2018年 beakchild. All rights reserved.
//

import Foundation

// JSON Format
/*
{
    ResultSet: {
        0: {
            Result: {
                0: {
                    Image: {
                        Medium: url
                    }
s                    Name: 商品名
                    Price: {
                        _value: 金額
                    }
                    Url
                }
                1: {
                }
                2: {
                }
            }
            Request: {
            }
        }
    }
}
*/

class ItemSearchResultSet: Codable {
    var resultSet: ResultSet
    
    private enum CodingKeys: String, CodingKey {
        case resultSet = "ResultSet"
    }
}

class ResultSet: Codable {
    var firstObject: FirstObject
    
    private enum CodingKeys: String, CodingKey {
        case firstObject = "0"
    }
}

class FirstObject: Codable {
    var result: Result
    
    private enum CodingKeys: String, CodingKey {
        case result = "Result"
    }
}

class Result: Codable {
    var items: [ItemData] = [ItemData]()
    
    required init(from decoder: Decoder) throws {
        // デコードのためのコンテナを取得
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // コンテナ内のキーを取得、ソート
        let keys = container.allKeys.sorted(by: { Int($0.rawValue)! < Int($1.rawValue)! })
        // キーを使用して検索結果を取り出す
        for key in keys {
            // 検索結果１件に対するデコード処理
            let item = try container.decode(ItemData.self, forKey: key)
            // デコードできたら結果の一覧に追加
            items.append(item)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        // 解析だけなのでエンコードは不要
    }
    
    private enum CodingKeys: String, CodingKey {
        case hit0 = "0"
        case hit1 = "1"
        case hit2 = "2"
        case hit3 = "3"
        case hit4 = "4"
        case hit5 = "5"
        case hit6 = "6"
        case hit7 = "7"
        case hit8 = "8"
        case hit9 = "9"
        case hit10 = "10"
        case hit11 = "11"
        case hit12 = "12"
        case hit13 = "13"
        case hit14 = "14"
        case hit15 = "15"
        case hit16 = "16"
        case hit17 = "17"
        case hit18 = "18"
        case hit19 = "19"
        case hit20 = "20"
    }
}

class ItemData: Codable {
    var name: String = ""
    var url: String = ""
    
    
    class ImageInfo: Codable {
        
        private enum CodingKeys: String, CodingKey {
            case medium = "Medium"
        }
        // 商品画像 URL
        var medium: String?
        
    }
    var imageInfo: ImageInfo = ImageInfo()
    
    class PriceInfo: Codable {
        private enum CodingKeys: String, CodingKey {
            case price = "_value"
        }
        var price: String?
    }
    var priceInfo: PriceInfo = PriceInfo()
    
    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case url = "Url"
        case imageInfo = "Image"
        case priceInfo = "Price"
    }
}
