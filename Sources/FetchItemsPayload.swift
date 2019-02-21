//
//  FetchItemsPayload.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/9/22.
//

// MARK: - FetchItemsPayload

import TinyCore

public struct FetchItemsPayload<Item> where Item: Unique {

    public let items: [Item]

    public let next: Page?

    public init(
        items: [Item] = [],
        next: Page? = nil
    ) {

        self.items = items

        self.next = next

    }

}
