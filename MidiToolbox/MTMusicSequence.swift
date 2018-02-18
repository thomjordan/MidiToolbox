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

open class MTMusicSequence : NSObject {
    
    public var sequence : MusicSequence? = nil
    
    public var seqUserCallback : MusicSequenceUserCallback?
    public var callbackRoutine : ((String, UInt32, MusicTimeStamp) -> String)?
    public var outputRoutine   : ((String) -> Void)?
    
    // If MTMusicSequence passes init(), it is then guaranteed to contain a valid MusicSequence.
    // So instead of needlessly propagating Optionals, we use the '!' operator if it's guaranteed that the value must already exist.
    
    public override init() {
        (confirm)(NewMusicSequence(&sequence))
        super.init()
    }
    
    public init(theSequence: MusicSequence) {
        sequence = theSequence
        super.init()
    }
    
    open func newTrack() -> MTMusicTrack {
       // guard let seq = sequence else { return nil }
        var trk: MusicTrack? = nil
        (confirm)(MusicSequenceNewTrack(sequence!, &trk))
        return MTMusicTrack(theTrack: trk!)
    }
    
    open func disposeTrack(_ mtMusicTrack: MTMusicTrack) {
        guard let tk = mtMusicTrack.track else { return }
        guard let seq = sequence else { return }
        (confirm)(MusicSequenceDisposeTrack(seq, tk))
    }
    
    open func disposeSequence() {
        guard let seq = sequence else { return }
        (confirm)(DisposeMusicSequence( seq )) 
    }
    
    open func setMIDIEndpoint(_ endpoint: MIDIEndpointRef?) {
        guard let seq = sequence else { return }
        if let ep = endpoint {
            (confirm)(MusicSequenceSetMIDIEndpoint(seq, ep))
        }
    }
    
    open func setAUGraph(_ augraph: AUGraph?) {
        guard let seq = sequence else { return }
        if let augr = augraph {
            (confirm)(MusicSequenceSetAUGraph(seq, augr))
        }
    }
    
    open func getAUGraph() -> AUGraph? {
        guard let seq = sequence else { return nil }
        var augr: AUGraph? = nil
        (confirm)(MusicSequenceGetAUGraph(seq, &augr))
        guard let augraph = augr else { return nil }
        return augraph
    }
    
    open func reverse() {
        guard let seq = sequence else { return }
        (confirm)(MusicSequenceReverse(seq))
    }
    
    open func getTrackIndex(_ mtMusicTrack: MTMusicTrack) -> UInt32? {
        guard let seq = sequence else { return nil }
        guard let tk = mtMusicTrack.track else { return nil }
        var idx = UInt32()
        (confirm)(MusicSequenceGetTrackIndex(seq, tk, &idx))
        return idx
    }
    
    open func getTrackAtIndex(_ trackIndex: UInt32) -> MTMusicTrack? {
        guard let seq = sequence else { return nil }
        var trk: MusicTrack? = nil
        (confirm)(MusicSequenceGetIndTrack(seq, trackIndex, &trk))
        guard let tk = trk else { return nil }
        return MTMusicTrack(theTrack: tk)
    }
    
    open func getTrackCount() -> UInt32 {
        guard let seq = sequence else { return 0 }
        var numtracks = UInt32()
        (confirm)(MusicSequenceGetTrackCount(seq, &numtracks))
        return numtracks
    }
    
    open func getTempoTrack() -> MTMusicTrack? {
        guard let seq = sequence else { return nil }
        var trk: MusicTrack? = nil
        (confirm)(MusicSequenceGetTempoTrack(seq, &trk))
        guard let tk = trk else { return nil }
        return MTMusicTrack(theTrack: tk)
    }
    
    open func getSecondsForBeats(_ beats: MusicTimeStamp) -> Float64? {
        guard let seq = sequence else { return nil }
        var numsecs = Float64()
        (confirm)(MusicSequenceGetSecondsForBeats(seq, beats, &numsecs))
        return numsecs
    }
    
    open func getBeatsForSeconds(_ seconds: Float64) -> MusicTimeStamp? {
        guard let seq = sequence else { return nil }
        var beats = MusicTimeStamp()
        (confirm)(MusicSequenceGetBeatsForSeconds(seq, seconds, &beats))
        return beats
    }
    
    open func getInfoDictionary() -> CFDictionary? {
        guard let seq = sequence else { return nil }
        let cfd = MusicSequenceGetInfoDictionary(seq)
        if cfd == MusicSequenceGetInfoDictionary(seq){
            return cfd
        }
        return nil
    }
    

    open func setSequenceType(_ type: MusicSequenceType) {
        guard let seq = sequence else { return }
        (confirm)(MusicSequenceSetSequenceType(seq, type))
    }
    
    // ----------------------------------------------------------------------
    
    // needs more work on the C <--> Swift interface
    
    open func beatsToBarBeatTime(_ beats: MusicTimeStamp, subbeatDivisor: UInt32) -> CABarBeatTime? {
        guard let seq = sequence else { return nil }
        var bbt = CABarBeatTime(bar: Int32(), beat: UInt16(), subbeat: UInt16(), subbeatDivisor: UInt16(), reserved: UInt16())
        (confirm)(MusicSequenceBeatsToBarBeatTime(seq, beats, subbeatDivisor, &bbt))
        return bbt
    }
    open func barBeatTimeToBeats(_ bbTime: UnsafePointer<CABarBeatTime>) -> MusicTimeStamp? {
        guard let seq = sequence else { return nil }
        var beats = MusicTimeStamp()
        (confirm)(MusicSequenceBarBeatTimeToBeats(seq, bbTime, &beats))
        return beats
    }
    
    @objc open func defUserCallback(proc: ((String, UInt32, MusicTimeStamp) -> String)? = nil, outputProc: ((String) -> Void)? = nil ) -> OSStatus {
        
        guard let seq = sequence else { return -1 }
        
        self.callbackRoutine = proc ?? { (str:String, idx:UInt32, start:MusicTimeStamp) -> String in
            return "track: \(idx); loc: \(start); \(str) "
        }
        
        self.outputRoutine = outputProc
        
        self.seqUserCallback = {
            (clientData:UnsafeMutableRawPointer?,
            sequence:MusicSequence,
            track:MusicTrack,
            eventTime:MusicTimeStamp,
            eventData:UnsafePointer<MusicEventUserData>,
            startSliceBeat:MusicTimeStamp,
            endSliceBeat:MusicTimeStamp) -> Void in
            
            var trackIndex = UInt32()
            (confirm)(MusicSequenceGetTrackIndex(sequence, track, &trackIndex))
            
            let mutablePtr = UnsafeMutablePointer(mutating: eventData)
            
            let client = unsafeBitCast(clientData, to: MTMusicSequence.self)
            
            if let asciiString = client.dereferenceUserData(ptr: mutablePtr) {
                if let callbackFun = client.callbackRoutine {
                    let result = callbackFun(asciiString, trackIndex, startSliceBeat)
                    // print("RETURNED FROM CALLBACK: " + result)
                    if let sendToOutlet = client.outputRoutine { sendToOutlet( result ) }
                }
            }
        }
        
        let status = MusicSequenceSetUserCallback(seq, seqUserCallback, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
        
        return status
    }
    
    public func addUserData(_ expr:String, onTracK tracknum: Int, atTime time: MusicTimeStamp) {
        
        let idx = UInt32(tracknum % Int(self.getTrackCount()))
        guard let trk = self.getTrackAtIndex(idx)?.track else { return }
        
        let bytes   = [UInt8](expr.utf8)
        let usrData = MyMusicEventUserData(data: bytes)
        
        confirm( MusicTrackNewUserEvent(trk, time, &usrData.MusicEventUserDataPtr.pointee) )
    }
    
    private func dereferenceUserData(ptr: UnsafeMutablePointer<MusicEventUserData>) -> String? {
        
        var packet:[UInt8] = []
        let rawPointer = UnsafeMutableRawPointer(ptr)
        let uData = ptr.pointee
        
        for i in 0..<uData.length {
            let nextByte = rawPointer.load(fromByteOffset: Int(i)+4, as: UInt8.self)
            packet.append( nextByte )
           // print(String(nextByte, radix: 10))
        }
        
        var result : String? = nil
        
        if let string = String(bytes: packet, encoding: String.Encoding.utf8) {
            result = string
          //  print(result!)
        }
        
        return result
    }
    
    
    /*
    
    remaining MusicSequence open functions:
    
    fileCreate
    fileCreateData
    fileLoad
    fileLoadData
    
    open func MusicSequenceSetUserCallback(_ inSequence: MusicSequence,
        _ inCallback: MusicSequenceUserCallback,
        _ inClientData: UnsafeMutablePointer<Void>) -> OSStatus
    */
    // -----------------------------------------------------------------------
    
}

    /*
    struct CABarBeatTime {
        bar            : UInt;
        beat           : UInt;
        subbeat        : UInt;
        subbeatDivisor : UInt;
        reserved       : UInt;
    };
    */
