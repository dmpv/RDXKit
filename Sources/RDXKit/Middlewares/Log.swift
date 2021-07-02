//
//  Log.swift
//  Messenger
//
//  Created by Dmitry Purtov on 20.12.2020.
//  Copyright © 2020 SoftPro. All rights reserved.
//

import Foundation

func makeLogMiddleware<StateT: Equatable>(
    actionsOnly: Bool = false,
    log: @escaping (_ message: String) -> Void = { print($0) })
-> Middleware<Store<StateT>, AnyAction<StateT>> {
    makeHookMiddleware(
        config: .init(
            preHook: { _, action in
                log("\n-> \(action.unbox)")
            },
            postHook: actionsOnly ? nil : { oldState, newState, action in
                if newState == oldState {
                    log("state unchanged")
                } else {
                    log("\(newState)")
                }
            }
        )
    )
}
