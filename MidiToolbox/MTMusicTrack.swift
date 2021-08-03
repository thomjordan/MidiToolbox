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


public enum TrackEvent {
    
    case note(MIDINoteMessage)
    
    case controlChange(MIDIChannelMessage)
    
    case programChange(MIDIChannelMessage)
    
    case pitchBend(MIDIChannelMessage)
    
    case channelPressure(MIDIChannelMessage)
    
    case aftertouch(MIDIChannelMessage)
    
    case auparam(ParameterEvent)
    
    case userdata(MusicEventUserData)
    
    case meta(MIDIMetaEvent)
    
    case sysex(MIDIRawData)
    
    
    // MIDI-conforming track events
    
    public static func makeNote(ch: UInt8 = 0, nn: UInt8 = 24, vl: UInt8 = 108, rv: UInt8 = 0, du: Float32 = 0.5) -> TrackEvent {
        
        return .note(MIDINoteMessage( channel: ch, note: nn, velocity: vl, releaseVelocity: rv, duration: du))
    }
    
    public static func makeControlChange(ch: UInt8 = 0, ccnum: UInt8 = 1, ccvalue: UInt8 = 0) -> TrackEvent {
        
        let msgType : UInt8 = 0xB0
        
        return .controlChange( MIDIChannelMessage(status: msgType + ch, data1: ccnum, data2: ccvalue, reserved: 0))
    }
    
    public static func makeProgramChange(ch: UInt8 = 0, bank: UInt8 = 1, programnum: UInt8 = 0) -> TrackEvent {
        
        let msgType : UInt8 = 0xC0
        
        return .programChange( MIDIChannelMessage(status: msgType + ch, data1: bank, data2: programnum, reserved: 0))
    }
    
    public static func makePitchBend(ch: UInt8 = 0, msv: UInt8 = 0, lsv: UInt8 = 0) -> TrackEvent {
        
        let msgType : UInt8 = 0xE0
        
        return .pitchBend( MIDIChannelMessage(status: msgType + ch, data1: msv, data2: lsv, reserved: 0))
    }
    
    public static func makeChannelPressure(ch: UInt8 = 0, pressure: UInt8 = 0) -> TrackEvent {
        
        let msgType : UInt8 = 0xD0
        
        return .channelPressure( MIDIChannelMessage(status: msgType + ch, data1: pressure, data2: 0, reserved: 0))
    }
    
    public static func makeAftertouch(ch: UInt8 = 0, keynum: UInt8 = 0, amount: UInt8 = 0) -> TrackEvent {
        
        let msgType : UInt8 = 0xA0
        
        return .aftertouch( MIDIChannelMessage(status: msgType + ch, data1: keynum, data2: amount, reserved: 0))
    }
    
//    public var auparam  = ParameterEvent(parameterID: AudioUnitParameterID(), scope: AudioUnitScope(), element: AudioUnitElement(), value: AudioUnitParameterValue())
//    public var aupreset = AUPresetEvent(scope: AudioUnitScope(), element: AudioUnitElement(), preset: CFPropertyList!)
//    public var userdata = MusicEventUserData(length: UInt32(0), data: UInt8()) // for user-defined event data of n bytes (length = n)
//    public var meta     = MIDIMetaEvent(metaEventType: UInt8(), unused1: UInt8(), unused2: UInt8(), unused3: UInt8(), dataLength: UInt32(), data: UInt8())
//    public var sysex    = MIDIRawData(length: UInt32(0), data: UInt8())
    
//    Example:
//    var event   = MusicEventUserData(length: 1, data: (0xAA))
//    let status2 = MusicTrackNewUserEvent(track, beat + MusicTimeStamp(duration), &event)

}


open class MTMusicTrack: NSObject {
    
    public var track         : MusicTrack?
    public var loopDuration  : MusicTimeStamp
    public var numberOfLoops : Int32
    public var trackLength   : MusicTimeStamp
    
    //  no specified track length means that it will use the timestamp of its current last element.
    
    public override init() {
        track         = nil
        loopDuration  = MusicTimeStamp(0.0)
        numberOfLoops = Int32(0)
        trackLength   = MusicTimeStamp(0.0)
        super.init()
    }
    public init(theTrack: MusicTrack) {
        track         = theTrack
        loopDuration  = MusicTimeStamp(0.0)
        numberOfLoops = Int32(0)
        trackLength   = MusicTimeStamp(0.0)
        super.init()
    }
    
    open func add(event: TrackEvent, at: MusicTimeStamp) {
        
        guard let track = self.track else { return }
        
        switch event {
            
        case var .note( evnt ):
            
            (confirm)(MusicTrackNewMIDINoteEvent(track, at, &evnt))
            
        case var .controlChange( evnt ):
            
            (confirm)(MusicTrackNewMIDIChannelEvent(track, at, &evnt))
            
        case var .programChange( evnt ):
            
            (confirm)(MusicTrackNewMIDIChannelEvent(track, at, &evnt))
            
        case var .pitchBend( evnt ):
            
            (confirm)(MusicTrackNewMIDIChannelEvent(track, at, &evnt))
            
        case var .channelPressure( evnt ):
            
            (confirm)(MusicTrackNewMIDIChannelEvent(track, at, &evnt))
            
        case var .aftertouch( evnt ):
            
            (confirm)(MusicTrackNewMIDIChannelEvent(track, at, &evnt))
            
        case var .userdata( userDataEvent ):
            
            (confirm)(MusicTrackNewUserEvent(track, at, &userDataEvent))

            
        default: break
            
        }
    }
    
    /*
        EVENT CREATORS (these should be wrapped) :
        
        MusicTrackNewAUPresetEvent
        MusicTrackNewUserEvent
        MusicTrackNewMetaEvent
        MusicTrackNewExtendedTempoEvent
        MusicTrackNewParameterEvent
        MusicTrackNewExtendedNoteEvent
        MusicTrackNewMIDIRawDataEvent
        MusicTrackNewMIDIChannelEvent
        MusicTrackNewMIDINoteEvent
        
        MusicTrackGetProperty
        MusicTrackSetProperty
    */

    
    open func changeNumberOfLoops(_ numloops:Int32) {
        guard let tk = track else { return }
        numberOfLoops = numloops
        var loopInfo:MusicTrackLoopInfo = MusicTrackLoopInfo(loopDuration: loopDuration, numberOfLoops: numloops)
        (confirm)(MusicTrackSetProperty(tk, UInt32(kSequenceTrackProperty_LoopInfo), &loopInfo, UInt32(MemoryLayout<MusicTrackLoopInfo>.size) as UInt32))
    }
    
    open func changeLoopDuration(_ duration:MusicTimeStamp) {
        guard let tk = track else { return }
        loopDuration = duration
        var loopInfo:MusicTrackLoopInfo = MusicTrackLoopInfo(loopDuration: duration, numberOfLoops: numberOfLoops)
        (confirm)(MusicTrackSetProperty(tk, UInt32(kSequenceTrackProperty_LoopInfo), &loopInfo, UInt32(MemoryLayout<MusicTrackLoopInfo>.size) as UInt32))
    }
    
    open func changeTrackLength(_ trklen: MusicTimeStamp) {
        guard let tk = track else { return }
        trackLength = trklen
        (confirm)(MusicTrackSetProperty(tk, UInt32(kSequenceTrackProperty_TrackLength), &trackLength, UInt32(MemoryLayout<MusicTimeStamp>.size)))
    }
    
    open func newExtendedTempoEvent(_ location:MusicTimeStamp, bpm:Float64) {
        guard let tk = track else { return }
        (confirm)(MusicTrackNewExtendedTempoEvent(tk, location, bpm))
    }
    
    open func setDestAUNode(_ node: AUNode?) {
        guard let tk = track else { return }
        if let n = node {
            (confirm)(MusicTrackSetDestNode(tk, n))
        }
    }
    
    open func getDestAUNode() -> AUNode? {
        guard let tk = track else { return nil }
        var node = AUNode()
        (confirm)(MusicTrackGetDestNode(tk, &node))
        return node
    }
    
    open func setDestMIDIEndpoint(_ endpoint: MIDIEndpointRef?) {
        guard let tk = track else { return }
        if let ep = endpoint {
            (confirm)(MusicTrackSetDestMIDIEndpoint(tk, ep))
        }
    }
    
    open func getDestMIDIEndpoint() -> MIDIEndpointRef? {
        guard let tk = track else { return nil }
        var endp = MIDIEndpointRef()
        (confirm)(MusicTrackGetDestMIDIEndpoint(tk, &endp))
        return endp
    }
    
    open func mergeFromTrack(_ sourceTrack: MTMusicTrack, sourceStart: MusicTimeStamp, sourceEnd: MusicTimeStamp, destInsertTime: MusicTimeStamp) {
        guard let tk = track else { return }
        guard let source_tk = sourceTrack.track else { return }
        (confirm)(MusicTrackMerge(source_tk, sourceStart, sourceEnd, tk, destInsertTime))
    }
    
    open func mergeIntoTrack(_ destTrack: MTMusicTrack, sourceStart: MusicTimeStamp, sourceEnd: MusicTimeStamp, destInsertTime: MusicTimeStamp) {
        guard let tk = track else { return }
        guard let dest_tk = destTrack.track else { return }
        (confirm)(MusicTrackMerge(tk, sourceStart, sourceEnd, dest_tk, destInsertTime))
    }
    
    open func copyInsertFrom(_ sourceTrack: MTMusicTrack, sourceStart: MusicTimeStamp, sourceEnd: MusicTimeStamp, destInsertTime: MusicTimeStamp) {
        guard let tk = track else { return }
        guard let source_tk = sourceTrack.track else { return }
        (confirm)(MusicTrackCopyInsert(source_tk, sourceStart, sourceEnd, tk, destInsertTime))
    }
    
    open func copyInsertInto(_ destTrack: MTMusicTrack, sourceStart: MusicTimeStamp, sourceEnd: MusicTimeStamp, destInsertTime: MusicTimeStamp) {
        guard let tk = track else { return }
        guard let dest_tk = destTrack.track else { return }
        (confirm)(MusicTrackCopyInsert(tk, sourceStart, sourceEnd, dest_tk, destInsertTime))
    }
    
    open func cut(_ startTime: MusicTimeStamp, endTime: MusicTimeStamp) {
        guard let tk = track else { return }
        (confirm)(MusicTrackCut(tk, startTime, endTime))
    }
    
    open func clear(_ startTime: MusicTimeStamp, endTime: MusicTimeStamp) {
        guard let tk = track else { return }
        (confirm)(MusicTrackClear(tk, startTime, endTime))
    }
    
    open func moveEvents(_ startTime: MusicTimeStamp, endTime: MusicTimeStamp, moveTime: MusicTimeStamp) {
        guard let tk = track else { return }
        (confirm)(MusicTrackMoveEvents(tk, startTime, endTime, moveTime))
    }
    
    open func getSequence() -> MTMusicSequence? {
        guard let tk = track else { return nil }
        var seq: MusicSequence? = nil
        (confirm)(MusicTrackGetSequence(tk, &seq))
        guard let sq = seq else { return nil }
        return MTMusicSequence(theSequence: sq)
    }
    
}


