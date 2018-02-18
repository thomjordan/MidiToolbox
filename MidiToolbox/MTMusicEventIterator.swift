//
//  MTMusicEventIterator.swift
//  MidiToolbox
//
//  Created by Thom Jordan on 11/18/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//

/*--------------------------------------------------------------------------------------------------------*
 |                             M U S I C   E V E N T   I T E R A T O R                                    |
 *--------------------------------------------------------------------------------------------------------*/

import Cocoa
import AudioToolbox


open class MTMusicEventIterator: NSObject {
    
    /*
    A newly-created music event iterator points at the first event on the music track specified in the parameter.
    
    If you edit a music track after associating it with a music event iterator, you must discard iterator and create a new one.
    Perform the following steps after editing the track:
    
    (1) Obtain the current position using the MusicEventIteratorGetEventInfo function, and save the position.
    
    (2) Dispose of the music event iterator.
    
    (3) Create a new iterator.
    
    (4) Seek to the desired position using the MusicEventIteratorSeek function.
    
    */
    
    public var eventIterator:MusicEventIterator? = nil
    
    public  init(track: MTMusicTrack) {
        guard let tk = track.track else { return }
        (confirm)(NewMusicEventIterator(tk, &eventIterator))
    }
    
    open func dispose() {
        guard let ei = eventIterator else { return }
        (confirm)(DisposeMusicEventIterator(ei))
    }
    
    // --------------------------------------------------------------------------------------------------------
    
    // Positions a music event iterator at a specified timestamp, in beats:
    
    open func seek(_ time: MusicTimeStamp) {
        guard let ei = eventIterator else { return }
        (confirm)(MusicEventIteratorSeek(ei, time))
    }
    /*  If there is no music event at the specified time, on output the iterator points to the first event after that time.
    
    To position the iterator immediately beyond the final event of a music track, specify kMusicTimeStamp_EndOfTrack
    for this parameter. You can then call the MusicEventIteratorPreviousEvent to backtrack to the final event of the music track.
    
       To position the iterator at the first event of a music track, specify a value of 0 for this parameter.   */
    
    
    // --------------------------------------------------------------------------------------------------------
    
    // Positions a music event iterator at the next event on a music track:
    
    open func nextEvent() {
        guard let ei = eventIterator else { return }
        (confirm)(MusicEventIteratorNextEvent(ei))
    }
    /*  Use this function to increment the position of a music event iterator forward through a music track’s events.
    
    If an iterator is at the final event of a track when you call this function, the iterator then moves beyond
    the final event. You can detect if the iterator is beyond the final event by calling the MusicEventIteratorHasCurrentEvent function.
    
    This code snippet illustrates how to use a music event iterator to proceed forward along a music track, from the start:
    
    // Create a new iterator, which automatically points at the first event on the iterator's music track.
    
        DarwinBoolean hasCurrentEvent;
    
        MusicEventIteratorHasCurrentEvent (myIterator, &hasCurrentEvent);
    
        while (hasCurrentEvent) {
            // do work here
            MusicEventIteratorNextEvent (myIterator);
            MusicEventIteratorHasCurrentEvent (myIterator, &hasCurrentEvent);
        }  
    
    */
    // --------------------------------------------------------------------------------------------------------
    
    // Positions a music event iterator at the previous event on a music track:
    
    open func previousEvent() {
        guard let ei = eventIterator else { return }
        (confirm)(MusicEventIteratorPreviousEvent(ei))
    }
    /*  Use this function to decrement a music event iterator, moving it backward through a music track’s events.
        If an iterator is at the first event of a track when you call this, the iterator position remains unchanged
           and this returns an error.
    
    This code snippet illustrates how to use a music event iterator to proceed backward along a music track, from the end:
    
        // Points iterator just beyond the final event on its music track
        MusicEventIteratorSeek (myIterator, kMusicTimeStamp_EndOfTrack);
    
        DarwinBoolean hasPreviousEvent;
        MusicEventIteratorHasPreviousEvent (myIterator, &hasPreviousEvent);
    
        while (hasPreviousEvent) {
            MusicEventIteratorPreviousEvent (myIterator);
                // do work here
            MusicEventIteratorHasPreviousEvent (myIterator, &hasPreviousEvent);
    }
    
    */
    // --------------------------------------------------------------------------------------------------------
    
    
    // Indicates whether or not a music track contains an event before the music event iterator’s current position.
    
    open func hasPreviousEvent() -> DarwinBoolean? {
        guard let ei = eventIterator else { return nil }
        var hasEvent = DarwinBoolean(false)
        (confirm)(MusicEventIteratorHasPreviousEvent(ei, &hasEvent))
        return hasEvent
    }
    
    // Indicates whether or not a music track contains an event beyond the music event iterator’s current position.
    
    open func hasNextEvent() -> DarwinBoolean? {
        guard let ei = eventIterator else { return nil }
        var hasEvent = DarwinBoolean(false)
        (confirm)(MusicEventIteratorHasNextEvent(ei, &hasEvent))
        return hasEvent
    }
    
    // Indicates whether or not a music track contains an event at the music event iterator’s current position.
    
    open func hasCurrentEvent() -> DarwinBoolean? {
        guard let ei = eventIterator else { return nil }
        var hasEvent = DarwinBoolean(false)
        (confirm)(MusicEventIteratorHasCurrentEvent(ei, &hasEvent))
        return hasEvent
    }
    
    /*------------------------------------*
     |  MANAGING MUSIC EVENT INFORMATION  |
     *------------------------------------*/
    
    /*
    
    MUSIC EVENT TYPES:
    
    typealias MusicEventType = UInt
    
    kMusicEventType_NULL                  0
    kMusicEventType_ExtendedNote          1
    kMusicEventType_ExtendedTempo         2
    kMusicEventType_User                  3
    kMusicEventType_Meta                  4
    kMusicEventType_MIDINoteMessage       5
    kMusicEventType_MIDIChannelMessage    6
    kMusicEventType_MIDIRawData           7
    kMusicEventType_Parameter             8
    kMusicEventType_AUPreset              9
    
    */
    
    public struct EventInfo {
        public var timestamp     = MusicTimeStamp()
        public var eventType     = MusicEventType()
        public var eventData: UnsafeRawPointer? = nil  // constructing a void pointer
        public var dataSize      = UInt32()
    }
    
    //  Gets information about the event at a music event iterator’s current position.
    
    open func getEventInfo() -> EventInfo? {
        
        guard let ei = eventIterator else { return nil }
        
        let info = EventInfo()  //  Pass NULL for any output parameter whose information you do not need.
        var timestamp = info.timestamp
        var eventType = info.eventType
        var eventData = info.eventData
        var dataSize  = info.dataSize
        
        (confirm)(
            MusicEventIteratorGetEventInfo(
            ei,                 //  The music event iterator whose current event you want information about.
            &timestamp,  //  the timestamp of the music event, in beats.
            &eventType,  //  the type of music event (see above key)
            &eventData,  //  a reference to the music event data. The type of data is specified by the eventType parameter.
            &dataSize))  //  the size, in bytes, of the music event data in the eventData parameter.
        return info
    }
    
    //  Sets information for the event at a music event iterator’s current position.
    //   ..This should be wrapped inside of several individual functions, one for each event data type.
    
    open func setEventInfo(_ eventType: MusicEventType, eventData: UnsafeRawPointer) {
        guard let ei = eventIterator else { return }
        (confirm)(
            MusicEventIteratorSetEventInfo(
            ei,             // The music event iterator whose current event you want to set.
            eventType,      // The type of music event that you are specifying (see above key).
            eventData))     // The event data that you are specifying. The size and type of the data must be
        //   appropriate for the music event type you specify in the eventType parameter.
    }
    /*  Use this function to set the music event type and event data for the event that a music event iterator is positioned at.
        This function doesn’t allow you to change an event’s timestamp; to do that, call the MusicEventIteratorSetEventTime function.  */
    

// --------------------------------------------------------------------------------------------------------
    
    
    // Sets the timestamp for the event at a music event iterator’s current position.
    
    open func setEventTime(_ timestamp: MusicTimeStamp) {
        guard let ei = eventIterator else { return }
        (confirm)(MusicEventIteratorSetEventTime(ei, timestamp))
    }
    /*  After calling this function, the music event iterator remains positioned at the same event. However, because the event has
        been moved to a new location on the iterator’s music track, the iterator may no longer have a next or previous event.
        You can test this by calling MusicEventIteratorHasPreviousEvent and MusicEventIteratorHasNextEvent.                             */
    
    
    // Deletes the event at a music event iterator’s current position.
    
    open func deleteEvent() {
        guard let ei = eventIterator else { return }
        (confirm)(MusicEventIteratorDeleteEvent(ei))
    }
    /* After calling this function, the music event iterator points to the event that follows the deleted event—if there is such an event.
       If the event you deleted was the final event, the iterator is then positioned immediately beyond the final event of the music track.  */
    
}

// --------------------------------------------------------------------------------------------------------




