//
//  PaginationReactor.swift
//  clean-redux
//
//  Created by BOGU$ on 13/06/2018.
//  Copyright © 2018 lyzkov. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit

class PaginationReactor<Entity>: Reactor {
    
    enum Action {
        case nextPage
    }
    
    enum Mutation {
        case nextPage(entities: [Entity])
    }
    
    struct State {
        let entities: [Entity]
        let nextPage: Int
    }
    
    let initialState = State(entities: [], nextPage: 1)
    
    private let pageFactory: (Int) -> Observable<[Entity]>
    
    init(pageFactory: @escaping (Int) -> Observable<[Entity]>) {
        self.pageFactory = pageFactory
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .nextPage:
            return pageFactory(currentState.nextPage)
                .map { .nextPage(entities: $0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .nextPage(entities):
            return State(
                entities: state.entities + entities,
                nextPage: state.nextPage + 1
            )
        }
    }
    
}
