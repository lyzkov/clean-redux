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

extension ObservableConvertibleType where E: ReducibleState {
    
    subscript<V>(sub keyPath: KeyPath<E, V>) -> Observable<V> {
        return asObservable().map { $0[keyPath: keyPath] }
    }
    
}

typealias EventAction<E: Event> = Action<Void, E>

extension ObservableConvertibleType where E: Event {
    
    func asAction() -> EventAction<E> {
        let observable = asObservable()
        
        return Action {
            observable
        }
    }
    
    func asSingleAction() -> EventAction<E> {
        let observable = asObservable()
        
        return Action {
            observable.take(1)
        }
    }
    
}

extension ObservableConvertibleType {
    
    func asAction<R: Event>(_ eventMap: @escaping (E) -> R) -> EventAction<R> {
        return asObservable().map(eventMap).asAction()
    }
    
    func asSingleAction<R: Event>(_ eventMap: @escaping (E) -> R) -> EventAction<R> {
        return asObservable().map(eventMap).asSingleAction()
    }
    
}

class Cyclone<State: ReducibleState, Action: Hashable> {
    
    typealias E = State
    
    let state = ReplaySubject<State>.create(bufferSize: 1)
    var actions = [Action: EventAction<State.E>]()
    
    private let events = PublishSubject<State.E>()
    
    let disposeBag = DisposeBag()
    
    init() {
        Observable
            .system(
                initialState: State.initial,
                reduce: State.reduce,
                scheduler: MainScheduler.instance,
                scheduledFeedback: { [unowned self] _ in
                    self.events
                }
            )
            .skip(1)
            .share(replay: 1, scope: .whileConnected)
            .bind(to: state)
            .disposed(by: disposeBag)
    }
    
    func register(action: Action, input: Observable<State.E>, single: Bool = false) {
        if single {
            actions[action] = input.asSingleAction()
        } else {
            actions[action] = input.asAction()
        }
        actions[action]!.elements.bind(to: events).disposed(by: disposeBag)
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

