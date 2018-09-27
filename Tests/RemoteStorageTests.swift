//
//  RemoteStorageTests.swift
//  TinyStorageTests
//
//  Created by Roy Hsu on 2018/9/22.
//

// MARK: - RemoteStorageTests

import XCTest

@testable import TinyStorage

internal final class RemoteStorageTests: XCTestCase {

    internal final func testLoad() {

        let promise = expectation(description: "Load the storage.")

        let storage = RemoteStorage(
            resource: MessageResource(
                fetchItemsResult: .success(
                    FetchItemsPayload(
                        items: [
                            Message(identifier: "1"),
                            Message(identifier: "2")
                        ]
                    )
                )
            )
        )

        XCTAssertFalse(storage.isLoaded)

        storage.load { result in

            defer { promise.fulfill() }

            switch result {

            case .success:

                XCTAssertEqual(
                    storage.count,
                    2
                )

                XCTAssertEqual(
                    storage.value(forKey: "1"),
                    Message(identifier: "1")
                )

                XCTAssertEqual(
                    storage.value(forKey: "2"),
                    Message(identifier: "2")
                )

            case let .failure(error): XCTFail("\(error)")

            }

        }

        wait(
            for: [ promise ],
            timeout: 10.0
        )

    }

}
