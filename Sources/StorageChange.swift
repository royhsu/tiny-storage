//
//  StorageChange.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/9/21.
//

// MARK: - StorageChange

public struct StorageChange<Key, Value> where Key: Hashable {

    public let key: Key

    public let value: Value?

    public init(key: Key, value: Value?) {

        self.key = key

        self.value = value

    }

}

// MARK: - Hashable

extension StorageChange: Hashable {

    public static func == (
        lhs: StorageChange<Key, Value>,
        rhs: StorageChange<Key, Value>
    )
    -> Bool { return lhs.key == rhs.key }

    public func hash(into hasher: inout Hasher) { hasher.combine(key.hashValue) }

}
