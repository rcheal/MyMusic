//
//  FlacExtractor.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation
import OSLog

struct MetaDataBlock {
    var lastBlock: Bool = false
    var type: Int
    var length: Int
    var data: Data?
    
    var blockSize: Int {
        length+4
    }
    
    init?(_ buffer: [UInt8]) {
        let blockHeader = buffer[0..<4]
        let firstByte = blockHeader[0]
        lastBlock = (firstByte & 0x80) != 0
        type = Int(firstByte & 0x7f)
        let blockLengthData = blockHeader[1..<4]
        length = Data(blockLengthData).bigEndian24()
    }
}

@available(OSX 11.0, *)
struct FlacExtractor : ExtractorProtocol {
    
    private let url: URL
    private let lFilename: String
    private let lRelativeFilename: String
    private var metadataItems: [MetadataType:MetadataItem] = [:]
    private var images: [MetadataImageType:(String,Data)] = [:]
    
    private var logger = Logger(subsystem: "com.cheal.bob.MusicMetaData", category: "FlacExtractor")

    var filename: String {
        lFilename
    }
    
    var relativeFilename: String {
        lRelativeFilename
    }
    
    mutating func removeItem(_ type: MetadataType) {
        if let index = metadataItems.index(forKey: type) {
            metadataItems.remove(at: index)
        }
    }
    
    func getDataItem(_ type: MetadataType) -> MetadataItem? {
        metadataItems[type]
    }
    
    func getImage(_ type: MetadataImageType) -> (String,Data)? {
        return images[type] 
    }
    
    init(file fname: String, relativeTo durl: URL) {
        url = URL(fileURLWithPath: fname, relativeTo: durl)
        lFilename = url.path
        lRelativeFilename = url.relativePath
    }

    init(file fname: String, path: String?) {
        lRelativeFilename = fname
        if let path = path {
            let pathURL = URL(fileURLWithPath: path, isDirectory: true)
            url = pathURL.appendingPathComponent(fname)
            lFilename = url.path
        } else {
            url = URL(fileURLWithPath: fname, isDirectory: false)
            lFilename = fname
        }
    }
    
    init(url: URL) {
        self.url = url
        lFilename = self.url.path
        lRelativeFilename = url.relativePath
    }
    
    func readFile(_ size: Int) -> Data? {
        var buffer: Data?
        if let fh = try? FileHandle(forReadingFrom: url) {
            buffer = try? fh.read(upToCount: size)
        }
            
        return buffer
    }
    
    func findSyncOffset(_ buffer: Data) -> Int? {
        let syncBytes = Data("fLaC".utf8)
        if let syncRange = buffer.range(of: syncBytes) {
            if !syncRange.isEmpty {
                return syncRange.endIndex
            }
        }
        return nil
    }
     
    mutating func getVorbisComments(_ blockData: [UInt8]) {
        // Vorbis Comment
        let vendorLength = Int(Data(blockData[0...3]).littleEndian32())
        var start = 4
        var end = start + vendorLength
        let vendorString = String(bytes: blockData[start..<end], encoding: .utf8) ?? ""
        logger.info("VendorString: \(vendorString, privacy: .public)")
        start = end
        end += 4
        let userCommentCount = Int(Data([UInt8](blockData[start..<end])).littleEndian32())
        for idx in 0..<userCommentCount {
            start = end
            end += 4
            let length = Int(Data([UInt8](blockData[start..<end])).littleEndian32())
            start = end
            end += length
            let tagString = String(bytes: blockData[start..<end], encoding: .utf8) ?? ""
            let components = tagString.components(separatedBy: "=")
            var metadataItem: MetadataItem?
            switch components[0].uppercased() {
            case "TITLE":
                metadataItem = MetadataItem(type: .title, contentsString: components[1])
            case "ARTIST":
                metadataItem = MetadataItem(type: .artist, contentsString: components[1])
            case "ALBUM":
                metadataItem = MetadataItem(type: .album, contentsString: components[1])
            case "DATE":
                metadataItem = MetadataItem(type: .recordingYear, contentsInt: Int(components[1]) ?? 0)
            case "TRACKNUMBER":
                metadataItem = MetadataItem(type: .track, contentsInt: Int(components[1]) ?? 0)
            case "GENRE":
                metadataItem = MetadataItem(type: .genre, contentsString: components[1])
            case "COMPOSER":
                metadataItem = MetadataItem(type: .composer, contentsString: components[1])
            default:
                break
            }
            if let item = metadataItem {
                metadataItems[item.type] = item
            } else {
                logger.info("Vorbis Comment not handled: \(idx, privacy: .public): \(tagString, privacy: .public)")
            }
        }
    }
    
    mutating func getPicture(_ blockData: [UInt8]) {
        let type = Data([UInt8](blockData[0..<4])).bigEndian32()
        let validTypes: [Int] = [3,4]
        if validTypes.contains(type) {
            var start = 4
            var end = 8
            let mimeLength = Data([UInt8](blockData[start..<end])).bigEndian32()
            start = end
            end = start + mimeLength
            let mimeType = String(bytes: [UInt8](blockData[start..<end]), encoding: .utf8)
            start = end
            end = start + 4
            let descLength = Data([UInt8](blockData[start..<end])).bigEndian32()
            start = end
            end = start + descLength
            let /*description*/ _ = String(bytes: [UInt8](blockData[start..<end]), encoding: .utf8)
            start = end
            end = start + 4
            let /*width*/ _ = Data([UInt8](blockData[start..<end])).bigEndian32()
            start = end
            end = start + 4
            let /*height*/ _ = Data([UInt8](blockData[start..<end])).bigEndian32()
            start = end
            end = start + 4
            let /*colorDepth*/ _ = Data([UInt8](blockData[start..<end])).bigEndian32()
            start = end
            end = start + 4
            let /*numColors*/ _ = Data([UInt8](blockData[start..<end])).bigEndian32()
            start = end
            end = start + 4
            let pictureLength = Data([UInt8](blockData[start..<end])).bigEndian32()
            start = end
            end = start + pictureLength
            let data = Data([UInt8](blockData[start..<end]))
            var imageType: MetadataImageType?
            switch type {
            case 3:
                imageType = .frontCover
            case 4:
                imageType = .backCover
            default:
                break
            }
            var format: String?
            switch mimeType {
            case "image/jpeg":
                format = "jpg"
            case "image/png":
                format = "png"
            default:
                break
            }
            if let format = format, let imageType = imageType {
                switch imageType {
                case .frontCover:
                    images[imageType] = ("FrontCover.\(format)",data)
                case .backCover:
                    images[imageType] = ("BackCover.\(format)",data)
                }
            }
        }
    }
    
    mutating func getStreamInfo(_ blockData: [UInt8]) {
        let headerEndBuf = Data([UInt8](blockData[10...17]))
        var sampleRate = Data([UInt8](headerEndBuf[0...2])).bigEndian24()
        sampleRate >>= 4
        var numChannels = Int(headerEndBuf[2])
        numChannels >>= 1
        numChannels &= 0x07
        var bitsPerSample = Data([UInt8](headerEndBuf[2...3])).bigEndian16()
        bitsPerSample >>= 4
        bitsPerSample &= 0x1f
        var totalSamples = Data([UInt8](headerEndBuf[3...7])).bigEndian40()
        totalSamples &= 0x0fffffffff
        let elapsedTime = totalSamples / sampleRate
        let metadataItem = MetadataItem(type: .duration, contentsInt: elapsedTime)
        metadataItems[.duration] = metadataItem
    }
    
    mutating func extractTags() -> (Bool, String) {
        if let buffer = readFile(8192) {
            
            if var offset = findSyncOffset(buffer) {

                var flacBuffer = [UInt8](buffer[(offset)...])
                while let blockHeader = MetaDataBlock(flacBuffer) {
                    let blockData = [UInt8](buffer[(offset+4)...])
                    offset += blockHeader.blockSize
                    flacBuffer = [UInt8](buffer[offset...])
                    
                    switch blockHeader.type {
                        case 0:
                             getStreamInfo(blockData)
                        case 1:
                            logger.info("Metadata Padding block of length \(blockHeader.length) skipped")
                        case 2:
                            logger.info("Metadata Application block of length \(blockHeader.length) skipped")
                        case 3:
                            logger.info("Metadata Seektable block of length \(blockHeader.length) skipped")
                        case 4:
                            getVorbisComments(blockData)
                        case 5:
                            logger.info("Metadata Cuesheet block of length \(blockHeader.length) skipped")
                        case 6:
                            getPicture(blockData)
                        default:
                            logger.info("Unknown metadata block - <\(blockHeader.type)> - of length \(blockHeader.length) skipped")
                            break
                            
                    }

                    if blockHeader.lastBlock {
                        break
                    }
                }
            }
        } else {
            return (false, "Unable to read from '\(url.path)")
        }
        return (true, "OK")
    }
    
    func printAudioFile() {
        // TODO: Add body
    }
    
}

