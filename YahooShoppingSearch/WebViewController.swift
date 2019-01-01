//
//  WebViewController.swift
//  YahooShoppingSearch
//
//  Created by beakhand on 2018/10/24.
//  Copyright © 2018年 beakchild. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var itemUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // User Agent を iPhone に設定する
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1"
        // WebView の URL を読み込ませる
        guard let itemUrl = itemUrl else {
            return
        }
        guard let url = URL(string: itemUrl) else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
