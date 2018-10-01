//
//  IndexedStorage.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/10/1.
//

// MARK: - IndexedStorage

public final class IndexedStorage<Value>: Storage, ExpressibleByArrayLiteral {
    
    private enum State {
        
        case initial, loading, loaded
        
    }
    
    private final var state: State = .initial

    public final var isLoaded: Bool { return (state == .loaded) }
    
    /// The base.
    private final var values: [Value] = []
    
    private final let changes: Observable< AnyCollection< StorageChange<Int, Value> > > = Observable()
    
    public final var count: Int { return values.count }
    
    public init(arrayLiteral values: Value...) { self.values = values }
    
    public final func load(
        completion: Optional< (Result< AnyStorage<Int, Value> >) -> Void >
    ) {
        
        if state == .loading { return }
        
        state = .loading
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            
            guard
                let self = self
            else { return }
            
            self.state = .loaded
            
            let changes = self.values.enumerated().map(StorageChange.init)
            
            self.changes.value = AnyCollection(changes)
            
            completion?(
                .success(
                    AnyStorage(self)
                )
            )
            
        }
        
    }
    
    public final func value(forKey index: Int) -> Value? { return values[index] }
    
    public final func setValue(
        _ value: Value?,
        forKey index: Int
    ) {
        
        guard
            let value = value
        else { fatalError("Setting the nil value is not allowed.") }
        
        values[index] = value
        
    }
    
    public func removeAll() {
        fatalError()
    }
    
    public var elements: AnyCollection<(key: Int, value: Value)> { fatalError() }
    
    public func observe(
        _ observer: @escaping (
            ObservedChange<
                AnyCollection< StorageChange<Int, Value> >
            >
        ) -> Void
    )
    -> Observation { return changes.observe(observer) }
    
}
