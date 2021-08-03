//
//  MTMusicPlayer.swift
//  MidiToolbox
//
//  Created by Thom Jordan on 11/18/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//

/*--------------------------------------------------------------------------------------------------------*
 |                                       M U S I C   P L A Y E R                                          |
 *--------------------------------------------------------------------------------------------------------*/


import Cocoa
import AudioToolbox


open class MTMusicPlayer: NSObject {
    
    public var player:MusicPlayer? = nil
    
    // If MTMusicPlayer passes init(), it is then guaranteed to contain a valid MusicPlayer.
    // So instead of needlessly propagating Optionals, we use the '!' operator if it's guaranteed that the value must already exist.
    
    public override init() {
        (confirm)(NewMusicPlayer(&player))
        super.init()
    }
    
    open func setSequence(_ mtMusicSequence: MTMusicSequence) {
        guard let playr = player else { return }
        (confirm)(MusicPlayerSetSequence(playr, mtMusicSequence.sequence!))
    }
    
    open func getSequence() -> MTMusicSequence? {
        guard let playr = player else { return nil }
        var seq: MusicSequence? = nil
        (confirm)(MusicPlayerGetSequence(playr, &seq))
        guard let sq = seq else { return nil }
        return MTMusicSequence(theSequence: sq)
    }
    
    open func disposePlayer() {
        guard let playr = player else { return }
        (confirm)(DisposeMusicPlayer(playr))
    }
    
    open func setTime(_ time: MusicTimeStamp) {
        guard let playr = player else { return }
        (confirm)(MusicPlayerSetTime(playr, time))
    }
    
    open func getTime() -> MusicTimeStamp {
        guard let playr = player else { return 0 } // HACK
        var time = MusicTimeStamp()
        (confirm)(MusicPlayerGetTime(playr, &time))
        return time
    }
    
    open func preroll() {
        guard let playr = player else { return }
        (confirm)(MusicPlayerPreroll(playr))
    }
    
    open func start() {
        guard let playr = player else { return }
        (confirm)(MusicPlayerStart(playr))
    }
    
    open func stop() {
        guard let playr = player else { return }
        (confirm)(MusicPlayerStop(playr))
    }
    
    open func fullStop() {
        stop(); setTime(0); preroll()
    }

    open func isPlaying() -> DarwinBoolean {
        guard let playr = player else { return false }
        var playing = DarwinBoolean(false)
        (confirm)(MusicPlayerIsPlaying(playr, &playing))
        return playing
    }
    
    open func setPlayRateScalar(_ rate: Float64) {
        guard let playr = player else { return }
        (confirm)(MusicPlayerSetPlayRateScalar(playr, rate))
    }
    
    open func getPlayRateScalar() -> Float64? {
        guard let playr = player else { return nil }
        var rate = Float64()
        (confirm)(MusicPlayerGetPlayRateScalar(playr, &rate))
        return rate
    }
    
    open func getHostTimeForBeats(_ beats: MusicTimeStamp) -> UInt64? {
        guard let playr = player else { return nil }
        var time = UInt64()
        (confirm)(MusicPlayerGetHostTimeForBeats(playr, beats, &time))
        return time
    }
    
    open func getBeatsForHostTime(_ time: UInt64) -> MusicTimeStamp? {
        guard let playr = player else { return nil }
        var beats = MusicTimeStamp()
        (confirm)(MusicPlayerGetBeatsForHostTime(playr, time, &beats))
        return beats
    }
    
    
}

