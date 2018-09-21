//
//  MemoryCacheTests.swift
//  TinyStorage Tests
//
//  Created by Roy Hsu on 2018/9/13.
//  Copyright © 2018 TinyWorld. All rights reserved.
//

// MARK: - AnyStorageTests

import XCTest

@testable import TinyStorage

internal final class MemoryCacheTests: XCTestCase {
    
    internal final func testInitialize() {
        
        let cache = MemeryCache<String, String>()
        
        XCTAssertEqual(
            cache.count,
            0
        )
        
    }
    
    internal final func testExpressibleByDictionaryLiteral() {
        
        let cache: MemeryCache = [
            "hello": "world"
        ]
        
        XCTAssertEqual(
            cache.count,
            1
        )
        
        XCTAssertEqual(
            cache["hello"],
            "world"
        )
        
    }
    
    internal final func testSetValue() {
        
        var cache: MemeryCache = [
            "hello": "world"
        ]
        
        cache["hello"] = nil
        
        XCTAssertEqual(
            cache["hello"],
            nil
        )
        
    }
    
    internal final func testTypeErasable() {
        
        let cache = MemeryCache<String, String>()
        
        _ = AnyStorage(cache)
        
        XCTSuccess()
        
    }
    
}
