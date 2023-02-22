//
//  Single+computedFields.swift
//  
//
//  Created by Robert Cheal on 2/21/23.
//

import Foundation

extension Single {

    public var composerLastName: String? { lastName(composer) }

    public var artistLastName: String? { lastName(artist) }

    public var conductorLastName: String? { lastName(conductor) }

}

extension SingleSummary {

    public var composerLastName: String? { lastName(composer) }

    public var artistLastName: String? { lastName(artist) }

}
