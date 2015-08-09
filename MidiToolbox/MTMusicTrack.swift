//
//  MTMusicTrack.swift
//  MidiToolbox
//
//  Created by Thom Jordan on 11/18/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//

/*--------------------------------------------------------------------------------------------------------*
|                                       M U S I C   T R A C K                                             |
*---------------------------------------------------------------------------------------------------------*/

import Cocoa
import AudioToolbox



public class MTMusicTrack: NSObject {
    
    public var track   : MusicTrack
    public var durationOfLoop : MusicTimeStamp
    public var numberOfLoops  : Int32
    public var lengthOfTrack  : MusicTimeStamp
    
    
    // ********** PUT IN A SUBCLASS ***********
    
    public struct Attributes {
        var playChannel = UInt8(0) // adopt the convention of limiting a track to play on just one midi channels
        var pulseVal    = MusicTimeStamp(0.25)
        var swingRatio  = Float32(0.5)
       // var groove      = [Float32]() // separate out list-length vibe traits
       // var accents     = [UInt8]()
       // var mutes       = [UInt8]()
    }
    
    var attr = Attributes()
    
    // ****************************************
    
    
    //  no specified track length means that it will use the timestamp of its current last element.
    
    override public init() {
        track          = MusicTrack()
        durationOfLoop = MusicTimeStamp(0.0)
        numberOfLoops  = Int32(0)
        lengthOfTrack  = MusicTimeStamp(0.0)
        super.init()
    }
    public init(theTrack: MusicTrack) {
        track          = theTrack
        durationOfLoop = MusicTimeStamp(0.0)
        numberOfLoops  = Int32(0)
        lengthOfTrack  = MusicTimeStamp(0.0)
        super.init()
    }
    
    // Here's a collection of prototype events, some with common default values.
    // New events can conveniently be built from these with message chaining via functional composition and currying (partial application).
    /*
    struct Event {
        var note     = MIDINoteMessage(channel: 0, note: UInt8(36), velocity: UInt8(120), releaseVelocity: UInt8(0), duration: Float32(0.5))
        var cc       = MIDIChannelMessage(status: UInt8(0x00), data1: UInt8(0), data2: UInt8(0), reserved: UInt8(0))
        var auparam  = ParameterEvent(parameterID: AudioUnitParameterID(), scope: AudioUnitScope(), element: AudioUnitElement(), value: AudioUnitParameterValue())
        // var aupreset = AUPresetEvent(scope: AudioUnitScope(), element: AudioUnitElement(), preset: CFPropertyList!)
        var userdata = MusicEventUserData(length: UInt32(0), data: UInt8()) // for user-defined event data of n bytes (length = n)
        var meta     = MIDIMetaEvent(metaEventType: UInt8(), unused1: UInt8(), unused2: UInt8(), unused3: UInt8(), dataLength: UInt32(), data: UInt8())
        var sysex    = MIDIRawData(length: UInt32(0), data: UInt8())
    }
    */
    
// ---------  EVENT CREATORS -----------
    
    /*
        (these should be wrapped) :
        
        MusicTrackNewAUPresetEvent
        MusicTrackNewMetaEvent
        MusicTrackNewExtendedTempoEvent
        MusicTrackNewParameterEvent
        MusicTrackNewExtendedNoteEvent
        MusicTrackNewMIDIRawDataEvent
        MusicTrackNewMIDIChannelEvent
    
        MusicTrackGetProperty
        MusicTrackSetProperty
        
        (begun) :
    
        MusicTrackNewUserEvent
    */

    
// -------  EVENT DEPLOYMENT ------------
    
    public func addNote(n: Note, at: MusicTimeStamp) {
        var mnm = MIDINoteMessage(channel: n.channel, note: n.notenum, velocity: n.velocity, releaseVelocity: n.release, duration: Float32(n.duration) )
        (confirm)(MusicTrackNewMIDINoteEvent(track, at, &mnm))
    }
    
    public func addUserEvent(udat: UInt8, atbeat: MusicTimeStamp) {
        var evdat = MusicEventUserData( length: 1, data: udat )
        (confirm)(MusicTrackNewUserEvent(self.track, atbeat, &evdat))
    }
    

// -------  TRACK SETTINGS ------------
    
    public func loopRepetitions(numloops:Int32) {
        numberOfLoops = numloops
        var loopInfo:MusicTrackLoopInfo = MusicTrackLoopInfo(loopDuration: durationOfLoop, numberOfLoops: numloops)
        (confirm)(MusicTrackSetProperty(track, UInt32(kSequenceTrackProperty_LoopInfo), &loopInfo, UInt32(sizeof(MusicTrackLoopInfo)) as UInt32))
    }
    
    public func loopDuration(duration:MusicTimeStamp) {
        durationOfLoop = duration
        var loopInfo:MusicTrackLoopInfo = MusicTrackLoopInfo(loopDuration: duration, numberOfLoops: numberOfLoops)
        (confirm)(MusicTrackSetProperty(track, UInt32(kSequenceTrackProperty_LoopInfo), &loopInfo, UInt32(sizeof(MusicTrackLoopInfo)) as UInt32))
    }
    
    public func trackLength(trklen: MusicTimeStamp) {
        lengthOfTrack = trklen
        (confirm)(MusicTrackSetProperty(track, UInt32(kSequenceTrackProperty_TrackLength), &lengthOfTrack, UInt32(sizeof(MusicTimeStamp))))
    }
    
    // only works when called on a tempo track.
    // get the tempo track by calling the MTMusicSequence.getTempoTrack() method.
    public func tempo(location:MusicTimeStamp, bpm:Float64) {
        (confirm)(MusicTrackNewExtendedTempoEvent(track, location, bpm))
    }
    
// --------  TRACK ASSIGNMENT ---------
    
    public func setDestAUNode(node: AUNode?) {
        if let n = node {
            (confirm)(MusicTrackSetDestNode(track, n))
        }
    }
    
    public func getDestAUNode() -> AUNode { // optionals required here?
        var node = AUNode()
        (confirm)(MusicTrackGetDestNode(track, &node))
        return node
    }
    
    public func setDestMIDIEndpoint(endpoint: MIDIEndpointRef?) {
        if let ep = endpoint {
            (confirm)(MusicTrackSetDestMIDIEndpoint(track, ep))
        }
    }
    
    public func getDestMIDIEndpoint() -> MIDIEndpointRef { // optionals required here?
        var endp = MIDIEndpointRef()
        (confirm)(MusicTrackGetDestMIDIEndpoint(track, &endp))
        return endp
    }
    
// --------- TRACK EDITING -----------
    
    public func mergeFromTrack(sourceTrack: MTMusicTrack, sourceStart: MusicTimeStamp, sourceEnd: MusicTimeStamp, destInsertTime: MusicTimeStamp) {
        (confirm)(MusicTrackMerge(sourceTrack.track, sourceStart, sourceEnd, track, destInsertTime))
    }
    
    public func mergeIntoTrack(destTrack: MTMusicTrack, sourceStart: MusicTimeStamp, sourceEnd: MusicTimeStamp, destInsertTime: MusicTimeStamp) {
        (confirm)(MusicTrackMerge(track, sourceStart, sourceEnd, destTrack.track, destInsertTime))
    }
    
    public func copyInsertFrom(sourceTrack: MTMusicTrack, sourceStart: MusicTimeStamp, sourceEnd: MusicTimeStamp, destInsertTime: MusicTimeStamp) {
        (confirm)(MusicTrackCopyInsert(sourceTrack.track, sourceStart, sourceEnd, track, destInsertTime))
    }
    
    public func copyInsertInto(destTrack: MTMusicTrack, sourceStart: MusicTimeStamp, sourceEnd: MusicTimeStamp, destInsertTime: MusicTimeStamp) {
        (confirm)(MusicTrackCopyInsert(track, sourceStart, sourceEnd, destTrack.track, destInsertTime))
    }
    
    public func cut(startTime: MusicTimeStamp, endTime: MusicTimeStamp) {
        (confirm)(MusicTrackCut(track, startTime, endTime))
    }
    
    public func clear(startTime: MusicTimeStamp, endTime: MusicTimeStamp) {
        (confirm)(MusicTrackClear(track, startTime, endTime))
    }
    
    public func moveEvents(startTime: MusicTimeStamp, endTime: MusicTimeStamp, moveTime: MusicTimeStamp) {
        (confirm)(MusicTrackMoveEvents(track, startTime, endTime, moveTime))
    }
    
    public func getSequence() -> MTMusicSequence {
        var seq = MusicSequence()
        (confirm)(MusicTrackGetSequence(track, &seq))
        return MTMusicSequence(theSequence: seq)
    }
    
}

