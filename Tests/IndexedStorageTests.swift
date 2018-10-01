//
//  IndexedStorageTests.swift
//  TinyStorageTests
//
//  Created by Roy Hsu on 2018/10/1.
//

// MARK: - TinyStorageTests

import XCTest

@testable import TinyStorage

internal final class TinyStorageTests: XCTestCase {
    
    private final var observations: [Observation] = []
    
    internal final func testInitialize() {
        
        let storage = IndexedStorage<String>()
        
        XCTAssert(storage.isEmpty)
        
    }
    
    internal final func testExpressibleByArrayLiteral() {
    
        let storage: IndexedStorage = [
            "hello"
        ]
        
        XCTAssertEqual(
            storage.count,
            1
        )
        
        XCTAssertEqual(
            storage[0],
            "hello"
        )
    
    }
    
    internal final func testLoad() {
        
        let loadPromise = expectation(description: "Load the storage.")
        
        let observePromise = expectation(description: "Observe changes.")
        
        let storage: IndexedStorage = [
            "hello"
        ]
        
        XCTAssertFalse(storage.isLoaded)
        
        observations.append(
            storage.observe { change in
                
                defer { observePromise.fulfill() }
                
                let changes = change.currentValue
                
                XCTAssertEqual(
                    changes?.count,
                    1
                )
                
                XCTAssertEqual(
                    changes?[ AnyIndex(0) ],
                    StorageChange(
                        key: 0,
                        value: "hello"
                    )
                )
                
            }
        )
        
        storage.load { result in
            
            defer { loadPromise.fulfill() }
            
            switch result {
                
            case .success:
                
                XCTAssertEqual(
                    storage.count,
                    1
                )
                
                XCTAssertEqual(
                    storage[0],
                    "hello"
                )
                
            case let .failure(error): XCTFail("\(error)")
                
            }
            
        }
        
        wait(
            for: [
                loadPromise,
                observePromise
            ],
            timeout: 10.0
        )
        
    }
    
}
