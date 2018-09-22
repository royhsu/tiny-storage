//
//  Message.swift
//  TinyStorage Tests
//
//  Created by Roy Hsu on 2018/9/22.
//

// MARK: - Message

import TinyStorage

internal struct Message: Unique {
    
    internal var identifier: AnyHashable
    
    internal init(identifier: AnyHashable) { self.identifier = identifier }
    
}
