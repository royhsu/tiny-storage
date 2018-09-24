//
//  MessageResource.swift
//  TinyStorageTests
//
//  Created by Roy Hsu on 2018/9/13.
//  Copyright © 2018 TinyWorld. All rights reserved.
//

// MARK: - MessageResource

import TinyCore
import TinyStorage

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
