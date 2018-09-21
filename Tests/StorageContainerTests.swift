//
//  StorageContainerTests.swift
//  TinyStorage Tests
//
//  Created by Roy Hsu on 2018/9/21.
//

// MARK: - StorageContainerTests

import TinyCore
import XCTest

@testable import TinyStorage

internal final class StorageContainerTests: XCTestCase {
    
    internal final var subscriptions: [ObservableSubscription] = []
    
    internal final func testObserveChangeBySettingNilForKey() {
        
        let promise = expectation(description: "Get notified about changes.")
        
        let cache: MemeryCache = [ "nil": "non-nil value" ]
        
        var container = StorageContainer(storage: cache)
        
        subscriptions.append(
            container.changes.subscribe { event in
                
                promise.fulfill()
                
                let changes = event.currentValue
                
                XCTAssertEqual(
                    changes?.count,
                    1
                )
                
                let nilKeyChange = changes?.first { $0.key == "nil" }
                
                XCTAssert(nilKeyChange != nil)
                
                XCTAssert(container.storage.isEmpty)
                
            }
        )
        
//        container.storage["nil"] = nil
        
        container.storage["nil"] = "test"
        
        wait(
            for: [ promise ],
            timeout: 10.0
        )
        
    }
    
}
