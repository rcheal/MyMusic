//
//  PlaylistItem+computedFields.swift
//  
//
//  Created by Robert Cheal on 2/21/23.
//

import Foundation

extension PlaylistItem {

    public var composerLastName: String? { lastName(composer) }

    public var artistLastName: String? { lastName(artist) }

}
