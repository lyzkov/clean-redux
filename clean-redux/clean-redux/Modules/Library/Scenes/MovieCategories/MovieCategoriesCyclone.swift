//
//  MoviesCategoryFeedback.swift
//  clean-redux
//
//  Created by BOGU$ on 08/05/2018.
//  Copyright © 2018 lyzkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback
import Action

enum MovieCategoriesEvent: Event {
    case load(categories: [Category])
}

// TODO: separate state to another file?
struct MovieCategoriesState {
    let categories: [Category]
}

extension MovieCategoriesState: ReducibleState {
    
    typealias E = MovieCategoriesEvent
    
    static var initial: MovieCategoriesState = MovieCategoriesState(categories: [])
    
    // TODO: make reduce as monad
    static func reduce(state: MovieCategoriesState, _ event: MovieCategoriesEvent) -> MovieCategoriesState {
        switch event {
        case let .load(categories):
            return MovieCategoriesState(categories: categories) // TODO: use Lens for creating state object
        }
    }
    
}

class MovieCategoriesCyclone: Cyclone<MovieCategoriesState, EmptyAction> {
    
    // dependencies
    let pagination = PaginationCyclone { page in
        DataProvider().categories(page: page)
    }
    
    override init() {
        super.init()
        
        register(events: pagination.state[sub: \.items].map(MovieCategoriesEvent.load))
    }
    
}
