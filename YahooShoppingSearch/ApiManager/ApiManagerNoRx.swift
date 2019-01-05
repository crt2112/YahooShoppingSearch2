//
//  ApiManagerNoRx.swift
//  YahooShoppingSearch
//
//  Created by beakhand on 2019/01/05.
//  Copyright © 2019 beakchild. All rights reserved.
//

// Rx を使わない版も試してみる
import Foundation
import Moya

class ApiManagerNoRx {
    static let shared = ApiManagerNoRx()
    
    func send<Request: YahooApiTargetType>(_ request: Request, completion: @escaping (_ response: Request.Response?, _ error: Moya.MoyaError?) -> Void) -> Void {
        let provider = MoyaProvider<MultiTarget>()
        let target = MultiTarget(request)
        provider.request(target) { (result) in
            switch result {
            case let .success(response):
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                
                do {
                    let decodedResponse = try response.map(Request.Response.self, using: jsonDecoder, failsOnEmptyData: true)
                    completion(decodedResponse, nil)
                } catch {
                    print(error.localizedDescription)
                }
            case let .failure(error):
                completion(nil, error)
            }
        }
    }
}
