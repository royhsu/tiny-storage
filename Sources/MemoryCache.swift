//
//  MemoryCache.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/9/21.
//

// MARK: - MemoryCache

#warning("TODO: should prevent mutating / accessing before loaded.")
#warning("TODO: It seems like not every storage is going to support merging operation. It maybe a good idea to create another MergableStorage protocol for this.")
public final class MemoryCache<Key, Value>: Storage, ExpressibleByDictionaryLiteral where Key: Hashable {

    private enum State {

        case initial, loaded

    }

    private final var state: State = .initial

    public final var isLoaded: Bool { return state == .loaded }

    private typealias Base = Dictionary<Key, Value>

    private final var _base: Base

    private final var changes: Observable< AnyCollection< StorageChange<Key, Value> > > = Observable()

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

    public final func merge(
        _ other: AnySequence< (key: Key, value: Value?) >
    ) {

        var mergingElements: [ (Key, Value) ] = []

        var removingKeys: [Key] = []

        var updatingElements: [ (key: Key, value: Value) ] = []

        for element in other {

            let key = element.key

            if let newValue = element.value {

                mergingElements.append(
                    (key, newValue)
                )

                updatingElements.append(
                    (key, newValue)
                )

            }
            else {

                if let existingValue = self[key] {

                    updatingElements.append(
                        (key, existingValue)
                    )

                }
                else { removingKeys.append(key) }

            }

        }

        removingKeys.forEach { self._base.removeValue(forKey: $0) }

        _base.merge(
            mergingElements,
            uniquingKeysWith: { _, new in new }
        )

        let updatingChanges = updatingElements.map(StorageChange.init)

        changes.value = AnyCollection(updatingChanges)

    }

    public final func removeAll() {

        let deletingChanges =
            _base.map(StorageChange.init)

        _base.removeAll()

        changes.value = AnyCollection(deletingChanges)

    }

    public final var count: Int { return _base.count }

    public final var elements: AnyCollection< (key: Key, value: Value) > {

        let elements = _base.lazy.elements.map { $0 }

        return AnyCollection(elements)

    }

    public final func observe(
        _ observer: @escaping (_ change: ObservedChange< AnyCollection< StorageChange<Key, Value> > >) -> Void
    )
    -> Observation { return changes.observe(observer) }

}
