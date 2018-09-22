//
//  Message.swift
//  TinyStorage Tests
//
//  Created by Roy Hsu on 2018/9/22.
//

// MARK: - Message

import TinyCore
import TinyStorage

internal struct Message: Unique {
    
    internal var identifier: String
    
    internal init(identifier: String) { self.identifier = identifier }
    
}
