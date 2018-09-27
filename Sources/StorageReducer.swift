//
//  StorageReducer.swift
//  TinyStorage
//
//  Created by Roy Hsu on 2018/9/26.
//  Copyright © 2018 TinyWorld. All rights reserved.
//

// MARK: - StorageReducer

public final class StorageReducer<T, U> where T: Storage {

    public final let storage: T

    private final let transform: (T) -> U

    public init(
        storage: T,
        transform: @escaping (T) -> U
    ) {

        self.storage = storage

        self.transform = transform

    }

    public final func reduce(
        queue: DispatchQueue = .global(qos: .background),
        completion: @escaping (Result<U>) -> Void
    ) {

        if storage.isLoaded {

            queue.async { [weak self] in

                guard
                    let self = self
                else { return }

                let value = self.transform(self.storage)

                completion(
                    .success(value)
                )

            }

            return

        }

        storage.load { result in

            queue.async { [weak self] in

                guard
                    let self = self
                else { return }

                switch result {

                case .success:

                    let value = self.transform(self.storage)

                    completion(
                        .success(value)
                    )

                case let .failure(error):

                     completion(
                        .failure(error)
                    )

                }

            }

        }

    }

}
