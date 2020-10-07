//
//  GIMediaType.swift
//  MediaLibraryWrapper
//
//  Created by daleijn on 07.10.2020.
//

import Foundation
import MobileCoreServices

struct GIMediaType: OptionSet {
    let rawValue: Int
    
    static let images = GIMediaType(rawValue: 1 << 0)
    static let videos = GIMediaType(rawValue: 1 << 1)
    
    
    var utTypes: [String] {
        var mediaTypes = [String]()
        
        if self.contains(.images) {
            mediaTypes.append(kUTTypeImage as String)
        }
        
        if self.contains(.videos) {
            mediaTypes.append(kUTTypeMovie as String)
        }
        
        return mediaTypes
    }
}
