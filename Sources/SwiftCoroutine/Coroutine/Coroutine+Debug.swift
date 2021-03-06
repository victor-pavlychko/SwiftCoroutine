//
//  Coroutine+Debug.swift
//  SwiftCoroutine
//
//  Created by Alex Belozierov on 19.12.2019.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

#if SWIFT_PACKAGE
import CCoroutine
#endif

extension Coroutine {
    
    @inline(never) public static var currentStackUsed: Int? {
        guard let coroutine = try? Coroutine.current() else { return nil }
        return coroutine.distanceToStack(from: _frameAddress())
    }
    
    @inline(never) public static var currentStackFreeSpace: Int? {
        guard let coroutine = try? Coroutine.current() else { return nil }
        return coroutine.stackSize - coroutine.distanceToStack(from: _frameAddress())
    }
    
    private func distanceToStack(from pointer: UnsafeRawPointer) -> Int {
        pointer.distance(to: context.stackStart)
    }
    
}
