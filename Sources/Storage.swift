//
//  Storage.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/9/21.
//

// MARK: - Storage

import TinyCore

public protocol Storage {
    
    associatedtype Key: Hashable
    
    associatedtype Value
    
    var changes: Observable< AnyCollection< StorageChange<Key, Value> > > { get }
    
    func load(
        completion: (
            ( Result< AnyStorage<Key, Value> > ) -> Void
        )?
    )
    
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
    
    public func load() { load(completion: nil) }
    
    public var isEmpty: Bool { return (count == 0) }
    
}

// MARK: - AnyStorage

public struct AnyStorage<Key, Value>: Storage where Key: Hashable {
    
    private let _changes: () -> Observable< AnyCollection< StorageChange<Key, Value> > >
    
    private let _load: (
        _ completion: (
            ( Result< AnyStorage<Key, Value> > ) -> Void
        )?
    )
    -> Void
    
    private let _value: (Key) -> Value?
    
    private let _setValue: (Value?, Key) -> Void
    
    private let _count: () -> Int
    
    public init<S>(_ storage: S)
    where
        S: Storage,
        S.Key == Key,
        S.Value == Value {
            
        self._changes = { storage.changes }
        
        self._load = storage.load
        
        self._value = storage.value
        
        self._setValue = storage.setValue
        
        self._count = { storage.count }
            
    }
    
    public var changes: Observable< AnyCollection< StorageChange<Key, Value> > > { return _changes() }
    
    public func load(
        completion: (
            ( Result< AnyStorage<Key, Value> > ) -> Void
        )?
    ) { _load(completion) }
    
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
