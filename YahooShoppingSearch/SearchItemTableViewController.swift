//
//  SearchItemTableViewController.swift
//  YahooShoppingSearch
//
//  Created by beakhand on 2018/10/21.
//  Copyright © 2018年 beakchild. All rights reserved.
//

import UIKit
import RxSwift
import Moya

class SearchItemTableViewController: UITableViewController, UISearchBarDelegate {

    var itemDataArray = [ItemData]()
    var imageCache = NSCache<AnyObject, UIImage>()
    let appid = YahooClientID
    let entryURL: String = "https://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch"
    // 数字を金額形式にするフォーマッター
    let priceFormat = NumberFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 価格のフォーマット指定
        priceFormat.numberStyle = .currency
        priceFormat.currencyCode = "JPY"
    }
    
    // キーボードのSearchタップ
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 入力された文字列の取り出し
        guard let inputText = searchBar.text else {
            // 入力文字なし
            return
        }
        
        // 文字数確認
        guard inputText.lengthOfBytes(using: String.Encoding.utf8) > 0 else {
            return
        }
        
        // 現在のリストをクリア
        itemDataArray.removeAll()
        
        // Moya(Rx版) で接続する場合
        /*
        let disposeBag = DisposeBag()
        
        ApiManager.shared.request(YahooApi.GetSearchItem(searchWord: inputText))
            .subscribe(onSuccess: { (profile) in
                print(profile)
            }) { (error) in
                print(error)
            }
            .disposed(by: disposeBag)

        */
        
        // Moya(NoRx版) で接続する場合
        let request = YahooApi.GetSearchItem(searchWord: inputText)
        ApiManagerNoRx.shared.send(request) { (response, error) in
            if let response = response {
                print("@@@@@ res \(response)")
                // 商品のリストに追加
                self.itemDataArray.append(contentsOf: response.resultSet.firstObject.result.items)
                // テーブル描画更新
                self.tableView.reloadData()
            }
            if let error = error {
                print("@@@@@ err \(error)")
            }
        }
        
        // URLSession で接続する場合
        /*
        // パラメータ指定
        let parameter = ["appid": appid, "query": inputText]
        
        // パラメータをエンコードしたURLを作成
        let requestUrl = createRequestUrl(parameter: parameter)
        
        // API リクエスト
        request(requestUrl: requestUrl)
        */
        
        // キーボードを閉じる
        searchBar.resignFirstResponder()
        
    }
    
    // パラメータのURLをエンコードする
    func encodeParameter(key: String, value: String) -> String? {
        guard let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil // エンコード失敗
        }
        // エンコードした値を key=value 形式で返す
        return "\(key)=\(escapedValue)"
    }
    
    func createRequestUrl(parameter: [String: String]) -> String {
        var parameterString = ""
        for key in parameter.keys {
            // 値の取り出し
            guard let value = parameter[key] else {
                continue
            }
            // すでのパラメータが設定されていた場合
            if 0 < parameterString.lengthOfBytes(using: String.Encoding.utf8) {
                // パラメータのセパレーター、＆を追加する
                parameterString += "&"
            }
            // 値をエンコードする
            guard let encodeValue = encodeParameter(key: key, value: value) else {
                continue // エンコード失敗。次の処理
            }
            parameterString += encodeValue
            
        }
        let requestUrl = entryURL + "?" + parameterString
        return requestUrl
    
    }
    
    func request(requestUrl: String) {
        // URL 生成
        guard let url = URL(string: requestUrl) else {
            return
        }
        
        // リクエスト 生成
        let request = URLRequest(url: url)
        // APIコール
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            // 通信完了後の処理
            // エラーチェック
            guard error == nil else {
                // エラー表示
                let alert = UIAlertController(title: "エラー", message: error?.localizedDescription, preferredStyle: .alert)
                // メインスレッドで表示
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                    
                }
                return
            }
            // JSON データをパースして返す
            guard let _data = data else {
                return // データなし
            }
            
            do {
                // パース
                let resultSet = try JSONDecoder().decode(ItemSearchResultSet.self, from: _data)
                // 商品のリストに追加
                self.itemDataArray.append(contentsOf: resultSet.resultSet.firstObject.result.items)
                
                
            } catch let error {
                print("!!error!! : \(error)")
            }
            
            // テーブル描画更新
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        // 通信開始
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDataArray.count
    }

    // セル取得
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }
        let itemData = itemDataArray[indexPath.row]
        // 商品名設定
        cell.itemTitleLabel.text = itemData.name
        // 商品価格設定(日本通過の形式で設定)
        let number = NSNumber(integerLiteral: Int(itemData.priceInfo.price!)!)
        cell.itemPriceLabel.text = priceFormat.string(from: number)
        // 商品URLの設定
        cell.itemUrl = itemData.url
        // 画像の設定
        // すでにセルにある画像と同じか確認
        guard let itemImageUrl = itemData.imageInfo.medium else {
            // 画像なし製品
            return cell
        }
        // キャッシュの画像を取り出す
        if let cacheImage = imageCache.object(forKey: itemImageUrl as AnyObject) {
            // キャッシュ画像の設定
            cell.itemImageView.image = cacheImage
            return cell
        }
        
        // キャッシュ画像がないのでダウンロードする
        guard let url = URL(string: itemImageUrl) else {
            return cell // url が生成できなかった
        }
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data: Data?, response:URLResponse?, error:Error?) in
            guard error == nil else {
                return // エラーあり
            }
            guard let data = data else {
                return // データなし
            }
            guard let image = UIImage(data: data) else {
                return // 画像生成できず
            }
            // ダウンロードした画像をキャッシュしておく
            self.imageCache.setObject(image, forKey: itemImageUrl as AnyObject)
            // メインスレッドで画像設定
            DispatchQueue.main.async {
                cell.itemImageView.image = image
            }
        }
        task.resume()
        return cell
    }


    // MARK: - Navigation
    // 商品をタップして次の画面へ遷移するときの処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? ItemTableViewCell {
            if let webViewController = segue.destination as? WebViewController {
                webViewController.itemUrl = cell.itemUrl
            }
        }
    }

}
