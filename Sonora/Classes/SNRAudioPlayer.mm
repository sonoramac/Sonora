//
//  SNRAudioPlayer.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-18.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRAudioPlayer.h"
#import <SFBAudioEngine/AudioPlayer.h>
#import <SFBAudioEngine/AudioDecoder.h>
#import <SFBAudioEngine/InputSource.h>
#import <AudioUnit/AudioUnit.h>
#import <CoreAudio/CoreAudio.h>

#import "NSUserDefaults-SNRAdditions.h"

@interface SNRAudioPlayer ()
- (void)renderTimerFired:(NSTimer*)timer;
- (void)setOutputDeviceID:(AudioDeviceID)deviceID;
@end

// ========================================
// Player flags
// ========================================
enum {
	ePlayerFlagRenderingStarted			= 1 << 0,
	ePlayerFlagRenderingFinished		= 1 << 1,
    ePlayerFlagDecodingStarted          = 1 << 2,
    ePlayerFlagDecodingFinished         = 1 << 3
};

volatile static uint32_t _playerFlags = 0;

static AudioObjectPropertyAddress sOutputAudioAddress = {
    kAudioHardwarePropertyDefaultSystemOutputDevice,
    kAudioObjectPropertyScopeGlobal,
    kAudioObjectPropertyElementMaster
};

#pragma mark -
#pragma mark Callbacks

static void renderingStarted(void *context, const AudioDecoder *decoder)
{
	OSAtomicTestAndSetBarrier(7 /* ePlayerFlagRenderingStarted */, &_playerFlags);
}

static void renderingFinished(void *context, const AudioDecoder *decoder)
{
	OSAtomicTestAndSetBarrier(6 /* ePlayerFlagRenderingFinished */, &_playerFlags);
}

static void decodingStarted(void *context, const AudioDecoder *decoder)
{
    OSAtomicTestAndSetBarrier(5 /* ePlayerFlagDecodingStarted */, &_playerFlags);
}

static void decodingFinished(void *context, const AudioDecoder *decoder)
{
    OSAtomicTestAndSetBarrier(4 /* ePlayerFlaDecodingFinished */, &_playerFlags);
}

static OSStatus systemOutputDeviceDidChange(AudioObjectID inObjectID, UInt32 inNumberAddresses, const AudioObjectPropertyAddress inAddresses[], void* refcon)
{
    AudioDeviceID currentDevice;
    UInt32 propsize = sizeof(AudioDeviceID);
    OSStatus err = AudioObjectGetPropertyData(kAudioObjectSystemObject, &sOutputAudioAddress, 0, NULL, &propsize, &currentDevice);
    if (err == noErr) {
        SNRAudioPlayer *player = (__bridge SNRAudioPlayer*)refcon;
        [player setOutputDeviceID:currentDevice];
    }
    return err;
}

@implementation SNRAudioPlayer  {
    AudioPlayer *_player;
    NSTimer *_renderTimer;
    AudioUnit _equalizer;
}
@synthesize delegate = _delegate;

#pragma mark -
#pragma mark Initialization

- (id)init
{
    if ((self = [super init])) {
        _player = new AudioPlayer;
        _player->AddEffect(kAudioUnitSubType_GraphicEQ, kAudioUnitManufacturer_Apple, 0, 0, &_equalizer);
        AudioUnitSetParameter(_equalizer, 10000, kAudioUnitScope_Global, 0, 0.0, 0); // 10 band EQ
        AudioObjectAddPropertyListener(kAudioObjectSystemObject, &sOutputAudioAddress, systemOutputDeviceDidChange, (__bridge void*)self);
        AudioDecoder::SetAutomaticallyOpenDecoders(true);
        self.volume = 1.0;
        _renderTimer = [NSTimer timerWithTimeInterval:0.5f target:self selector:@selector(renderTimerFired:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_renderTimer forMode:NSRunLoopCommonModes];
    }
    return self;
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
    [_renderTimer invalidate];
    AudioObjectRemovePropertyListener(kAudioObjectSystemObject, &sOutputAudioAddress, systemOutputDeviceDidChange, (__bridge void*)self);
    AudioUnitUninitialize(_equalizer);
    _equalizer = NULL;
    delete _player; _player = NULL;
}


#pragma mark -
#pragma mark Private

- (void)setOutputDeviceID:(AudioDeviceID)deviceID
{
    _player->SetOutputDeviceID(deviceID);
}

- (void)renderTimerFired:(NSTimer*)timer
{
    if (ePlayerFlagRenderingStarted & _playerFlags) {
		OSAtomicTestAndClearBarrier(7 /* ePlayerFlagRenderingStarted */, &_playerFlags);
		if ([self.delegate respondsToSelector:@selector(audioPlayerStartedPlaying:)]) {
            [self.delegate audioPlayerStartedPlaying:self];
        }
	} else if (ePlayerFlagRenderingFinished & _playerFlags) {
		OSAtomicTestAndClearBarrier(6 /* ePlayerFlagRenderingFinished */, &_playerFlags);
		if ([self.delegate respondsToSelector:@selector(audioPlayerFinishedPlaying:)]) {
            [self.delegate audioPlayerFinishedPlaying:self];
        }
	} else if (ePlayerFlagDecodingStarted & _playerFlags) {
        OSAtomicTestAndClearBarrier(5 /* ePlayerFlagDecodingStarted */, &_playerFlags);
        if ([self.delegate respondsToSelector:@selector(audioPlayerStartedDecoding:)]) {
            [self.delegate audioPlayerStartedDecoding:self];
        }
    } else if (ePlayerFlagDecodingFinished & _playerFlags) {
        OSAtomicTestAndClearBarrier(4 /* ePlayerFlagDecodingFinished */, &_playerFlags);
        if ([self.delegate respondsToSelector:@selector(audioPlayerFinishedDecoding:)]) {
            [self.delegate audioPlayerFinishedDecoding:self];
        }
    }
    if ([self.delegate respondsToSelector:@selector(audioPlayerWantsUIUpdate:)]) {
        [self.delegate audioPlayerWantsUIUpdate:self];
    }
}

#pragma mark -
#pragma mark Playback Controls

- (BOOL)isPlaying
{
    return (BOOL)_player->IsPlaying();
}

- (BOOL)isPaused
{
    return (BOOL)_player->IsPaused();
}

- (BOOL)isStopped
{
    return (BOOL)_player->IsStopped();
}

- (NSURL*)playingURL
{
    return (__bridge NSURL*)_player->GetPlayingURL();
}

- (NSTimeInterval)currentTime
{
    CFTimeInterval time = 0.0;
    _player->GetCurrentTime(time);
    return (NSTimeInterval)time;
}

- (NSTimeInterval)totalTime
{
    CFTimeInterval time = 0.0;
    _player->GetTotalTime(time);
    return (NSTimeInterval)time;
}

- (NSUInteger)currentFrame
{
    SInt64 frame = 0;
    _player->GetCurrentFrame(frame);
    return (NSUInteger)frame;
}

- (NSUInteger)totalFrames
{
    SInt64 frame = 0;
    _player->GetTotalFrames(frame);
    return (NSUInteger)frame;
}

- (BOOL)supportsSeeking
{
    return (BOOL)_player->SupportsSeeking();
}

- (float)volume
{
    Float32 volume = 0.0;
    _player->GetVolume(volume);
    return (float)volume;
}
        
- (void)setVolume:(float)volume
{
    [self willChangeValueForKey:@"volume"];
    _player->SetVolume(volume);
    [self didChangeValueForKey:@"volume"];
}

- (float)preGain
{
    Float32 preGain = 0.0;
    _player->GetPreGain(preGain);
    return (float)preGain;
}

- (void)setPreGain:(float)preGain
{
    [self willChangeValueForKey:@"preGain"];
    _player->SetPreGain(preGain);
    [self didChangeValueForKey:@"preGain"];
}

- (IBAction)play:(id)sender
{
    _player->Play();
}

- (IBAction)playPause:(id)sender
{
	self.isPlaying ? [self pause:nil] : [self play:nil];
}

- (IBAction)pause:(id)sender
{
    _player->Pause();
}

- (IBAction)stop:(id)sender
{
    _player->Stop();
}

- (IBAction)seekForward:(id)sender
{
    _player->SeekForward();
}

- (IBAction)seekBackward:(id)sender
{
    _player->SeekBackward();
}

- (void)seekForwardWithSeconds:(NSTimeInterval)seconds
{
    _player->SeekForward((CFTimeInterval)seconds);
}

- (void)seekBackwardWithSeconds:(NSTimeInterval)seconds
{
    _player->SeekBackward((CFTimeInterval)seconds);
}

- (BOOL)seekToTime:(NSTimeInterval)time
{
    return (BOOL)_player->SeekToTime((CFTimeInterval)time);
}

- (BOOL)enqueueURL:(NSURL*)url
{
    BOOL useMemoryInputSource = [[NSUserDefaults standardUserDefaults] useMemoryInputSource];
    InputSource *inputSource = InputSource::CreateInputSourceForURL((__bridge CFURLRef)url, useMemoryInputSource ? InputSourceFlagLoadFilesInMemory : 0, nullptr);
    if (inputSource == nullptr) {
        return NO;
    }
	AudioDecoder *decoder = AudioDecoder::CreateDecoderForInputSource(inputSource);
	if (decoder == nullptr) { 
        delete inputSource, inputSource = nullptr;
        return NO;
    }
	decoder->SetRenderingStartedCallback(renderingStarted, (__bridge void*)self);
	decoder->SetRenderingFinishedCallback(renderingFinished, (__bridge void*)self);
    decoder->SetDecodingStartedCallback(decodingStarted, (__bridge void*)self);
    decoder->SetDecodingFinishedCallback(decodingFinished, (__bridge void*)self);
	if ((_player->Enqueue(decoder)) == false) {
		delete decoder, decoder = nullptr;
        return NO;
	}
    return YES;
}

- (BOOL)clearEnqueuedTracks
{
    return (BOOL)_player->ClearQueuedDecoders();
}

- (BOOL)skipToNextEnqueuedTrack
{
    return (BOOL)_player->SkipToNextTrack();
}

- (void)setEQValue:(float)value forEQBand:(int)band
{
    AudioUnitSetParameter(_equalizer, band, kAudioUnitScope_Global, 0, (Float32)value, 0);
}
@end
