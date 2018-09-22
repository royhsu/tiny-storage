//
//  MemoryCacheTests.swift
//  TinyStorage Tests
//
//  Created by Roy Hsu on 2018/9/13.
//  Copyright © 2018 TinyWorld. All rights reserved.
//

// MARK: - AnyStorageTests

import TinyCore
import XCTest

@testable import TinyStorage

internal final class MemoryCacheTests: XCTestCase {
    
    internal final var subscriptions: [ObservableSubscription] = []
    
    internal final func testInitialize() {
        
        let cache = MemoryCache<String, String>()
        
        XCTAssertEqual(
            cache.count,
            0
        )
        
    }
    
    internal final func testExpressibleByDictionaryLiteral() {
        
        let cache: MemoryCache = [
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
    
    internal final func testLoad() {
        
        let promise = expectation(description: "Load the cache.")
        
        let cache = MemoryCache<String, String>()
        
        XCTAssertFalse(cache.isLoaded)
        
        cache.load { result in
            
            promise.fulfill()
            
            switch result {
                
            case .success:
                
                XCTAssert(cache.isLoaded)
                
                XCTAssert(cache.isEmpty)
                
            case let .failure(error): XCTFail("\(error)")
                
            }
            
        }
        
        wait(
            for: [ promise ],
            timeout: 10.0
        )
        
    }
    
    internal final func testSetValue() {
        
        let promise = expectation(description: "Get notified about changes.")
        
        var cache = MemoryCache<String, String>()
        
        let subscription = cache.changes.subscribe { event in
            
            promise.fulfill()
            
            let changes = event.currentValue
            
            XCTAssertEqual(
                changes?.count,
                1
            )
            
            let helloKeyChange = changes?.first { $0.key == "hello" }
            
            XCTAssertEqual(
                helloKeyChange?.value,
                "world"
            )
            
        }
        
        subscriptions.append(subscription)
        
        cache["hello"] = "world"
        
        XCTAssertEqual(
            cache["hello"],
            "world"
        )
        
        XCTAssertEqual(
            cache.count,
            1
        )
        
        wait(
            for: [ promise ],
            timeout: 10.0
        )
        
    }
    
    internal final func testMergeValues() {
        
        let promise = expectation(description: "Get notified about changes.")
        
        var cache: MemoryCache = [
            "existing": "value",
            "replacing": "current value"
        ]
        
        let subscription = cache.changes.subscribe { event in
            
            promise.fulfill()
            
            let changes = event.currentValue
            
            XCTAssertEqual(
                changes?.count,
                2
            )
            
            let existingKeyChange = changes?.first { $0.key == "existing" }
            
            XCTAssert(existingKeyChange == nil)
            
            let newKeyChange = changes?.first { $0.key == "new" }
            
            XCTAssert(newKeyChange != nil)
            
            XCTAssertEqual(
                newKeyChange?.value,
                "value"
            )
            
            let replacingKeyChange = changes?.first { $0.key == "replacing" }
            
            XCTAssert(replacingKeyChange != nil)
            
            XCTAssertEqual(
                replacingKeyChange?.value,
                "by value"
            )
            
            let nilKeyChange = changes?.first { $0.key == "nil" }
            
            XCTAssert(nilKeyChange == nil)
            
        }
        
        subscriptions.append(subscription)
        
        let newElements: [ (String, String?) ] =  [
            ("new", "value"),
            ("replacing", "by value"),
            ("nil", nil)
        ]
        
        cache.merge(
            AnySequence(newElements)
        )
        
        XCTAssertEqual(
            cache["new"],
            "value"
        )
        
        XCTAssertEqual(
            cache["existing"],
            "value"
        )
        
        XCTAssertEqual(
            cache["replacing"],
            "by value"
        )
        
        XCTAssert(
            cache["nil"] == nil
        )
        
        XCTAssertEqual(
            cache.count,
            3
        )
        
        wait(
            for: [ promise ],
            timeout: 10.0
        )
        
    }
    
    internal final func testRemoveValue() {
        
        let promise = expectation(description: "Get notified about changes.")
        
        var cache: MemoryCache = [ "nil": "non-nil value" ]
        
        let subscription = cache.changes.subscribe { event in
        
            promise.fulfill()
        
            let changes = event.currentValue
        
            XCTAssertEqual(
                changes?.count,
                1
            )
        
            let nilKeyChange = changes?.first { $0.key == "nil" }
            
            XCTAssert(nilKeyChange != nil)
        
            XCTAssertEqual(
                nilKeyChange?.value,
                nil
            )
        
        }
        
        subscriptions.append(subscription)
        
        cache["nil"] = nil
        
        XCTAssert(cache.isEmpty)
        
        wait(
            for: [ promise ],
            timeout: 10.0
        )
        
    }
    
    internal final func testRemoveAllValues() {
        
        let promise = expectation(description: "Remove all values.")
        
        let cache: MemoryCache = [
            "removing": "value"
        ]
        
        let subscription = cache.changes.subscribe { event in
                
            promise.fulfill()
            
            XCTAssert(cache.isEmpty)
            
            let changes = event.currentValue
            
            let removeKeyChange = changes?.first { $0.key == "removing" }
            
            XCTAssert(removeKeyChange != nil)
            
            XCTAssertEqual(
                removeKeyChange?.value,
                "value"
            )
            
        }
        
        subscriptions.append(subscription)
        
        cache.removeAll()
        
        wait(
            for: [ promise ],
            timeout: 10.0
        )
        
    }
    
    internal final func testLazyCollection() {
        
        let cache: MemoryCache = [
            "hello": "world"
        ]
        
        XCTAssertEqual(
            cache.lazy.elements,
            [ "hello": "world" ]
        )
        
    }
    
    internal final func testTypeErasable() {
        
        let cache = MemoryCache<String, String>()
        
        _ = AnyStorage(cache)
        
        XCTSuccess()
        
    }
    
}
