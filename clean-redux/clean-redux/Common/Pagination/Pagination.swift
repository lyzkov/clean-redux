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

enum PaginationAction: Int {
    case next
    case reset
}

enum PaginationEvent<Item>: Event {
    case next(items: [Item])
    case reset
}

struct PaginationState<Item> {
    let items: [Item]
    let page: Int
}

extension PaginationState: ReducibleState {
    
    typealias E = PaginationEvent<Item>
    
    static var initial: PaginationState<Item> {
        return PaginationState<Item>(items: [], page: 0)
    }
    
    static func reduce(state: PaginationState<Item>, _ event: PaginationEvent<Item>) -> PaginationState {
        switch event {
        case let .next(items):
            return PaginationState(
                items: state.items + items,
                page: state.page + 1
            )
        case .reset:
            return initial
        }
    }
    
}

class PaginationCyclone<Item>: Cyclone<PaginationState<Item>, PaginationAction> {
    
    init<O: ObservableConvertibleType>(itemsFactory: @escaping (Int) -> O) where O.E == [Item] {
        super.init()
        
        let nextItems = output(\.page).flatMap(itemsFactory).take(1)
        register(action: .next, events: nextItems.map(PaginationEvent.next))
        register(action: .reset, events: Observable.concat(.just(.reset), nextItems.map(PaginationEvent.next)))
    }
    
}
