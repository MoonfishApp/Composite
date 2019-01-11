//
//  Operation.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 1/5/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

// operation1 ==> operation2 ==> operation3 // Execute in order 1 to 3

precedencegroup OperationChaining {
    associativity: left
}
infix operator ==> : OperationChaining

@discardableResult
func ==><T: Operation>(lhs: T, rhs: T) -> T {
    rhs.addDependency(lhs)
    return rhs
}
