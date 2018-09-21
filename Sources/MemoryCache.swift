//
//  MemoryCache.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/9/21.
//

public protocol Storage {
    
    associatedtype Key: Hashable
    
    associatedtype Value
    
    typealias Change = StorageChange<Key, Value>
    
    typealias Changes = AnyCollection<Change>
    
    var changes: Observable<Changes> { get }
    
    func value(forKey key: Key) -> Value?
    
    func setValue(
        _ value: Value?,
        forKey key: Key
    )
    
    var count: Int { get }
    
}

public extension Storage {
    
    public subscript(key: Key) -> Value? {
        
        get { return value(forKey: key) }
        
        set {
            
            setValue(
                newValue,
                forKey: key
            )
            
        }
        
    }
    
}

public struct AnyStorage<Key, Value>: Storage where Key: Hashable {
    
    private let _changes: () -> Observable<Changes>
    
    private let _value: (Key) -> Value?
    
    private let _setValue: (Value?, Key) -> Void
    
    private let _count: () -> Int
    
    public init<S>(_ storage: S)
    where
        S: Storage,
        S.Key == Key,
        S.Value == Value {
            
        self._changes = { storage.changes }
        
        self._value = storage.value
            
        self._setValue = storage.setValue
            
        self._count = { storage.count }
        
    }
    
    public var changes: Observable<AnyCollection<StorageChange<Key, Value>>> { return _changes() }
    
    public func value(forKey key: Key) -> Value? { return _value(key) }
    
    public func setValue(
        _ value: Value?,
        forKey key: Key
    ) {
    
        _setValue(
            value,
            key
        )
        
    }
    
    public var count: Int { return _count() }
    
}

public extension Storage {
    
    public var isEmpty: Bool { return (count == 0) }
    
}

import TinyCore

public struct StorageContainer<Key, Value> where Key: Hashable {
    
    public struct Change: Hashable {
        
        public let key: Key
        
        public let value: Value?
        
        public init(
            key: Key,
            value: Value?
        ) {
            
            self.key = key
            
            self.value = value
            
        }
        
        public static func == (
            lhs: StorageContainer.Change,
            rhs: StorageContainer.Change
        )
        -> Bool { return lhs.key == rhs.key }
        
        public func hash(into hasher: inout Hasher) { hasher.combine(key.hashValue) }
        
    }
    
    public typealias Changes = Set<Change>
    
    public var storage: AnyStorage<Key, Value> {
        
        didSet(oldStorage) {

//            let oldSet = Set(
//                oldStorage.lazy.elements.map(Change.init)
//            )
//
//            let newSet = Set(
//                storage.lazy.elements.map(Change.init)
//            )
//
//            let diff = newSet.subtracting(newSet)
//
//            print("diff", diff)
            
//            let s = AnySequence(oldStorage.lazy.elements)
//
//            Set<<#Element: Hashable#>>(s)
            
//           oldStorage.lazy.
            
//            changes.value = [
//                Change(
//                    key: key,
//                    value: value
//                )
//            ]
            
        }
        
    }
    
    public let changes: Observable<Changes>
    
    public init<S>(storage: S)
    where
        S: Storage,
        S.Key == Key,
        S.Value == Value {
            
        self.storage = AnyStorage(storage)
            
        self.changes = Observable<Changes>()
            
    }
    
}

// MARK: - MemeryCache

public final class MemeryCache<Key, Value>: Storage, ExpressibleByDictionaryLiteral where Key: Hashable {
    
    private typealias Base = Dictionary<Key, Value>
    
    private final var _base: Base
    
    public let changes: Observable<Changes> = Observable()
    
    public init() { self._base = [:] }
    
    public init(
        dictionaryLiteral elements: (Key, Value)...
    ) { self._base = Base(uniqueKeysWithValues: elements) }
    
    public final func value(forKey key: Key) -> Value? { return _base[key] }
    
    public final func setValue(
        _ value: Value?,
        forKey key: Key
    ) {
        
        _base[key] = value
        
        changes.value = AnyCollection(
            [
                Change(
                    key: key,
                    value: value
                )
            ]
        )
        
    }
    
    public final var count: Int { return _base.count }
    
}
