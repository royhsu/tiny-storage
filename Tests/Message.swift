//
//  Message.swift
//  TinyStorageTests
//
//  Created by Roy Hsu on 2018/9/22.
//

// MARK: - Message

import TinyStorage

internal struct Message: Unique, Equatable {
    
    internal var identifier: String
    
    internal init(identifier: String) { self.identifier = identifier }
    
}
