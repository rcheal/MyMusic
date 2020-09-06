//
//  FrameName+allCases.swift
//  LoadMusicDB
//
//  Created by Robert Cheal on 7/30/20.
//

import Foundation
import ID3TagEditor

extension FrameName: CaseIterable {
    public static var allCases: [FrameName] {
        [   FrameName.Album,
            FrameName.Title,
            FrameName.Subtitle,
            FrameName.Artist,
            FrameName.Composer,
            FrameName.Conductor,
            FrameName.Lyricist,
            FrameName.Genre,
            FrameName.Publisher,
            FrameName.Copyright,
            FrameName.EncodedBy,
            FrameName.EncoderSettings,
            FrameName.RecordingYear,
        ]
    }
}
