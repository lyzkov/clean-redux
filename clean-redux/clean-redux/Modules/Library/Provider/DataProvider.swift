//
//  DataProvider.swift
//  clean-redux
//
//  Created by BOGU$ on 03/05/2018.
//  Copyright © 2018 lyzkov. All rights reserved.
//

import Foundation
import RxSwift

enum NetworkError: Error {
    case unknown(description: String)
}

class DataProvider {
    
    private static let categories = ["Thriller", "Comedy", "Action", "Adventure", "Comedy", "Crime", "Fantasy", "Historical", "Horror", "Document", "Saga", "Psychological", "Romance", "Science Fiction", "Thriller", "Western"].map(Category.init)
    
    private static let minimal = ["Thriller"].map(Category.init)
    
    // TODO: implement load more?
    func categories() -> Single<[Category]> {
        let result = Single.just(
            DataProvider.categories,
            scheduler: MainScheduler.instance
        )
        .delay(2.0, scheduler: MainScheduler.instance)
        
        return result
    }
    
    func categories(page: Int) -> Single<[Category]> {
        return Single.just(["Page: \(page)"].map(Category.init))
//        return Single.error(NetworkError.unknown(description: "Something wrong"))
            .delay(1.0, scheduler: MainScheduler.instance)
    }
    
}
