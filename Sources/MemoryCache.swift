//
//  MemoryCache.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/9/21.
//

// MARK: - MemoryCache

import TinyCore

//public struct StorageContainer<Key, Value> where Key: Hashable {
//
//    public struct Change: Hashable {
//
//        public let key: Key
//
//        public let value: Value?
//
//        public init(
//            key: Key,
//            value: Value?
//        ) {
//
//            self.key = key
//
//            self.value = value
//
//        }
//
//        public static func == (
//            lhs: StorageContainer.Change,
//            rhs: StorageContainer.Change
//        )
//        -> Bool { return lhs.key == rhs.key }
//
//        public func hash(into hasher: inout Hasher) { hasher.combine(key.hashValue) }
//
//    }
//
//    public typealias Changes = Set<Change>
//
//    public var storage: AnyStorage<Key, Value> {
//
//        didSet(oldStorage) {
//
////            let oldSet = Set(
////                oldStorage.lazy.elements.map(Change.init)
////            )
////
////            let newSet = Set(
////                storage.lazy.elements.map(Change.init)
////            )
////
////            let diff = newSet.subtracting(newSet)
////
////            print("diff", diff)
//
////            let s = AnySequence(oldStorage.lazy.elements)
////
////            Set<<#Element: Hashable#>>(s)
//
////           oldStorage.lazy.
//
////            changes.value = [
////                Change(
////                    key: key,
////                    value: value
////                )
////            ]
//
//        }
//
//    }
//
//    public let changes: Observable<Changes>
//
//    public init<S>(storage: S)
//    where
//        S: Storage,
//        S.Key == Key,
//        S.Value == Value {
//
//        self.storage = AnyStorage(storage)
//
//        self.changes = Observable<Changes>()
//
//    }
//
//}

public final class MemoryCache<Key, Value>: Storage, ExpressibleByDictionaryLiteral where Key: Hashable {
    
    private enum State {
        
        case initial, loaded
        
    }
    
    private final var state: State = .initial

    public final var isLoaded: Bool { return state == .loaded }

    private typealias Base = Dictionary<Key, Value>
    
    private final var _base: Base
    
    public let changes: Observable< AnyCollection< StorageChange<Key, Value> > > = Observable()
    
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
    
}
