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
    
    case loadCategories(categories: [Category])
    
}

// TODO: separate state to another file?
struct MovieCategoriesState: Encodable {
    
    let categories: [Category]
    
}

extension MovieCategoriesState: ReducibleState {
    
    typealias E = MovieCategoriesEvent
    
    static var initial: MovieCategoriesState = MovieCategoriesState(categories: [])
    
    // TODO: make reduce as monad
    static func reduce(state: MovieCategoriesState, _ event: MovieCategoriesEvent) -> MovieCategoriesState {
        switch event {
        case let .loadCategories(categories):
            return MovieCategoriesState(categories: categories) // TODO: use Lens for creating state object
        }
    }
    
}

class MovieCategoriesCyclone: Cyclone<MovieCategoriesState> {
    
    // dependencies
    let pagination = PaginationCyclone { page in
        DataProvider().categories(page: page)
    }
    
    // actions
    let loadAction: EventAction<MovieCategoriesEvent>
    
    // inputs
    let categoriesInput = PublishSubject<[Category]>()
    
    // outputs
    var categoryNames: Observable<[String]> {
        return state.map { $0.categories.map { $0.name } }
    }
    
    private let disposeBag = DisposeBag()
    
    init() {
        let loadAction = categoriesInput.asObservable().asAction(MovieCategoriesEvent.loadCategories)
        self.loadAction = loadAction
        
        super.init { state in
            [loadAction]
        }
        
        loadAction.inputs.bind(to: pagination.resetAction.inputs).disposed(by: disposeBag)
        pagination.entities.asObservable().bind(to: categoriesInput).disposed(by: disposeBag)
    }
    
}
