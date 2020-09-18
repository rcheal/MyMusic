//
//  AudioFileExtractor.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation
import ID3TagEditor

struct ID3Extractor: ExtractorProtocol {
    
    private let id3TagEditor: ID3TagEditor = ID3TagEditor()
    private let url: URL
    private let lFilename: String
    private let lRelativeFilename: String
    private var metadataItems: [MetadataType:MetadataItem] = [:]
    var images: [MetadataImageType:(String,Data)] = [:]
    
    var filename: String {
        lFilename
    }
    
    var relativeFilename: String {
        lRelativeFilename
    }
        
    @available(OSX 10.11, *)
    init(file fname: String, relativeTo durl: URL) {
        url = URL(fileURLWithPath: fname, relativeTo: durl)
        lFilename = url.path
        lRelativeFilename = url.relativePath
    }

    init(file fname: String) {
        lFilename = fname
        url = URL(fileURLWithPath: fname, isDirectory: false)
        lRelativeFilename = url.relativePath
    }
    
    init(url: URL) {
        self.url = url
        lFilename = self.url.path
        lRelativeFilename = url.relativePath
    }
    
    mutating func removeItem(_ type: MetadataType) {
        if let index = metadataItems.index(forKey: type) {
            metadataItems.remove(at: index)
        }
    }
    
    func getDataItem(_ type: MetadataType) -> MetadataItem? {
        metadataItems[type]
    }
          
    mutating func setDataItem(_ item: MetadataItem) {
        removeItem(item.type)
        metadataItems[item.type] = item
    }
    
    func getImage(_ type: MetadataImageType) -> (String, Data)? {
        return images[type]
    }

    mutating func extractTags() -> (Bool, String) {
        do {
            if let id3Tag = try id3TagEditor.read(from: lFilename) {
                for (key,value) in id3Tag.frames {
                    var metadataItem: MetadataItem?
                    let frame = ID3FrameEx(frameName: key, frame: value)
                    switch key {
                    case .Album:
                        if let value = frame.getFrameValue() {
                            metadataItem = MetadataItem(type: .album, contentsString: value)
                        }
                    case .Title:
                        if let value = frame.getFrameValue() {
                            metadataItem = MetadataItem(type: .title, contentsString: value)
                        }
                    case .Subtitle:
                        if let value = frame.getFrameValue() {
                            metadataItem = MetadataItem(type: .subtitle, contentsString: value)
                        }
                    case .Artist:
                        if let value = frame.getFrameValue() {
                            metadataItem = MetadataItem(type: .artist, contentsString: value)
                        }
                    case .Composer:
                        if let value = frame.getFrameValue() {
                            metadataItem = MetadataItem(type: .composer, contentsString: value)
                        }
                    case .Conductor:
                        if let value = frame.getFrameValue() {
                            metadataItem = MetadataItem(type: .conductor, contentsString: value)
                        }
                    case .Lyricist:
                        if let value = frame.getFrameValue() {
                            metadataItem = MetadataItem(type: .lyricist, contentsString: value)
                        }
                    case .Genre:
                        if let value = frame.getFrameValue() {
                            metadataItem = MetadataItem(type: .genre, contentsString: value)
                        }
                    case .Publisher:
                        if let value = frame.getFrameValue() {
                            metadataItem = MetadataItem(type: .publisher, contentsString: value)
                        }
                    case .Copyright:
                        if let value = frame.getFrameValue() {
                            metadataItem = MetadataItem(type: .copyright, contentsString: value)
                        }
                    case .EncodedBy:
                        if let value = frame.getFrameValue() {
                            metadataItem = MetadataItem(type: .encodedBy, contentsString: value)
                        }
                    case .EncoderSettings:
                        if let value = frame.getFrameValue() {
                            metadataItem = MetadataItem(type: .encoderSettings, contentsString: value)
                        }
                    case .RecordingYear:
                        if let value = Int(frame.getFrameValue() ?? "") {
                            metadataItem = MetadataItem(type: .recordingYear, contentsInt: value)
                        }
                    case .DiscPosition:
                        let value = frame.getFramePartValue()
                        metadataItem = MetadataItem(type: .disk, contentsInt: value)
                    case .TrackPosition:
                        let value = frame.getFramePartValue()
                        metadataItem = MetadataItem(type: .track, contentsInt: value)
                    case .AttachedPicture(let t):
                        let value = frame.getFramePicture()
                        let format = (frame.getFramePictureFormat() == .Jpeg) ? "jpg" : "png"
                        switch t {
                        case .FrontCover:
                            if let value = value {
                                images[.frontCover] = ("FrontCover.\(format)",value)
                            }
                        case .BackCover:
                            if let value = value {
                                images[.backCover] = ("BackCover.\(format)",value)
                            }
                        default:
                            break
                        }
                    default:
                        break
                    }
                    if let item = metadataItem {
                        metadataItems[item.type] = item
                    }
                }
            }
        } catch {
            return (false,"Exception getting frames for \(lFilename) - \(error)")
        }
        return (true, "OK")
    }

    func printAudioFile() {

        print("\n  File: \(lFilename)")
//        for frame in frames {
//            frame.value.printFrame()
//        }
    }
    
}
