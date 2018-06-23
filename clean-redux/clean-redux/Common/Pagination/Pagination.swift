//
//  Pagination.swift
//  clean-redux
//
//  Created by BOGU$ on 16/05/2018.
//  Copyright © 2018 lyzkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum PaginationEvent<Entity>: Event {
    case nextPage(entities: [Entity])
    case clear
}

struct PaginationState<Entity>: ReducibleState {
    
    let entities: [Entity]
    let lastPage: Int
    
    typealias E = PaginationEvent<Entity>
    
    static var initial: PaginationState<Entity> {
        return PaginationState<Entity>(entities: [], lastPage: 0)
    }
    
    static func reduce(state: PaginationState<Entity>, _ event: PaginationEvent<Entity>) -> PaginationState {
        switch event {
        case let .nextPage(entities):
            return PaginationState(
                entities: state.entities + entities,
                lastPage: state.lastPage + 1
            )
        case .clear:
            return initial
        }
    }
    
}

enum PaginationAction: Int {
    case next
    case reset
}

class PaginationCyclone<Entity>: Cyclone<PaginationState<Entity>, PaginationAction> {
    
    init<O: ObservableConvertibleType>(pageFactory: @escaping (Int) -> O) where O.E == [Entity] {
        super.init()
        
        let nextPage = state[sub: \.lastPage].flatMap(pageFactory)
        
        register(
            action: .next,
            input: nextPage.map(PaginationEvent.nextPage),
            single: true
        )
        register(
            action: .reset,
            input: Observable.concat(.just(.clear), nextPage.take(1).map(PaginationEvent.nextPage))
        )
    }
    
}
