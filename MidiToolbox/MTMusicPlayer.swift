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


public class MTMusicPlayer: NSObject {
    
    var player:MusicPlayer
    
    override public init() {
        player = MusicPlayer()
        (confirm)(NewMusicPlayer(&player))
        super.init()
    }
    
    public func setSequence(mtMusicSequence: MTMusicSequence) {
        (confirm)(MusicPlayerSetSequence(player, mtMusicSequence.sequence))
    }
    
    public func getSequence() -> MTMusicSequence {
        var seq = MusicSequence()
        (confirm)(MusicPlayerGetSequence(player, &seq))
        return MTMusicSequence(theSequence: seq)
    }
    
    public func disposePlayer() {
        (confirm)(DisposeMusicPlayer(player))
    }
    
    public func setTime(time: MusicTimeStamp) {
        (confirm)(MusicPlayerSetTime(player, time))
    }
    
    public func getTime() -> MusicTimeStamp {
        var time = MusicTimeStamp()
        (confirm)(MusicPlayerGetTime(player, &time))
        return time
    }
    
    public func preroll() {
        (confirm)(MusicPlayerPreroll(player))
    }
    
    public func start() {
        (confirm)(MusicPlayerStart(player))
    }
    
    public func stop() {
        (confirm)(MusicPlayerStop(player))
    }
    
    public func isPlaying() -> DarwinBoolean {
        var playing = DarwinBoolean(false)
        (confirm)(MusicPlayerIsPlaying(player, &playing))
        return playing
    }
    
    public func setPlayRateScalar(rate: Float64) {
        (confirm)(MusicPlayerSetPlayRateScalar(player, rate))
    }
    
    public func getPlayRateScalar() -> Float64 {
        var rate = Float64()
        (confirm)(MusicPlayerGetPlayRateScalar(player, &rate))
        return rate
    }
    
    public func getHostTimeForBeats(beats: MusicTimeStamp) -> UInt64 {
        var time = UInt64()
        (confirm)(MusicPlayerGetHostTimeForBeats(player, beats, &time))
        return time
    }
    
    public func getBeatsForHostTime(time: UInt64) -> MusicTimeStamp {
        var beats = MusicTimeStamp()
        (confirm)(MusicPlayerGetBeatsForHostTime(player, time, &beats))
        return beats
    }
    
    
}
