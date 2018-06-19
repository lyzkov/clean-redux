//
//  ObservableType+Extras.swift
//  clean-redux
//
//  Created by BOGU$ on 02/05/2018.
//  Copyright © 2018 lyzkov. All rights reserved.
//

import RxSwift

extension ObservableType {
    
    func ignoreAll() -> Observable<Void> {
        return self.map { _ in }
    }
    
    func unwrap<T>() -> Observable<T> where E == Optional<T> {
        return self.filter { $0 != nil }.map { $0! }
    }
    
}
