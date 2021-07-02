//
//  Proxy.swift
//  Messenger
//
//  Created by Dmitry Purtov on 20.12.2020.
//  Copyright © 2020 SoftPro. All rights reserved.
//

import Foundation

typealias ActionMap<StateT, SubstateT> = (AnyAction<SubstateT>) -> AnyAction<StateT>

struct ProxyAction<StateT>: Action {
    var state: StateT

    func adjust(_ state: inout StateT) {
        state = self.state
    }
}

func makeProxyMiddleware<StoreT: StoreType, SubstoreT: StoreType>(
    store: StoreT,
    actionMap: @escaping ActionMap<StoreT.State, SubstoreT.State>
) -> Middleware<SubstoreT, AnyAction<SubstoreT.State>> {
    return { _, next in
        return { action in
            switch action.unbox {
            case is ProxyAction<SubstoreT.State>:
                next(action)
            default:
                store.dispatch(actionMap(action))
            }
        }
    }
}
