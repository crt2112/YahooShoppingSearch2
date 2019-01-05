//
//  ApiManager.swift
//  YahooShoppingSearch
//
//  Created by beakhand on 2019/01/02.
//  Copyright © 2019 beakchild. All rights reserved.
//

import Moya
import RxSwift

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
