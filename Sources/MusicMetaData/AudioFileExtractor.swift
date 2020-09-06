//
//  AudioFileExtractor.swift
//  
//
//  Created by Robert Cheal on 9/6/20.
//

import Foundation
import ID3TagEditor

struct AudioFileExtractor {
    
    private let id3TagEditor: ID3TagEditor = ID3TagEditor()
    private let url: URL
    private let filename: String
    private let relativeFilename: String
    private var frames: [FrameName:ID3FrameEx] = [:]
    
    func getFilename() -> String { filename }
    func getRelativeFilename() -> String { relativeFilename }
    
    
    init(file fname: String) {
        filename = fname
        url = URL(fileURLWithPath: fname, isDirectory: false)
        relativeFilename = url.relativePath
    }
    
    init(url: URL) {
        self.url = url
        filename = self.url.path
        relativeFilename = url.relativePath
    }
    
    func getFrame(_ frameName: FrameName) -> ID3FrameEx? {
        return frames[frameName]
    }
    
    mutating func getFrames() {
        do {
            if let id3Tag = try id3TagEditor.read(from: filename) {
                for (key,value) in id3Tag.frames {
                    frames[key] = ID3FrameEx(frameName: key, frame: value)
                }
            }
        } catch {
            print("Exception getting frames for \(filename) - \(error)")
        }

    }
    
    mutating func removeFrame(_ frameName: FrameName) {
        guard let index = frames.index(forKey: frameName) else { return }
        frames.remove(at: index)
    }
    
    func printAudioFile() {

        print("\n  File: \(filename)")
        for frame in frames {
            frame.value.printFrame()
        }
    }
    
    func getFrameValue(_ frameName: FrameName) -> String? {
        let frame = frames[frameName]
        return frame?.getFrameValue()
    }
    
    func getFramePartValue(_ frameName: FrameName) -> Int? {
        let frame = frames[frameName]
        return frame?.getFramePartValue()
    }
    
    func getFrameTotalValue(_ frameName: FrameName) -> Int? {
        let frame = frames[frameName]
        return frame?.getFrameTotalValue()
    }

}
