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

enum PaginatedEvent<Entity>: Event {
    case nextPage(entities: [Entity])
    case clear
}

struct PaginatedState<Entity> {
    let entities: [Entity]
    let lastPage: Int
}

extension PaginatedState: ReducibleState {
    
    typealias E = PaginatedEvent<Entity>
    
    static var initial: PaginatedState<Entity> {
        return PaginatedState<Entity>(entities: [], lastPage: 0)
    }

    static func reduce(state: PaginatedState<Entity>, _ event: PaginatedEvent<Entity>) -> PaginatedState {
        switch event {
        case let .nextPage(entities):
            return PaginatedState(
                entities: state.entities + entities,
                lastPage: state.lastPage + 1
            )
        case .clear:
            return initial
        }
    }
    
}

class PaginationCyclone<Entity>: Cyclone<PaginatedState<Entity>> {
    
    // actions
    let nextAction: EventAction<PaginatedEvent<Entity>>
    let resetAction: EventAction<PaginatedEvent<Entity>>
    
    // inputs
    
    // outputs
    var entities: Observable<[Entity]> {
        return state.map { $0.entities }
    }
    var lastPage: Observable<Int> {
        return state.map { $0.lastPage }
    }
    
    private let disposeBag = DisposeBag()
    
    init<O: ObservableConvertibleType>(pageFactory: @escaping (Int) -> O) where O.E == [Entity] {
        let entitiesPaged = ReplaySubject<[Entity]>.create(bufferSize: 1)
        let nextAction = entitiesPaged.take(1).asAction(PaginatedEvent.nextPage)
        let resetAction = Observable.concat(
                .just(.clear),
                entitiesPaged.take(1).map(PaginatedEvent.nextPage)
            )
            .asAction()
        
        self.nextAction = nextAction
        self.resetAction = resetAction
        
        super.init { state in
            return [nextAction, resetAction]
        }
        
        lastPage.asObservable()
            .flatMap(pageFactory)
            .bind(to: entitiesPaged)
            .disposed(by: disposeBag)
    }
    
}
