//
//  Cyclone.swift
//  clean-redux
//
//  Created by BOGU$ on 15/06/2018.
//  Copyright © 2018 lyzkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import RxFeedback

// TODO: error handling through feedback cycle (alert, logging)
// TODO: navigation through feedback cycle (routing)
// TODO: transition states, how to show loading in progress?

// TODO: write unit tests for reducer
// TODO: write integration tests for all action-reducer-output logic
// TODO: write UI snapshot tests

protocol Event { }

protocol ReducibleState {
    
    associatedtype E: Event
    
    static var initial: Self { get }
    
    static func reduce(state: Self, _ event: E) -> Self
    
}

typealias EventAction<E: Event> = Action<Void, E>

extension ObservableConvertibleType where E: Event {
    
    func asAction() -> EventAction<E> {
        let observable = asObservable()
        
        return Action {
            observable
        }
    }
    
}

extension ObservableConvertibleType {
    
    func asAction<R: Event>(_ eventMap: @escaping (E) -> R) -> EventAction<R> {
        return asObservable().map(eventMap).asAction()
    }
    
}

class Cyclone<State: ReducibleState> {
    
    private typealias Feedback = (ObservableSchedulerContext<State>) -> Observable<State.E>
    
    let state: Observable<State>
    
    init(eventsFactory: @escaping (Observable<State>) -> [EventAction<State.E>]) {
        state = Observable.system(
            initialState: State.initial,
            reduce: State.reduce,
            scheduler: MainScheduler.instance,
            scheduledFeedback: { state in
                Observable.merge(eventsFactory(state.asObservable()).map { $0.elements })
            }
        )
    }
    
}

extension ObservableConvertibleType where E: Event {
    
    func cyclone<State: ReducibleState>(feedback: @escaping (ObservableSchedulerContext<State>, Observable<E>) -> Observable<E>) -> Observable<State> where State.E == E {
        let events = asObservable()
        return Observable.system(
            initialState: State.initial,
            reduce: State.reduce,
            scheduler: MainScheduler.instance,
            scheduledFeedback: { state in feedback(state, events) }
        )
    }
    
}
