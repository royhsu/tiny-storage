//
//  RemoteStorage.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/9/22.
//

import TinyCore

// MARK: - Unique

#warning("TODO: move to TinyCore")
public protocol Unique: Equatable {
    
    associatedtype Identifier: Hashable
    
    var identifier: Identifier { get }
    
}

public protocol Resource {
    
    associatedtype Item: Unique
    
    func fetchItems(
        page: Page,
        completion: @escaping (
            Result< FetchItemsPayload<Item> >
        )
        -> Void
    )
    
}

// MARK: - AnyResource

public struct AnyResource<Item>: Resource where Item: Unique {
    
    private let _fetchItems: (
        _ page: Page,
        _ completion: @escaping (
            Result< FetchItemsPayload<Item> >
        )
        -> Void
    )
    -> Void
    
    public init<R: Resource>(_ resource: R)
    where R.Item == Item {
        
        self._fetchItems = resource.fetchItems
        
    }
    
    public func fetchItems(
        page: Page,
        completion: @escaping (
            Result< FetchItemsPayload<Item> >
        )
        -> Void
    ) {
        
        _fetchItems(
            page,
            completion
        )
        
    }
    
}


public enum Page {
    
    case first
    
    case next
    
    case last
    
}

public struct FetchItemsPayload<Item> {
    
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

public final class RemoteStorage<Item>: Storage where Item: Unique {
    
    private final var _base = MemoryCache<Item.Identifier, Item>()
    
    private final let resource: AnyResource<Item>
    
    private enum State {
        
        case initial, loading, loaded
        
    }
    
    private final var state: State = .initial
    
    public final var changes: Observable< AnyCollection< StorageChange<Item.Identifier, Item> > > { return _base.changes }
    
    public init<R>(resource: R)
    where
        R: Resource,
        R.Item == Item { self.resource = AnyResource(resource) }
    
    public final var isLoaded: Bool { return (state == .loaded) }
    
    public final func load(
        completion: (
            (Result< AnyStorage<Item.Identifier, Item> >) -> Void
        )?
    ) {
        
        if state == .loading {
            
            _base.load(completion: completion)
            
            return
            
        }
        
        state = .loading
        
        _base.load { [weak self] result in
            
            defer { self?.state = .loaded }
            
            guard
                let self = self
            else { return }
            
            switch result {
                
            case .success:
            
                self.resource.fetchItems(page: .first) { result in
                
                    switch result {
                        
                    case let .success(payload):
                        
        //                let sequence: [ (key: Key, value: Item?) ] = payload
        //                    .items
        //                    .enumerated()
        //                    .map { $0 }
                        
                        #warning("TODO: should keep tracking the previous fetched pages.")
                        
//                        self._base.merge
                        
                        completion?(
                            .success(
                                AnyStorage(self)
                            )
                        )
                        
                    case let .failure(error):
                        
                        completion?(
                            .failure(error)
                        )
                        
                    }
                    
                }
                
            case let .failure(error):
                
                completion?(
                    .failure(error)
                )
                
            }
            
        }
        
    }
    
    public final func value(forKey key: Item.Identifier) -> Item? { return _base[key] }
    
    public final func setValue(
        _ value: Item?,
        forKey key: Item.Identifier
    ) {
        
        _base.setValue(
            value,
            forKey: key
        )
        
    }
    
    public final func merge(
        _ other: AnySequence< (key: Item.Identifier, value: Item? )>
    ) { _base.merge(other) }
    
    public final func removeAll() { _base.removeAll() }
    
    public final var count: Int { return _base.count }
    
    public var lazy: LazyCollection< [Item.Identifier: Item ] > { return _base.lazy }
    
}
