//
//  Resource.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/9/22.
//

// MARK: - RemoteStorage

#warning("TODO: should consider to define FetchItemsRequest wrapping up the context including page.")
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
    where R.Item == Item { self._fetchItems = resource.fetchItems }
    
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

