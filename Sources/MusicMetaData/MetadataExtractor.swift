//
//  MetadataExtractor.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation
import ID3TagEditor
import Cocoa

@available(OSX 11.0, *)
public struct MetadataExtractor {
    
    let url: URL
    let directory: String
    var audioFiles: [ExtractorProtocol] = []
    var flacAudioFiles: [ExtractorProtocol] = []
//    var imageData: Data?
    var imageRefs: [String] = []
    private var items: [MetadataType:MetadataItem] = [:]
    
    public init(dir: String) {
        directory = dir
        url = URL(fileURLWithPath: directory, isDirectory: true)
    }
    
    public init(url: URL) {
        self.url = url
        directory = url.path
    }
    
    mutating func normalize() {
        // flac files
        for type in MetadataType.allCases {
            var matches = true
            
            var firstBlock: MetadataItem?
            
            for file in flacAudioFiles {
                if firstBlock == nil {
                    firstBlock = file.getDataItem(type)
                } else {
                    let currentBlock = file.getDataItem(type)
                    // TODO: comparing flac data items
                    if currentBlock != firstBlock {
                        matches = false
                    }
                }
            }
            
            if matches {
                // Add block to Album
                items[type] = firstBlock
                // Remove block from flacAudioFiles
                var newFlacAudioFiles: [ExtractorProtocol] = []
                for var file in flacAudioFiles {
                    // TODO: remove flac data item
                    file.removeItem(type)
                    newFlacAudioFiles.append(file)
                }
                flacAudioFiles = newFlacAudioFiles
            }
        }
    }
    
//    // TODO: deprecated
//    #if false
//    mutating func normalize() {
//        for frameName in FrameName.allCases {
//            var matches = true
//
//            var firstFrame: ID3FrameEx?
//            var firstFrameValue: String?
//            
//            for file in audioFiles {
//                if firstFrame == nil {
//                    firstFrame = file.getFrame(frameName)
//                    firstFrameValue = file.getFrameValue(frameName)
//                } else {
//                    let currentFrameValue = file.getFrameValue(frameName)
//                    if currentFrameValue != firstFrameValue {
//                        matches = false
//                    }
//                }
//            }
//            
//            if matches {
//                // Add frame to Album
//                frames[frameName] = firstFrame
//                // Remove frame from AudioFiles
//                var newAudioFiles: [ID3Extractor] = []
//                for var file in audioFiles {
//                    file.removeFrame(frameName)
//                    newAudioFiles.append(file)
//                }
//                audioFiles = newAudioFiles
//            }
//            
//        }
//    }
//    #endif
    
    mutating public func getAudioFiles() {
        let fm = FileManager.default
        do {

            let files = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
            
            for fileurl in files {
                let validExtensions = ["mp3","mp4"]
                let validPictureFormats = ["gmp","gif","ico","jpg","jpeg","png","tiff"]
                if fileurl.pathExtension == "flac" {
                    var audioFile = FlacExtractor(url: fileurl)
                    _ = audioFile.extractTags()
                    flacAudioFiles.append(audioFile)
                } else if validExtensions.contains(fileurl.pathExtension) {
                    var audioFile: ExtractorProtocol = ID3Extractor(url: fileurl)
                    _ = audioFile.extractTags()
                    audioFiles.append(audioFile)
                } else if validPictureFormats.contains(fileurl.pathExtension) {
                    let imagePath = fileurl.path
                    if NSImage(byReferencingFile: imagePath) != nil {
                        imageRefs.append(imagePath)
                    }
//                    if imageRef == nil {
//                        let ext = fileurl.pathExtension
//                    if imageData == nil {
//                        let ext = fileurl.pathExtension
//                        if let image = NSImage(byReferencingFile: imagePath) {
//                            if ext == "jpg" || ext == "jpeg" {
//                                imageData = image.jpg
//                            } else {
//                                imageData = image.png
//                            }
//                        }
//                    } else {
//                        print("Multiple image files: \(imagePath)")
//                    }

                } else {
                    print("Skipping file: \(fileurl.path)")
                }
            }
            
            normalize()
            
        } catch {
            print("\(error)")
        }
    }
    
    public func getAlbum() -> Album? {
        if let albumTitle = items[.album]?.contentsString {
            var album = Album(album: albumTitle)
            album.artist = items[.artist]?.contentsString
            album.composer = items[.composer]?.contentsString
            album.conductor = items[.composer]?.contentsString
            album.lyricist = items[.lyricist]?.contentsString
            album.genre = items[.genre]?.contentsString
            album.publisher = items[.publisher]?.contentsString
            album.copyright = items[.copyright]?.contentsString
            album.encodedBy = items[.encodedBy]?.contentsString
            album.encoderSettings = items[.encoderSettings]?.contentsString
            album.recordingYear = items[.recordingYear]?.contentsInt
            album.coverArtRefs = imageRefs

            for file in audioFiles.sorted(by: { $0.getDataItem(.track)?.contentsInt ?? 0 <
                                            $1.getDataItem(.track)?.contentsInt ?? 0 }) {
                let filename = file.relativeFilename
                if let track = file.getDataItem(.track)?.contentsInt,
                   let title = file.getDataItem(.title)?.contentsString {
                    var audioFile = AudioFile(track: track, title: title, filename: filename)
                    audioFile.artist = file.getDataItem(.artist)?.contentsString
                    audioFile.composer = file.getDataItem(.composer)?.contentsString
                    audioFile.genre = file.getDataItem(.genre)?.contentsString
                    audioFile.recordingYear = file.getDataItem(.recordingYear)?.contentsInt
                    album.audioFiles.append(audioFile)
                }
            }
            return album
        }
        return nil

    }
    
    #if false
    public func getAlbum() -> Album? {
        if let albumTitle = frames[.Album]?.getFrameValue() {
            var album = Album(album: albumTitle)
            album.artist = frames[.Artist]?.getFrameValue()
            album.composer = frames[.Composer]?.getFrameValue()
            album.conductor = frames[.Conductor]?.getFrameValue()
            album.lyricist = frames[.Lyricist]?.getFrameValue()
            album.genre = frames[.Genre]?.getFrameValue()
            album.publisher = frames[.Publisher]?.getFrameValue()
            album.copyright = frames[.Copyright]?.getFrameValue()
            album.encodedBy = frames[.EncodedBy]?.getFrameValue()
            album.encoderSettings = frames[.EncoderSettings]?.getFrameValue()
            album.recordingYear = Int(frames[.RecordingYear]?.getFrameValue() ?? "")
            album.coverArtRefs = imageRefs

            for file in audioFiles.sorted(by: { $0.getFramePartValue(.TrackPosition) ?? 0 <
                                            $1.getFramePartValue(.TrackPosition) ?? 0 }) {
                let filename = file.getRelativeFilename()
                if let track = file.getFramePartValue(.TrackPosition) ,
                   let title = file.getFrameValue(.Title) {
                    var audioFile = AudioFile(track: track, title: title, lFilename: lFilename)
                    audioFile.artist = file.getFrameValue(.Artist)
                    audioFile.composer = file.getFrameValue(.Composer)
                    audioFile.genre = file.getFrameValue(.Genre)
                    audioFile.recordingYear = Int(file.getFrameValue(.RecordingYear) ?? "")
                    album.audioFiles.append(audioFile)
                }
            }
            return album
        } else if let albumBlock = items[.album]?.contents {
            switch albumBlock {
            case .string(let s):
                let albumTitle = s
                    = Album(album: )
            }
        }
        return nil
    }
    #endif

    public func getJSON(from album: Album, pretty: Bool = false) -> Data? {
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = .prettyPrinted
        }
        let jsonData = try? encoder.encode(album)
        return jsonData
    }
        
    public func printJSON(from json: Data) {
        let jsonString = String(data: json, encoding: .utf8)!
        print(jsonString)
    }
    
     public func printAudioFiles() {
        print("\nDirectory: \(directory)")

        printItems()
        for file in audioFiles.sorted(by: { $0.getDataItem(.track)?.contentsInt ?? 0 <
                                        $1.getDataItem(.track)?.contentsInt ?? 0 }) {
            file.printAudioFile()
        }

    }

    func printItems() {
        // TODO: Add function body
    }
    
//    func printFrames() {
//        for (_, frame) in frames {
//            frame.printFrame()
//
//        }
//    }
    
}
