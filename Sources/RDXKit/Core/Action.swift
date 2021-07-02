//
//  Action.swift
//  Messenger
//
//  Created by Dmitry Purtov on 20.12.2020.
//  Copyright © 2020 SoftPro. All rights reserved.
//

import Foundation

import LensKit

public protocol Action: CustomDebugStringConvertible {
    associatedtype State

    func adjust(_ state: inout State)

    var id: String { get }
}

extension Action {
    public var id: String {
        "\(Self.self)"
    }

    public func boxed() -> AnyAction<State> {
        .init(self)
    }

    public var debugDescription: String {
        "\(type(of: self))"
    }

    func reduce(_ state: State) -> State {
        var state = state
        adjust(&state)
        return state
    }

    func converted<SuperstateT>(with lens: Lens<SuperstateT, State>) -> AnyAction<SuperstateT> {
        Custom(id: "\(SuperstateT.self)::\(id)") { superstate in
            lens.set(&superstate, reduce(lens.get(superstate)))
        }.boxed()
    }

    func converted<SuperstateT>(with lens: Lens<SuperstateT, State?>) -> AnyAction<SuperstateT> {
        Custom(id: "\(SuperstateT.self)::\(id)") { superstate in
            guard let state = lens.get(superstate) else { return }
            lens.set(&superstate, reduce(state))
        }.boxed()
    }
}

public struct Custom<StateT>: Action {
    public let id: String

    let adjustBody: (inout StateT) -> Void

    public init(id: String, adjustBody: @escaping (inout StateT) -> Void) {
        self.id = id
        self.adjustBody = adjustBody
    }

    public func adjust(_ state: inout StateT) {
        adjustBody(&state)
    }

    public var debugDescription: String {
        "Custom/\(id)"
    }
}

extension StoreType {
    public func dispatchCustom(_ id: String = "", adjustBody: @escaping (inout State) -> Void) {
        dispatch(Custom(id: id, adjustBody: adjustBody))
    }
}
