//
//  MetadataExtractor.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation
import ID3TagEditor
import Cocoa
import OSLog

@available(OSX 11.0, *)
public struct MetadataExtractor {
    
    let url: URL
    let baseurl: URL
    let directory: String
    let reldir: String
    var audioFiles: [ExtractorProtocol] = []
    var images: [MetadataImageType:(String,Data)] = [:]
    var imageRefs: [String] = []
    private var items: [MetadataType:MetadataItem] = [:]
    private var compositionFileCounts: [String:Int] = [:]
    
    private var logger = Logger(subsystem: "com.cheal.bob.MusicMetaData", category: "MetadataExtractor")

    init(dir: String, relativeTo baseurl: URL) {
        self.baseurl = baseurl
        reldir = dir
        url = URL(fileURLWithPath: dir, relativeTo: baseurl)
        directory = url.path
    }

    public init(dir: String) {
        directory = dir
        let tmpurl = URL(fileURLWithPath: directory, isDirectory: true)
        let components = tmpurl.pathComponents
        let index = components.endIndex
        reldir = "\(components[index-2])/\(components[index-1])"
        baseurl = tmpurl.deletingLastPathComponent().deletingLastPathComponent()
        url = URL(fileURLWithPath: reldir, isDirectory: true, relativeTo: baseurl)
    }
    
    public init(url: URL) {
        let components = url.pathComponents
        let index = components.endIndex
        reldir = "\(components[index-2])/\(components[index-1])"
        baseurl = url.deletingLastPathComponent().deletingLastPathComponent()
        self.url = URL(fileURLWithPath: reldir, isDirectory: true, relativeTo: baseurl)
        directory = self.url.path
    }
    
    mutating public func getAudioFiles() {
        let fm = FileManager.default
        do {

            let files = try fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
            
            for fileurl in files {
                let relfilename = "\(reldir)/\(fileurl.lastPathComponent)"
                let validExtensions = ["mp3","mp4"]
                let validPictureFormats = ["gmp","gif","ico","jpg","jpeg","png","tiff"]
                var audioFile: ExtractorProtocol
                if fileurl.pathExtension == "flac" {
                    audioFile = FlacExtractor(file: relfilename, relativeTo: baseurl)
                    _ = audioFile.extractTags()
                    audioFiles.append(audioFile)
                } else if validExtensions.contains(fileurl.pathExtension) {
                    audioFile = ID3Extractor(file: relfilename, relativeTo: baseurl)
                    _ = audioFile.extractTags()
                    audioFiles.append(audioFile)
                } else if validPictureFormats.contains(fileurl.pathExtension) {
                    let imagePath = fileurl.path
                    let ext = fileurl.pathExtension
                    if let image = NSImage(byReferencingFile: imagePath) {
                        let imageRef = fileurl.relativePath
                        var imageData: Data?
                        if ext == "jpg" || ext == "jpeg" {
                            imageData = image.jpg
                        } else if ext == "png" {
                            imageData = image.png
                        }
                        if let imageData = imageData, images[.frontCover] == nil {
                            images[.frontCover] = (imageRef, imageData)
                            imageRefs.append(imagePath)
                        }
                    }

                } else {
                    logger.debug("Skipping file: \(fileurl.path)")
                }
            }
            
            normalize()
            
        } catch {
            logger.debug("\(error.localizedDescription)")
        }
    }
    
    mutating func normalize() {
        // flac files
        
        // find compositions base on Album title or Composition title
        var firstAlbumBlock: MetadataItem?
        var firstCompositionBlock: MetadataItem?
        var compositionCount = 0
        var startTrack = 0
        var startDisk = 0
        for file in audioFiles.sorted(by: {
            let diska = $0.getDataItem(.disk)?.contentsInt ?? 0
            let diskb = $0.getDataItem(.disk)?.contentsInt ?? 0
            let tracka = $0.getDataItem(.track)?.contentsInt ?? 1
            let trackb = $1.getDataItem(.track)?.contentsInt ?? 1
            let albuma = $0.getDataItem(.album)?.contentsString ?? ""
            let albumb = $1.getDataItem(.album)?.contentsString ?? ""
            if diska == diskb {
                if albuma == albumb {
                    return tracka < trackb
                } else {
                    return albuma < albumb
                }
            } else {
                if albuma == albumb {
                    return tracka < trackb
                } else {
                    return albuma < albumb
                }
            }
        }) {
            let currentAlbumBlock = file.getDataItem(.album) ?? MetadataItem(type: .album, contentsString: "")
            let currentCompositionBlock = file.getDataItem(.composition) ?? MetadataItem(type: .composition, contentsString: "")
            let currentTrack = file.getDataItem(.track)?.contentsInt ?? 1
            let currentDisk = file.getDataItem(.disk)?.contentsInt ?? 0
            
            if firstAlbumBlock == nil  {
                firstAlbumBlock = currentAlbumBlock
                firstCompositionBlock = currentCompositionBlock
                compositionCount = 1
                startDisk = currentDisk
                startTrack = currentTrack
            } else {
                if (currentAlbumBlock != firstAlbumBlock) ||
                    (currentCompositionBlock != firstCompositionBlock) {
                    if compositionCount >= 2 {
                        let key = (firstAlbumBlock?.contentsString ?? "") + ":\(startTrack)"
                        compositionFileCounts[key] = compositionCount
                        logger.debug("normalize() Key: \(key)")
                        logger.debug("normalize() Composition count: \(compositionCount)")

                    }
                    firstAlbumBlock = currentAlbumBlock
                    firstCompositionBlock = currentCompositionBlock
                    compositionCount = 1
                } else {
                    compositionCount += 1
                }
            }
            
        }
        
        
        for type in MetadataType.allCases {
            var matches = true
            
            var firstBlock: MetadataItem?
            
            for file in audioFiles {
                if firstBlock == nil {
                    firstBlock = file.getDataItem(type)
                } else {
                    let currentBlock = file.getDataItem(type)
                    if currentBlock != firstBlock {
                        matches = false
                    }
                }
            }
            
            if matches {
                // Add block to Album
                items[type] = firstBlock
                // Remove block from flacAudioFiles
                var newAudioFiles: [ExtractorProtocol] = []
                for var file in audioFiles {
                    file.removeItem(type)
                    newAudioFiles.append(file)
                }
                audioFiles = newAudioFiles
            } else if type == .album {
                if items[.album] == nil {
                    items[type] = firstBlock
                    logger.warning("Files are not from the same album")
                    for file in audioFiles {
                        let fname = file.relativeFilename
                        let albumTitle = file.getDataItem(.album)?.contentsString ?? ""
                        logger.info("\(fname): \(albumTitle)")
                    }
                }
            }
        }
    }
    
    public func getAlbum() -> Album? {
        if let albumTitle = items[.album]?.contentsString {
            var album = Album(album: albumTitle)
            album.artist = items[.artist]?.contentsString
            album.composer = items[.composer]?.contentsString
            album.conductor = items[.conductor]?.contentsString
            album.lyricist = items[.lyricist]?.contentsString
            album.genre = items[.genre]?.contentsString
            album.publisher = items[.publisher]?.contentsString
            album.copyright = items[.copyright]?.contentsString
            album.encodedBy = items[.encodedBy]?.contentsString
            album.encoderSettings = items[.encoderSettings]?.contentsString
            album.recordingYear = items[.recordingYear]?.contentsInt
            album.coverArtRefs = imageRefs

            var compositionCount = 0
            var composition: Composition?
            for file in audioFiles.sorted(by: {
                    let tracka = $0.getDataItem(.track)?.contentsInt ?? 0
                    let trackb = $1.getDataItem(.track)?.contentsInt ?? 0
                    let albuma = $0.getDataItem(.album)?.contentsString ?? ""
                    let albumb = $1.getDataItem(.album)?.contentsString ?? ""
                    if albuma == albumb {
                        return tracka < trackb
                    } else {
                        return albuma < albumb
                    }

                }) {
                let filename = file.relativeFilename
                if let track = file.getDataItem(.track)?.contentsInt,
                   let title = file.getDataItem(.title)?.contentsString {
                    var audioFile = AudioFile(track: track, title: title, filename: filename)
                    audioFile.artist = file.getDataItem(.artist)?.contentsString
                    audioFile.composer = file.getDataItem(.composer)?.contentsString
                    audioFile.genre = file.getDataItem(.genre)?.contentsString
                    audioFile.recordingYear = file.getDataItem(.recordingYear)?.contentsInt
                    audioFile.duration = file.getDataItem(.duration)?.contentsInt
                    logger.debug("Duration for \(title): \(audioFile.duration ?? 0)")
                    let key = file.getDataItem(.album)?.contentsString ?? "" + ":\(track)"
                    if let compositionFileCount = compositionFileCounts[key] {
                        logger.debug("getAlbum() Key: \(key)")
                        logger.debug("getAlbum() composition file count: \(compositionFileCount)")
                        if composition != nil {
                            album.compositions.append(composition!)
                        }
                        composition = Composition(startTrack: track, title: file.getDataItem(.composition)?.contentsString
                                                    ?? file.getDataItem(.album)?.contentsString ?? "")
                        if composition != nil {
                            composition!.audioFiles.append(audioFile)
                            compositionCount = compositionFileCount-1
                        }
                    } else if compositionCount > 0 {
                        composition?.audioFiles.append(audioFile)
                        compositionCount -= 1
                    } else {
                        if composition != nil {
                            album.compositions.append(composition!)
                            composition = nil
                        }
                        album.audioFiles.append(audioFile)
                    }
                }
            }
            if composition != nil {
                album.compositions.append(composition!)
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
