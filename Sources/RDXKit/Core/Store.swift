//
//  Store.swift
//  Messenger
//
//  Created by Dmitry Purtov on 20.12.2020.
//  Copyright © 2020 SoftPro. All rights reserved.
//

import Foundation

import ToolKit

public typealias Dispatch<ActionT: Action> = (ActionT) -> Void

public final class Store<StateT: Equatable>: StoreType {
    public private(set) var state: StateT

    private(set) var disposable = Disposable()

    private lazy var dispatchBody: Dispatch<AnyAction<StateT>> = { [weak self] action in
        assert(Thread.isMainThread)
        guard let self = self else { return }
        action.adjust(&self.state)
    }

    public func apply(middleware: @escaping Middleware<Store, AnyAction<StateT>>) {
        let dispatchBody = self.dispatchBody
        self.dispatchBody = { [weak self] action in
            guard let self = self else { return }
            middleware(self, dispatchBody)(action)
        }
    }

    public private(set) lazy var stateObservable = Observable(value: state)

    var broadcasting: AnyAction<StateT>?

    public func dispatch<ActionT: Action>(_ action: ActionT) where ActionT.State == StateT {
        dispatchBody(action.boxed())
        if let _ = broadcasting {
            fatalError(.shouldNeverBeCalled())
        }
        broadcasting = action.boxed()
        stateObservable.value = state
        broadcasting = nil
    }

    public init(state: StateT) {
        self.state = state
    }
}
