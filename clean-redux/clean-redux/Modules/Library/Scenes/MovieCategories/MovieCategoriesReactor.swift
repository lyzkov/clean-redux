//
//  MovieCategoriesReactor.swift
//  clean-redux
//
//  Created by BOGU$ on 14/06/2018.
//  Copyright © 2018 lyzkov. All rights reserved.
//

import Foundation
import RxSwift
import ReactorKit

protocol OutputProtocol {
    associatedtype State
    
    init(state: Observable<State>)
    
}

class MovieCategoriesReactor: Reactor {
    
    enum Action {
        case load
    }
    
    enum Mutation {
        case load(categories: [Category])
    }
    
    struct State {
        let categories: [Category]
    }
    
    struct Input {
        let categories: Observable<[Category]>
    }
    
    struct Output: OutputProtocol {

        let categoryNames: Observable<[String]>

        init(state: Observable<State>) {
            self.categoryNames = state.map { $0.categories.map { $0.name } }
        }

    }
    
    let input: Input
    
    lazy var output: Output = Output(state: state)
    
    let initialState = State(categories: [])
    
    init(input: Input) {
        self.input = input
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load:
            return input.categories.map(Mutation.load)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .load(categories):
            return State(categories: categories)
        }
    }
    
}
