//
//  MemoryCache.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/9/21.
//

// MARK: - MemoryCache

import TinyCore

public final class MemoryCache<Key, Value>: Storage, ExpressibleByDictionaryLiteral where Key: Hashable {
    
    private enum State {
        
        case initial, loaded
        
    }
    
    private final var state: State = .initial

    public final var isLoaded: Bool { return state == .loaded }

    private typealias Base = Dictionary<Key, Value>
    
    private final var _base: Base
    
    public final let changes: Observable< AnyCollection< StorageChange<Key, Value> > > = Observable()
    
    public init() { self._base = [:] }
    
    public init(
        dictionaryLiteral elements: (Key, Value)...
    ) { self._base = Base(uniqueKeysWithValues: elements) }
    
    public final func load(
        completion: (
            ( Result< AnyStorage<Key, Value> > ) -> Void
        )?
    ) {
        
        state = .loaded
        
        DispatchQueue.global(qos: .background).async {
            
            completion?(
                .success(
                    AnyStorage(self)
                )
            )
            
        }
        
    }
    
    public final func value(forKey key: Key) -> Value? { return _base[key] }
    
    public final func setValue(
        _ value: Value?,
        forKey key: Key
    ) {
        
        _base[key] = value
        
        changes.value = AnyCollection(
            [
                StorageChange(
                    key: key,
                    value: value
                )
            ]
        )
        
    }
    
    public final var count: Int { return _base.count }

    public final var lazy: LazyCollection< [Key : Value] > { return _base.lazy }
    
}
