//
//  RemoteStorage.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/9/22.
//

import TinyCore

// MARK: - Unique

#warning("TODO: move to TinyCore")
public protocol Unique {
    
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

// MARK: - RemoteStorage

#warning("TODO: missing test.")
public final class RemoteStorage<Item>: Storage where Item: Unique {
    
    private final var _base: [Item] = []
    
    private final let resource: AnyResource<Item>
    
    private enum State {
        
        case initial, loading, loaded
        
    }
    
    private final var state: State = .initial
    
    public final let changes: Observable< AnyCollection< StorageChange<Item.Identifier, Item> > > = Observable()
    
    public init<R>(resource: R)
    where
        R: Resource,
        R.Item == Item { self.resource = AnyResource(resource) }
    
    public final var isLoaded: Bool { return (state == .loaded) }
    
    #warning("TODO: should keep tracking the previous fetched pages.")
    public final func load(
        completion: (
            (Result< AnyStorage<Item.Identifier, Item> >) -> Void
        )?
    ) {
        
        if state == .loading { return }
        
        state = .loading
        
        resource.fetchItems(page: .first) { [weak self] result in
            
            defer { self?.state = .loaded }
            
            guard
                let self = self
            else { return }
            
            switch result {
                
            case let .success(payload):
                
                self._base.append(contentsOf: payload.items)
                
                let changes = payload.items.map { item in
                    
                    return StorageChange(
                        key: item.identifier,
                        value: item
                    )
                    
                }
                
                self.changes.value = AnyCollection(changes)
                
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
        
    }
    
    public final func value(forKey key: Item.Identifier) -> Item? { return _base.first { $0.identifier == key } }
    
    public final func setValue(
        _ value: Item?,
        forKey key: Item.Identifier
    ) {
        
        guard
            let value = value
        else { fatalError("Setting the nil value is not allowed.") }
        
        guard
            let index = _base.index(
                where: { $0.identifier == key }
            )
        else { fatalError("The key is out of bounds.") }
        
        _base[index] = value
        
    }
    
    #warning("TODO: not implemented.")
    public final func merge(
        _ other: AnySequence< (key: Item.Identifier, value: Item? )>
    ) { fatalError("Not implemented.")  }
    
    public final func removeAll() { _base.removeAll() }
    
    public final var count: Int { return _base.count }
    
    public var elements: AnyCollection< (key: Item.Identifier, value: Item) > {
        
        let elements = _base.map { ($0.identifier, $0) }
        
        return AnyCollection(elements)
        
    }
    
}
