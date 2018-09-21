//
//  MemoryCache.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/9/21.
//

public protocol Storage {
    
    associatedtype Key: Hashable
    
    associatedtype Value
    
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
    
    private let _value: (Key) -> Value?
    
    private let _setValue: (Value?, Key) -> Void
    
    private let _count: () -> Int
    
    public init<S>(_ storage: S)
    where
        S: Storage,
        S.Key == Key,
        S.Value == Value {
        
        self._value = storage.value
            
        self._setValue = storage.setValue
            
        self._count = { storage.count }
        
    }
    
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

public struct StorageContainer<Key, Value> where Key: Hashable {
    
    public typealias Storage = AnyStorage<Key, Value>
    
    private var storage: Storage
    
    public init(storage: Storage) { self.storage = storage }
    
}

// MARK: - MemeryCache

public final class MemeryCache<Key, Value>: Storage, ExpressibleByDictionaryLiteral where Key: Hashable {
    
    private typealias Base = Dictionary<Key, Value>
    
    private final var _base: Base
    
    public init() { self._base = [:] }
    
    public init(
        dictionaryLiteral elements: (Key, Value)...
    ) { self._base = Base(uniqueKeysWithValues: elements) }
    
    public final func value(forKey key: Key) -> Value? { return _base[key] }
    
    public final func setValue(
        _ value: Value?,
        forKey key: Key
    ) { _base[key] = value }
    
    public final var count: Int { return _base.count }
    
}
