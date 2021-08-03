//
//  utils.swift
//  InteractiveMusicAgentObjC
//
//  Created by Thom Jordan on 10/13/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//

import Foundation
import AudioToolbox


public func confirm(_ err: OSStatus) {
    if err == 0 { return }
    
    switch(CInt(err)) {
        
    case kMIDIInvalidClient     :
        print("OSStatus error:  kMIDIInvalidClient")
        
    case kMIDIInvalidPort       :
        print("OSStatus error:  kMIDIInvalidPort")
        
    case kMIDIWrongEndpointType :
        print("OSStatus error:  kMIDIWrongEndpointType")
        
    case kMIDINoConnection      :
        print("OSStatus error:  kMIDINoConnection")
        
    case kMIDIUnknownEndpoint   :
        print("OSStatus error:  kMIDIUnknownEndpoint")
        
    case kMIDIUnknownProperty   :
        print("OSStatus error:  kMIDIUnknownProperty")
        
    case kMIDIWrongPropertyType :
        print("OSStatus error:  kMIDIWrongPropertyType")
        
    case kMIDINoCurrentSetup    :
        print("OSStatus error:  kMIDINoCurrentSetup")
        
    case kMIDIMessageSendErr    :
        print("OSStatus error:  kMIDIMessageSendErr")
        
    case kMIDIServerStartErr    :
        print("OSStatus error:  kMIDIServerStartErr")
        
    case kMIDISetupFormatErr    :
        print("OSStatus error:  kMIDISetupFormatErr")
        
    case kMIDIWrongThread       :
        print("OSStatus error:  kMIDIWrongThread")
        
    case kMIDIObjectNotFound    :
        print("OSStatus error:  kMIDIObjectNotFound")
        
    case kMIDIIDNotUnique       :
        print("OSStatus error:  kMIDIIDNotUnique")

    case kAUGraphErr_NodeNotFound             :
        print("OSStatus error:  kAUGraphErr_NodeNotFound \n")
        
    case kAUGraphErr_OutputNodeErr            :
        print("OSStatus error:  kAUGraphErr_OutputNodeErr \n")
        
    case kAUGraphErr_InvalidConnection        :
        print("OSStatus error:  kAUGraphErr_InvalidConnection \n")
        
    case kAUGraphErr_CannotDoInCurrentContext :
        print("OSStatus error:  kAUGraphErr_CannotDoInCurrentContext \n")
        
    case kAUGraphErr_InvalidAudioUnit         :
        print("OSStatus error:  kAUGraphErr_InvalidAudioUnit \n")
        
    case kAudioToolboxErr_InvalidSequenceType :
        print("OSStatus error:  kAudioToolboxErr_InvalidSequenceType")
        
    case kAudioToolboxErr_TrackIndexError     :
        print("OSStatus error:  kAudioToolboxErr_TrackIndexError")
        
    case kAudioToolboxErr_TrackNotFound       :
        print("OSStatus error:  kAudioToolboxErr_TrackNotFound")
        
    case kAudioToolboxErr_EndOfTrack          :
        print("OSStatus error:  kAudioToolboxErr_EndOfTrack")
        
    case kAudioToolboxErr_StartOfTrack        :
        print("OSStatus error:  kAudioToolboxErr_StartOfTrack")
        
    case kAudioToolboxErr_IllegalTrackDestination :
        print("OSStatus error:  kAudioToolboxErr_IllegalTrackDestination")
        
    case kAudioToolboxErr_NoSequence           :
        print("OSStatus error:  kAudioToolboxErr_NoSequence")
        
    case kAudioToolboxErr_InvalidEventType      :
        print("OSStatus error:  kAudioToolboxErr_InvalidEventType")
        
    case kAudioToolboxErr_InvalidPlayerState  :
        print("OSStatus error:  kAudioToolboxErr_InvalidPlayerState")
        
    case kAudioUnitErr_InvalidProperty          :
        print("OSStatus error:  kAudioUnitErr_InvalidProperty")
        
    case kAudioUnitErr_InvalidParameter          :
        print("OSStatus error:  kAudioUnitErr_InvalidParameter")
        
    case kAudioUnitErr_InvalidElement          :
        print("OSStatus error:  kAudioUnitErr_InvalidElement")
        
    case kAudioUnitErr_NoConnection              :
        print("OSStatus error:  kAudioUnitErr_NoConnection")
        
    case kAudioUnitErr_FailedInitialization      :
        print("OSStatus error:  kAudioUnitErr_FailedInitialization")
        
    case kAudioUnitErr_TooManyFramesToProcess :
        print("OSStatus error:  kAudioUnitErr_TooManyFramesToProcess")
        
    case kAudioUnitErr_InvalidFile              :
        print("OSStatus error:  kAudioUnitErr_InvalidFile")
        
    case kAudioUnitErr_FormatNotSupported      :
        print("OSStatus error:  kAudioUnitErr_FormatNotSupported")
        
    case kAudioUnitErr_Uninitialized          :
        print("OSStatus error:  kAudioUnitErr_Uninitialized")
        
    case kAudioUnitErr_InvalidScope           :
        print("OSStatus error:  kAudioUnitErr_InvalidScope")
        
    case kAudioUnitErr_PropertyNotWritable      :
        print("OSStatus error:  kAudioUnitErr_PropertyNotWritable")
        
    case kAudioUnitErr_InvalidPropertyValue      :
        print("OSStatus error:  kAudioUnitErr_InvalidPropertyValue")
        
    case kAudioUnitErr_PropertyNotInUse          :
        print("OSStatus error:  kAudioUnitErr_PropertyNotInUse")
        
    case kAudioUnitErr_Initialized              :
        print("OSStatus error:  kAudioUnitErr_Initialized")
        
    case kAudioUnitErr_InvalidOfflineRender      :
        print("OSStatus error:  kAudioUnitErr_InvalidOfflineRender")
        
    case kAudioUnitErr_Unauthorized              :
        print("OSStatus error:  kAudioUnitErr_Unauthorized")
        
    default :
        NSLog("OSStatus error:  unrecognized type: %d", err)
    }
}



public func bridge<T : AnyObject>(obj : T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
    // return unsafeAddressOf(obj) // ***
}

public func bridge<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
    // return unsafeBitCast(ptr, T.self) // ***
}

public func bridgeRetained<T : AnyObject>(obj : T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passRetained(obj).toOpaque())
}

public func bridgeTransfer<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
}

func mutableBridge<T : AnyObject>(ptr : UnsafeMutableRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

func mutableBridgeRetained<T : AnyObject>(obj : T) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(Unmanaged.passRetained(obj).toOpaque())
}

func mutableBridgeTransfer<T : AnyObject>(ptr : UnsafeMutableRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
}

