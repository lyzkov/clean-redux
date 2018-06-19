//
//  AppDelegate.swift
//  clean-redux
//
//  Created by BOGU$ on 27/04/2018.
//  Copyright © 2018 lyzkov. All rights reserved.
//

import UIKit
import RxSwift
import RxFeedback

struct LogState: Encodable {
    
    let logs: [String]
    
}

enum LogEvent {
    case newState(log: String)
}

extension LogEvent: Event {
    
}

extension LogState: ReducibleState {
    
    typealias E = LogEvent
    
    static var initial: LogState {
        return LogState(logs: [])
    }
    
    static func reduce(state: LogState, _ event: LogEvent) -> LogState {
        if case let .newState(log) = event {
            return LogState(logs: state.logs + [log])
        }
        
        return state
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let logger: ReplaySubject<Observable<String>> = .create(bufferSize: 1)
    
    let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let cyclone = Observable.system(
            initialState: LogState.initial,
            reduce: LogState.reduce,
            scheduler: MainScheduler.instance,
            scheduledFeedback: bind(self) { this, state in
                Bindings(
                    subscriptions: [
                        state.map { $0.logs.last }.subscribe(onNext: { print($0 ?? "") })
                    ],
                    events: [
                        this.logger.flatMap { $0 }.map(LogEvent.newState)
                    ]
                )
            }
        )
        cyclone.subscribe().disposed(by: disposeBag)
        
        return true
    }

}

