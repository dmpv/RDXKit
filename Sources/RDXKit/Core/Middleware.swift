//
//  Middleware.swift
//  Messenger
//
//  Created by Dmitry Purtov on 20.12.2020.
//  Copyright © 2020 SoftPro. All rights reserved.
//

import Foundation

public protocol StoreType {
    associatedtype State: Equatable

    var state: State { get }

    init(state: State)

    func apply(middleware: @escaping Middleware<Self, AnyAction<State>>)

    func dispatch<ActionT: Action>(_ action: ActionT) where ActionT.State == State
}

public typealias Middleware<StoreT: StoreType, ActionT: Action> = (StoreT, @escaping Dispatch<ActionT>) -> Dispatch<ActionT>
