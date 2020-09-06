//
//  MetadataExtractor.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation
import ID3TagEditor
import Cocoa

public struct MetadataExtractor {
    
    let url: URL
    let directory: String
    var audioFiles: [AudioFileExtractor] = []
//    var imageData: Data?
    var imageRefs: [String] = []
    private var frames: [FrameName:ID3FrameEx] = [:]
    
    public init(dir: String) {
        directory = dir
        url = URL(fileURLWithPath: directory, isDirectory: true)
    }
    
    public init(url: URL) {
        self.url = url
        directory = url.path
    }
    
    mutating func normalize() {
        for frameName in FrameName.allCases {
            var matches = true

            var firstFrame: ID3FrameEx?
            var firstFrameValue: String?
            
            for file in audioFiles {
                if firstFrame == nil {
                    firstFrame = file.getFrame(frameName)
                    firstFrameValue = file.getFrameValue(frameName)
                } else {
                    let currentFrameValue = file.getFrameValue(frameName)
                    if currentFrameValue != firstFrameValue {
                        matches = false
                    }
                }
            }
            
            if matches {
                // Add frame to Album
                frames[frameName] = firstFrame
                // Remove frame from AudioFiles
                var newAudioFiles: [AudioFileExtractor] = []
                for var file in audioFiles {
                    file.removeFrame(frameName)
                    newAudioFiles.append(file)
                }
                audioFiles = newAudioFiles
            }
                        
        }
    }
    
    mutating public func getAudioFiles() {
        let fm = FileManager.default
        do {

            let files = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
            
            for fileurl in files {
                let validExtensions = ["mp3","flac"]
                let validPictureFormats = ["gmp","gif","ico","jpg","jpeg","png","tiff"]
                if validExtensions.contains(fileurl.pathExtension) {
                    var audioFile = AudioFileExtractor(url: fileurl)
                    audioFile.getFrames()
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
                    var audioFile = AudioFile(track: track, title: title, filename: filename)
                    audioFile.artist = file.getFrameValue(.Artist)
                    audioFile.composer = file.getFrameValue(.Composer)
                    audioFile.genre = file.getFrameValue(.Genre)
                    audioFile.recordingYear = Int(file.getFrameValue(.RecordingYear) ?? "")
                    album.audioFiles.append(audioFile)
                }
            }
            return album
        }
        return nil
    }

    public func getJSON(from album: Album, pretty: Bool = false) -> Data? {
        let encoder = JSONEncoder()
        if pretty {
            encoder.outputFormatting = .prettyPrinted
        }
        let jsonData = try? encoder.encode(album)
        return jsonData
    }
        
    public func printAudioFiles() {
        print("\nDirectory: \(directory)")

        printFrames()
        for file in audioFiles.sorted(by: { Int($0.getFrameValue(.TrackPosition) ?? "0") ?? 0 <
                                        Int($1.getFrameValue(.TrackPosition) ?? "0") ?? 0 }) {
            file.printAudioFile()
        }

    }

    func printFrames() {
        for (_, frame) in frames {
            frame.printFrame()

        }
    }
    
}
