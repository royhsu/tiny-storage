import TinyStorage

internal struct Message: Unique {

    internal var identifier: String

    internal init(identifier: String) { self.identifier = identifier }

}

internal struct MessageResource: Resource {

    internal var fetchItemsResult: Result< FetchItemsPayload<Message> >

    internal func fetchItems(
        page: Page,
        completion: @escaping (
            Result< FetchItemsPayload<Message> >
        )
        -> Void
    ) {

        DispatchQueue.global(qos: .background).async {

            completion(self.fetchItemsResult)

        }

    }

}

let remoteStorage = RemoteStorage(
    resource: MessageResource(
        fetchItemsResult: .success(
            FetchItemsPayload(
                items: [
                    Message(identifier: "3"),
                    Message(identifier: "1"),
                    Message(identifier: "4"),
                    Message(identifier: "6"),
                    Message(identifier: "2"),
                    Message(identifier: "5")
                ]
            )
        )
    )
)

remoteStorage.load { result in

    do {

        let storage = try result.resolve()

        let elements = storage.elements.map { $0.key }

        print(elements)

    }
    catch { print("\(error)") }

}

print("End")
