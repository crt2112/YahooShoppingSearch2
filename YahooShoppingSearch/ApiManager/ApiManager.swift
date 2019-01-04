//
//  ApiManager.swift
//  YahooShoppingSearch
//
//  Created by beakhand on 2019/01/02.
//  Copyright © 2019 beakchild. All rights reserved.
//

import Moya
import RxSwift

extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

class ApiManager {
    static let shared = ApiManager()
    private let provider = MoyaProvider<MultiTarget>()
    func request<R>(_ request: R) -> Single<R.Response> where R: YahooApiTargetType {
        let target = MultiTarget(request)
        return provider.rx.request(target)
            .filterSuccessfulStatusCodes()
            .map(R.Response.self)
    }
}

protocol YahooApiTargetType: TargetType {
    associatedtype Response: Codable
}

extension YahooApiTargetType {
    var baseURL: URL { return URL(string: "https://shopping.yahooapis.jp/ShoppingWebService/V1/json")! }
    var headers: [String : String]? { return nil }
    var sampleData: Data {
        // ここでスタブを設定できる
        let path = Bundle.main.path(forResource: "samples", ofType: "json")!
        return FileHandle(forReadingAtPath: path)!.readDataToEndOfFile()
    }
}

enum YahooApi {
    struct GetSearchItem: YahooApiTargetType {
        typealias Response = ItemSearchResultSet
        var method: Moya.Method { return .get }
        var path: String { return "/itemSearch" }
        var task: Task { return .requestParameters(parameters: ["appid": YahooClientID, "query": searchWord], encoding: URLEncoding.default) }
        let searchWord: String
        init(searchWord: String) {
            self.searchWord = searchWord
        }
    }
}

