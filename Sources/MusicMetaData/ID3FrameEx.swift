//
//  ID3FrameEx.swift
//  LoadMusicDB
//
//  Created by Robert Cheal on 7/30/20.
//

import Foundation
import ID3TagEditor

struct ID3FrameEx {
    private var frameName: FrameName
    private var frame: ID3Frame
   
    init(frameName: FrameName, frame: ID3Frame) {
        self.frameName = frameName
        self.frame = frame
    }
    
    func getFrameName() -> FrameName {frameName}
    func getID3Frame() -> ID3Frame {frame}
    
    func getFramePicture() -> Data? {
        if let pictureFrame = frame as? ID3FrameAttachedPicture {
            return pictureFrame.picture
        }
        return nil
    }
    
    func getFramePictureFormat() -> ID3PictureFormat? {
        if let pictureFrame = frame as? ID3FrameAttachedPicture {
            return pictureFrame.format
        }
        return nil
    }
    
    func getFramePictureType() -> ID3PictureType? {
        if let pictureFrame = frame as? ID3FrameAttachedPicture {
            return pictureFrame.type
        }
        return nil
    }
    
    func getFramePartValue() -> Int {
        
        if frameName == .TrackPosition || frameName == .DiscPosition {
            if let partOfTotalFrame = frame as? ID3FramePartOfTotal {
                let part = partOfTotalFrame.part
                return part
            }
        }
        return 0
    }
    
    func getFrameTotalValue() -> Int? {
        if frameName == .TrackPosition || frameName == .DiscPosition {
            if let partOfTotalFrame = frame as? ID3FramePartOfTotal {
                let total = partOfTotalFrame.total
                return total
            }
        }
        return nil
    }
    
    
    func getFrameValue() -> String? {
        var valueStr: String
        let noValue = "(no value)"
        
        switch frameName {
        case .Genre:
            if let genreFrame = frame as? ID3FrameGenre {
                if let genreIdentifer = genreFrame.identifier {
                    valueStr = "\(String(describing: genreIdentifer))"
                } else if let genreIdentifier = genreFrame.description {
                    valueStr = genreIdentifier
                } else {
                    valueStr = noValue
                }
            } else {
                valueStr = noValue
            }
            
        case .TrackPosition, .DiscPosition:
            if let partOfTotalFrame = frame as? ID3FramePartOfTotal {
                let part = partOfTotalFrame.part
                valueStr = ("\(part)")

                if let total = partOfTotalFrame.total {
                    valueStr += " of \(total)"
                }
                return valueStr

            }
            return  noValue

        case .RecordingYear:
            if let yearFrame = frame as? ID3FrameRecordingYear {
                if let year = yearFrame.year {
                    valueStr = "\(year)"
                    return valueStr
                }
            } else if let yearFrame = frame as? ID3FrameWithIntegerContent {
                if let year = yearFrame.value {
                    valueStr = "\(year)"
                    return valueStr
                }
            }
            return noValue
            
        default:
            valueStr = (frame as? ID3FrameWithStringContent)?.content ?? ""
            
        }

        return valueStr
    }
    
    func getFrameDisplayName() -> String {
        var name: String
        switch frameName {

            case .Title:
                name = "Title"
            case .Album:
                name = "Album"
            case .AlbumArtist:
                name = "AlbumArtist"
            case .Artist:
                name = "Artist"
            case .Composer:
                name = "Composer"
            case .Conductor:
                name = "Conductor"
            case .ContentGrouping:
                name = "ContentGrouping"
            case .Copyright:
                name = "Copyright"
            case .EncodedBy:
                name = "EncodedBy"
            case .EncoderSettings:
                name = "EncoderSettings"
            case .FileOwner:
                name = "FileOwner"
            case .Lyricist:
                name = "Lyricist"
            case .MixArtist:
                name = "MixArtist"
            case .Publisher:
                name = "Publisher"
            case .Subtitle:
                name = "Subtitle"
            case .Genre:
                name = "Genre"
            case .DiscPosition:
                name = "DiscPosition"
            case .TrackPosition:
                name = "TrackPosition"
            case .RecordingDayMonth:
                name = "RecordingDayMonth"
            case .RecordingYear:
                name = "RecordingYear"
            case .RecordingHourMinute:
                name = "RecordingHourMinute"
            case .RecordingDateTime:
                name = "RecordingDateTime"
            case .AttachedPicture(_):
                name = "AttachedPicture"
            case .iTunesGrouping:
                name = "iTunesGrouping"
            case .iTunesMovementName:
                name = "iTunesMovementName"
            case .iTunesMovementIndex:
                name = "iTunesMovementIndex"
            case .iTunesMovementCount:
                name = "iTunesMovementCount"
            case .iTunesPodcastCategory:
                name = "iTunesPodcastCategory"
            case .iTunesPodcastDescription:
                name = "iTunesPodcastDescription"
            case .iTunesPodcastID:
                name = "iTunesPodcastID"
            case .iTunesPodcastKeywords:
                name = "iTunesPodcastKeywords"
        }
        return name
    }
    
    func printFrame() {
        let longKey = getFrameDisplayName()
        let value = getFrameValue() ?? "<error>"
        print("    \(longKey)(\(frame.id3Identifier ?? "")): \(value)")
    }
    
}
