//
//  Store+proxy.swift
//  Messenger
//
//  Created by Dmitry Purtov on 20.12.2020.
//  Copyright © 2020 SoftPro. All rights reserved.
//

import Foundation

import LensKit

extension Store {
    public func makeProxy<SubstateT>(config: ProxyConfig<StateT, SubstateT>) -> Store<SubstateT> {
        let proxyStore = RDXKit.Store(state: config.lens.get(state))
        proxyStore.apply(
            middleware: makeProxyMiddleware(store: self, actionMap: config.actionMap)
        )
        proxyStore.apply(middleware: makeThunkMiddleware())

        stateObservable
            .addObserver { [weak proxyStore] state in
                proxyStore?.dispatch(ProxyAction(state: config.lens.get(state)))
            }
            .disposed(by: proxyStore.disposable)

        return proxyStore
    }
}

public struct ProxyConfig<StateT, SubstateT> {
    var lens: Lens<StateT, SubstateT>
    // dp-sticky-refactor-TODO: rename to actionTransform
    var actionMap: ActionMap<StateT, SubstateT>
}

extension ProxyConfig {
    public init(lens: Lens<StateT, SubstateT>) {
        self.init(lens: lens) { anySubaction in anySubaction.converted(with: lens) }
    }
}
