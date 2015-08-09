//
//  MTMusicSequence.swift
//  MidiToolbox
//
//  Created by Thom Jordan on 11/18/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//

/*--------------------------------------------------------------------------------------------------------*
|                                      M U S I C   S E Q U E N C E                                        |
*---------------------------------------------------------------------------------------------------------*/

import Cocoa
import AudioToolbox


public typealias MusicSequenceType = UInt32


public class MTMusicSequence: NSObject {
    
    var sequence:MusicSequence
    
    override public init() {
        sequence = MusicSequence()
        (confirm)(NewMusicSequence(&sequence))
        super.init()
    }
    
    public init(theSequence: MusicSequence) {
        sequence = theSequence
        super.init()
    }
    
    public func newTrack() -> MTMusicTrack {
        var trk = MusicTrack()
        (confirm)(MusicSequenceNewTrack(sequence, &trk))
        return MTMusicTrack(theTrack: trk)
    }
    
    public func disposeTrack(mtMusicTrack: MTMusicTrack) {
        (confirm)(MusicSequenceDisposeTrack(sequence, mtMusicTrack.track))
    }
    
    public func setMIDIEndpoint(endpoint: MIDIEndpointRef?) {
        if let ep = endpoint {
            NSLog("MIDI Endpoint set.")
            (confirm)(MusicSequenceSetMIDIEndpoint(sequence, ep))
        }
    }
    
    public func setAUGraph(augraph: AUGraph?) {
        if let augr = augraph {
            (confirm)(MusicSequenceSetAUGraph(sequence, augr))
        }
    }
    
    public func getAUGraph() -> AUGraph {
        var augr = AUGraph()
        (confirm)(MusicSequenceGetAUGraph(sequence, &augr))
        return augr
    }
    
    public func reverse() {
        (confirm)(MusicSequenceReverse(sequence))
    }
    
    public func getTrackIndex(mtMusicTrack: MTMusicTrack) -> UInt32 {
        var idx = UInt32()
        (confirm)(MusicSequenceGetTrackIndex(sequence, mtMusicTrack.track, &idx))
        return idx
    }
    
    public func getTrackAtIndex(trackIndex: UInt32) -> MTMusicTrack {
        var trk = MusicTrack()
        (confirm)(MusicSequenceGetIndTrack(sequence, trackIndex, &trk))
        return MTMusicTrack(theTrack: trk)
    }
    
    public func getTrackCount() -> UInt32 {
        var numtracks = UInt32()
        (confirm)(MusicSequenceGetTrackCount(sequence, &numtracks))
        return numtracks
    }
    
    public func getTempoTrack() -> MTMusicTrack {
        var trk = MusicTrack()
        (confirm)(MusicSequenceGetTempoTrack(sequence, &trk))
        return MTMusicTrack(theTrack: trk)
    }
    
    public func getSecondsForBeats(beats: MusicTimeStamp) -> Float64 {
        var numsecs = Float64()
        (confirm)(MusicSequenceGetSecondsForBeats(sequence, beats, &numsecs))
        return numsecs
    }
    
    public func getBeatsForSeconds(seconds: Float64) -> MusicTimeStamp {
        var beats = MusicTimeStamp()
        (confirm)(MusicSequenceGetBeatsForSeconds(sequence, seconds, &beats))
        return beats
    }
    
    public func getInfoDictionary() -> CFDictionary? {
        if let cfd = MusicSequenceGetInfoDictionary(sequence) {
            return cfd
        }
        return nil
    }
    
    public func getSequenceType() -> MusicSequenceType {
        var mst = MusicSequenceType()
        (confirm)(MusicSequenceGetSequenceType(sequence, &mst))
        return mst
    }
    
    public func setSequenceType(type: MusicSequenceType) {
        (confirm)(MusicSequenceSetSequenceType(sequence, type))
    }
    
    // ----------------------------------------------------------------------
    
    // needs more work on the C <--> Swift interface
    
    public func beatsToBarBeatTime(beats: MusicTimeStamp, subbeatDivisor: UInt32) -> CABarBeatTime {
        var bbt = CABarBeatTime(bar: Int32(), beat: UInt16(), subbeat: UInt16(), subbeatDivisor: UInt16(), reserved: UInt16())
        (confirm)(MusicSequenceBeatsToBarBeatTime(sequence, beats, subbeatDivisor, &bbt))
        return bbt
    }
    public func barBeatTimeToBeats(bbTime: UnsafePointer<CABarBeatTime>) -> MusicTimeStamp {
        var beats = MusicTimeStamp()
        (confirm)(MusicSequenceBarBeatTimeToBeats(sequence, bbTime, &beats))
        return beats
    }
    
    /*
    
    remaining MusicSequence functions:
    
    fileCreate
    fileCreateData
    fileLoad
    fileLoadData
    
    func MusicSequenceSetUserCallback(_ inSequence: MusicSequence,
        _ inCallback: MusicSequenceUserCallback,
        _ inClientData: UnsafeMutablePointer<Void>) -> OSStatus
    */
    // -----------------------------------------------------------------------
    
}

    /*
    struct CABarBeatTime {
        bar            : UInt32;
        beat           : UInt16;
        subbeat        : UInt16;
        subbeatDivisor : UInt16;
        reserved       : UInt16;
    };
    */
