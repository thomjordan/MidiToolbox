//
//  MT_Events.swift
//  InteractiveMusicAgentObjC
//
//  Created by Thom Jordan on 11/30/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//

import Cocoa
import AudioToolbox


public struct Note {
    
    public enum Trait {
        case NUM(UInt8)
        case VEL(UInt8)
        case DUR(MusicTimeStamp)
        case REL(UInt8)
        case CHN(UInt8)
    }
    
    public var notenum  = UInt8(24)
    public var velocity = UInt8(127)
    public var duration = MusicTimeStamp(0.5)
    public var release  = UInt8(0)
    public var channel  = UInt8(0)
    
    public func edit(type: Trait) -> Note {
        var n = self
        switch type {
        case let Trait.NUM(val):
            n.notenum  = val
            return n
            
        case let Trait.VEL(val):
            n.velocity = val
            return n
        case let Trait.DUR(val):
            n.duration = val
            return n
        case let Trait.REL(val):
            n.release  = val
            return n
        case let Trait.CHN(val):
            n.channel  = val
            return n
        default:
            return n
        }
    }
}



/*
func editNote(theNote: Note, #type: NoteTrait) -> Note {
    var n = theNote
    switch type {
    case let NoteTrait.NUM(val):
        n.notenum  = val
        return n
    case let NoteTrait.VEL(val):
        n.velocity = val
        return n
    case let NoteTrait.DUR(val):
        n.duration = val
        return n
    case let NoteTrait.REL(val):
        n.release  = val
        return n
    case let NoteTrait.CHN(val):
        n.channel  = val
        return n
    case let NoteTrait.MUT(val):
        n.muted  = val
        return n
    default:
        return n
    }
}
*/



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
        MusicTrackNewUserEvent
        MusicTrackNewMetaEvent
        MusicTrackNewExtendedTempoEvent
        MusicTrackNewParameterEvent
        MusicTrackNewExtendedNoteEvent
        MusicTrackNewMIDIRawDataEvent
        MusicTrackNewMIDIChannelEvent

        MusicTrackGetProperty
        MusicTrackSetProperty

*/
