/*
 *  Copyright (C) 2012 Indragie Karunaratne <i@indragie.com>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    - Neither the name of Indragie Karunaratne nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SNRQueueCoordinator.h"
#import "SNRQueueAnimationContainer.h"
#import "SNRQueueScrollView.h"
#import "SPMediaKeyTap.h"
#import "SNRWindow.h"
#import "SNRVolumeViewController.h"
#import "SNRSaveMixWindowController.h"
#import "SNRBlockMenuItem.h"
#import "SNRLastFMEngine.h"
#import "SNRMix.h"

#import "NSUserDefaults-SNRAdditions.h"
#import "NSObject+SNRAdditions.h"
#import "NSManagedObjectContext-SNRAdditions.h"

#define kQueueCoordinatorEqualizerdBMultiplier 20
#define kQueueCoordinatorMediaKeySeekRepeatMultiplier 0.05f
#define kQueueCoordinatorVolumeButtonIncrement 0.1f
#define kQueueCoordinatorAnimationDuration 0.5f

static NSString* const kImageRepeat = @"repeat-icon";
static NSString* const kImageRepeatAll = @"repeat-all";
static NSString* const kImageRepeatOne = @"repeat-one";

typedef enum {
    SNRQueueCoordinatorMediaButtonNone,
    SNRQueueCoordinatorMediaButtonPlayPause,
    SNRQueueCoordinatorMediaButtonNext,
    SNRQueueCoordinatorMediaButtonPrevious,
    SNRQueueCoordinatorMediaButtonVolumeUp,
    SNRQueueCoordinatorMediaButtonVolumeDown
} SNRQueueCoordinatorMediaButton;

@interface SNRQueueCoordinator ()
- (SNRQueueController *)newQueueController;
- (void)registerForKVONotifications;
- (void)registerForNCNotifications;
+ (void)configureEqualizerForPlayer:(SNRAudioPlayer*)player;

- (void)windowPlayPause:(NSNotification*)notification;
- (void)windowClear:(NSNotification*)notification;
- (void)windowPrevious:(NSNotification*)notification;
- (void)windowNext:(NSNotification*)notification;
- (void)workspaceWillSleep:(NSNotification*)notification;

- (void)handleMediaButton:(SNRQueueCoordinatorMediaButton)button state:(BOOL)state repeated:(BOOL)repeated;
- (void)resetRepeatButtonImage;
@property (nonatomic, assign) SNRQueueControllerRepeatMode repeatMode;
@end

@implementation SNRQueueCoordinator {
    NSMutableArray *_queueControllers;
    SNRQueueController *_mainQueueController;
    SNRQueueController *_mixQueueController;
    NSPoint _savedScrollPosition;

    SPMediaKeyTap *_mediaKeyTap;
    NSUInteger _mediaKeySeekRepeatCount;

    NSPopover *_volumePopover;
    SNRSaveMixWindowController *_saveMixWindowController;
}
@synthesize repeatButton = _repeatButton;
@synthesize queueControllers = _queueControllers;
@synthesize repeatMode = _repeatMode;
@synthesize mainQueueView = _mainQueueView;

// --------------------
// Register the media event handlers
// --------------------

- (id)init
{
    if ((self = [super init])) {
        _queueControllers = [NSMutableArray array];
        _mediaKeyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
        [_mediaKeyTap startWatchingMediaKeys];
        HIDRemote *remote = [HIDRemote sharedHIDRemote];
        [remote setDelegate:self];
        [remote startRemoteControl:kHIDRemoteModeExclusive];
        self.repeatMode = [[NSUserDefaults standardUserDefaults] repeatMode];
        [self registerForKVONotifications];
        [self registerForNCNotifications];
        [self mainQueueController]; // create it
    }
    return self;
}

// --------------------
// Create & configure a new queue controller
// Set it as the active queue controller if there isn't one already
// --------------------

- (SNRQueueController*)newQueueController
{
    SNRQueueController *controller = [SNRQueueController new];
    SNRAudioPlayer *player = [controller audioPlayer];
    [[self class] configureEqualizerForPlayer:player];
    if (!self.activeQueueController) {
        self.activeQueueController = controller;
    }
    [_queueControllers addObject:controller];
    [controller addObserver:self forKeyPath:@"playerState" options:0 context:NULL];
    return controller;
}

// --------------------
// Get the main queue controller, creating it if needed
// --------------------

- (SNRQueueController*)mainQueueController
{
    if (!_mainQueueController) {
        _mainQueueController = [self newQueueController];
        _mainQueueController.identifier = @"SNRMainQueue";
        // The main queue is restorable, so register it with the restoration manager
        [[SNRRestorationManager sharedManager] registerRestorationObject:_mainQueueController];
    }
    return _mainQueueController;
}

// --------------------
// Get the mix queue controller (for mix editing)
// --------------------

- (SNRQueueController*)mixQueueController
{
    if (!_mixQueueController) {
        _mixQueueController = [self newQueueController];
        _mixQueueController.identifier = @"SNRMixQueue";
    }
    return _mixQueueController;
}

// --------------------
// Creates the mix queue controller, loads content, and shows it
// --------------------

- (void)showMixEditingQueueControllerForMix:(SNRMix*)mix
{
    SNRQueueController *mixQueueController = [self mixQueueController];
    if ([mixQueueController representedObject]) { return; }
    [mixQueueController setRepresentedObject:mix];
    [mixQueueController enqueueSongs:[mix.songs array]];
    [self setActiveQueueController:mixQueueController];
}

// --------------------
// Set up the outlets for the active queue controller
// --------------------

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.mainQueueView.delegate = _activeQueueController;
    self.mainQueueView.dataSource = _activeQueueController;
    [_activeQueueController setQueueView:self.mainQueueView];
    [self resetRepeatButtonImage];
}

// --------------------
// Bunch of methods to handle notification registration
// --------------------

- (void)registerForKVONotifications
{
    NSUserDefaultsController *controller = [NSUserDefaultsController sharedUserDefaultsController];
    [controller addObserver:self forKeyPath:@"values.eqBas" options:0 context:NULL];
    [controller addObserver:self forKeyPath:@"values.eqMid" options:0 context:NULL];
    [controller addObserver:self forKeyPath:@"values.eqTre" options:0 context:NULL];
    [controller addObserver:self forKeyPath:@"values.repeatMode" options:0 context:NULL];
}

- (void)registerForNCNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(windowPlayPause:) name:SNRWindowSpaceKeyPressedNotification object:nil];
    [nc addObserver:self selector:@selector(windowClear:) name:SNRWindowEscapeKeyPressedNotification object:nil];
    [nc addObserver:self selector:@selector(windowPrevious:) name:SNRWindowLeftKeyPressedNotification object:nil];
    [nc addObserver:self selector:@selector(windowNext:) name:SNRWindowRightKeyPressedNotification object:nil];
    NSNotificationCenter *wnc = [[NSWorkspace sharedWorkspace] notificationCenter];
    [wnc addObserver:self selector:@selector(workspaceWillSleep:) name:NSWorkspaceWillSleepNotification object:nil];
}

- (void)dealloc
{
    NSUserDefaultsController *controller = [NSUserDefaultsController sharedUserDefaultsController];
    [controller removeObserver:self forKeyPath:@"values.eqBas"];
    [controller removeObserver:self forKeyPath:@"values.eqMid"];
    [controller removeObserver:self forKeyPath:@"values.eqTre"];
    [controller removeObserver:self forKeyPath:@"values.repeatMode"];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// --------------------
// Configures the equalizer for the specified audio player
// using the values from user defaults
// --------------------

+ (void)configureEqualizerForPlayer:(SNRAudioPlayer *)player
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    float bas = [ud floatForKey:@"eqBas"] * kQueueCoordinatorEqualizerdBMultiplier;
    float mid = [ud floatForKey:@"eqMid"] * kQueueCoordinatorEqualizerdBMultiplier;
    float tre = [ud floatForKey:@"eqTre"] * kQueueCoordinatorEqualizerdBMultiplier;
    [player setEQValue:bas forEQBand:0];
    [player setEQValue:bas*(1/2) + mid*(1/8) forEQBand:1];
    [player setEQValue:bas*(1/4) + mid*(1/4) forEQBand:2];
    [player setEQValue:bas*(1/8) + mid*(1/2) forEQBand:3];
    [player setEQValue:mid forEQBand:4];
    [player setEQValue:mid forEQBand:5];
    [player setEQValue:mid*(1/2) + tre*(1/8) forEQBand:6];
    [player setEQValue:mid*(1/4) + tre*(1/4) forEQBand:7];
    [player setEQValue:mid*(1/8) + tre*(1/2) forEQBand:8];
    [player setEQValue:tre forEQBand:9];
}

#pragma mark - Notifications

// --------------------
// Forward the notifications to the active queue controller
// --------------------

- (void)windowPlayPause:(NSNotification*)notification
{
    [self.activeQueueController playPause];
}

- (void)windowClear:(NSNotification*)notification
{
    [self.activeQueueController clearQueueImmediately:NO];
}

- (void)windowPrevious:(NSNotification*)notification
{
    [self.activeQueueController previous];
}

- (void)windowNext:(NSNotification*)notification
{
    [self.activeQueueController next];
}

- (void)workspaceWillSleep:(NSNotification*)notification
{
    [self.activeQueueController pause];
}

#pragma mark - Button Actions

// --------------------
// Change the repeat mode
// --------------------

- (IBAction)repeat:(id)sender
{
    switch (self.repeatMode) {
        case SNRQueueControllerRepeatModeNone:
            self.repeatMode = SNRQueueControllerRepeatModeAll;
            break;
        case SNRQueueControllerRepeatModeAll:
            self.repeatMode = SNRQueueControllerRepeatModeOne;
            break;
        case SNRQueueControllerRepeatModeOne:
            self.repeatMode = SNRQueueControllerRepeatModeNone;
            break;
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] setRepeatMode:self.repeatMode];
}

// --------------------
// Show the volume & EQ popover
// --------------------

- (IBAction)volume:(id)sender
{
    if (_volumePopover) {
        [_volumePopover close];
        _volumePopover = nil;
    } else {
        SNRVolumeViewController *vol = [[SNRVolumeViewController alloc] init];
        _volumePopover = [[NSPopover alloc] init];
        _volumePopover.delegate = self;
        _volumePopover.contentViewController = vol;
        _volumePopover.behavior = NSPopoverBehaviorSemitransient;
        [_volumePopover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
    }
}

// --------------------
// Save the contents of the active queue controller as a mix
// --------------------

- (IBAction)save:(id)sender
{
    _saveMixWindowController = [[SNRSaveMixWindowController alloc] initWithSongs:[self.activeQueueController queue]];
    [[_saveMixWindowController window] setDelegate:self];
    [_saveMixWindowController showWindow:nil];
}

// --------------------
// Clear the active queue controller
// --------------------

- (IBAction)clear:(id)sender
{
    [self.activeQueueController clearQueueImmediately:NO];
}

// --------------------
// Shuffle the active queue controller
// --------------------

- (IBAction)shuffle:(id)sender
{
    [self.activeQueueController shuffle];
}

// --------------------
// Save the mix in the mix queue
// --------------------

- (IBAction)saveMix:(id)sender
{
    SNRMix *mix = [[self mixQueueController] representedObject];
    NSArray *songs = [[self mixQueueController] queue];
    [mix setSongs:[NSOrderedSet orderedSetWithArray:songs]];
    [[mix managedObjectContext] saveChanges];
    [self setActiveQueueController:[self mainQueueController]];
}

// --------------------
// Cancel saving the mix
// --------------------

- (IBAction)cancelMix:(id)sender
{
    [self setActiveQueueController:[self mainQueueController]];
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    _saveMixWindowController = nil;
}

#pragma mark - NSPopoverDelegate


- (void)popoverDidClose:(NSNotification *)notification
{
    _volumePopover = nil;
}

#pragma mark - Accessors

// --------------------
// Show a new active queue controller with animation
// --------------------

- (void)setActiveQueueController:(SNRQueueController *)activeQueueController
{
    if (_activeQueueController != activeQueueController) {
        NSScrollView *currentScrollView = [self.mainQueueView enclosingScrollView];
        NSView *parentView = [currentScrollView superview];
        BOOL showingMainQueue = _activeQueueController == _mainQueueController;
        if (showingMainQueue) {
            _savedScrollPosition = [currentScrollView documentVisibleRect].origin;
        }
        // Show the animation container with a rendering of the view in its current state
        SNRQueueAnimationContainer *container = [[SNRQueueAnimationContainer alloc] initWithFrame:[currentScrollView frame]];
        [container setAnimationView:currentScrollView];
        
        // When we're moving from the main queue to the mix queue, we want the mix queue to slide
        // over the main queue from left to right. The steps for this look like this:
        //
        // 1. Take a snapshot of the view in its current state (showing the main queue)
        // 2. Render that into the bottom layer
        // 3. Place the animation container over the actual view
        // 4. Set the active queue controller to the mix queue
        // 5. Render that state into the top layer
        // 6. Position the top layer to the right of the visible rect and animate left
        
        // Conversely, when moving from the mix queue to the main queue (right to left) the steps look like this:
        //
        // 1. Take a snapshot of the view in its current state (showing the mix queue)
        // 2. Render that into the TOP layer (the top layer is always the one that will be animated)
        // 3. Place the animation container over the view
        // 4. Set the active queue controller to the main queue
        // 5. Render the main queue into the bottom layer
        // 6. Animate the top layer (containing the mix queue) off to the right and off screen
        //
        [parentView addSubview:container positioned:NSWindowAbove relativeTo:currentScrollView];
        [container setDirection:showingMainQueue ? SNRQueueAnimationDirectionLeft : SNRQueueAnimationDirectionRight];
        if (showingMainQueue) {
            [container renderBottomLayer];
        } else {
            [container renderTopLayer];
        }
        
        // Detach the queue view from the current queue controller
        // and set the new queue controller for it to reload the queue view
        [_activeQueueController setQueueView:nil];
        _activeQueueController = activeQueueController;
        [_activeQueueController setLoadArtworkSynchronously:YES];
        [_activeQueueController setQueueView:self.mainQueueView];
        
        // Do the second rendering with the new queue controller
        if (!showingMainQueue) {
            [self.mainQueueView scrollPoint:_savedScrollPosition];
            [container renderBottomLayer];
        } else {
            [container renderTopLayer];
        }
        
        // Perform the animation (moving the top layer)
        [CATransaction begin];
        [CATransaction setAnimationDuration:kQueueCoordinatorAnimationDuration];
        [CATransaction setCompletionBlock:^{
            if (!showingMainQueue) {
                SNRQueueController *controller = [self mixQueueController];
                [controller clearQueueImmediately:YES];
                [controller setRepresentedObject:nil];
            }
            [_activeQueueController setLoadArtworkSynchronously:NO];
            [container removeFromSuperview];
        }];
        [container animate];
        [CATransaction commit];
        
        // Animate the buttons view
        NSView *oldButtonsView = showingMainQueue ? self.mainButtonsContainer : self.mixButtonsContainer;
        NSView *newButtonsView = showingMainQueue ? self.mixButtonsContainer : self.mainButtonsContainer;
        [newButtonsView setAlphaValue:0.f];
        [newButtonsView setFrame:[oldButtonsView frame]];
        [[oldButtonsView superview] addSubview:newButtonsView];
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [oldButtonsView removeFromSuperview];
        }];
        [[NSAnimationContext currentContext] setDuration:kQueueCoordinatorAnimationDuration];
        [[newButtonsView animator] setAlphaValue:1.f];
        [[oldButtonsView animator] setAlphaValue:0.f];
        [NSAnimationContext endGrouping];

    }
}

#pragma mark - SPMediaKeyTapDelegate

- (void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event
{
    int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	int keyState = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	int keyRepeat = (keyFlags & 0x1);
    
    SNRQueueCoordinatorMediaButton button = SNRQueueCoordinatorMediaButtonNone;
    switch (keyCode) {
        case NX_KEYTYPE_PLAY:
            button = SNRQueueCoordinatorMediaButtonPlayPause;
            break;
        case NX_KEYTYPE_FAST:
            button = SNRQueueCoordinatorMediaButtonNext;
            break;
        case NX_KEYTYPE_REWIND:
            button = SNRQueueCoordinatorMediaButtonPrevious;
            break;
    }
    if (button != SNRQueueCoordinatorMediaButtonNone) {
        [self handleMediaButton:button state:keyState repeated:keyRepeat];
    }
}

#pragma mark - HIDRemoteDelegate

- (void)hidRemote:(HIDRemote *)hidRemote eventWithButton:(HIDRemoteButtonCode)buttonCode isPressed:(BOOL)isPressed fromHardwareWithAttributes:(NSMutableDictionary *)attributes
{
    HIDRemoteButtonCode button = buttonCode & kHIDRemoteButtonCodeCodeMask;
    int repeat = buttonCode & kHIDRemoteButtonCodeHoldMask;
    SNRQueueCoordinatorMediaButton mediaButton = SNRQueueCoordinatorMediaButtonNone;
    switch (button) {
        case kHIDRemoteButtonCodeCenter:
        case kHIDRemoteButtonCodePlay:
            mediaButton = SNRQueueCoordinatorMediaButtonPlayPause;
            break;
        case kHIDRemoteButtonCodeUp:
            mediaButton = SNRQueueCoordinatorMediaButtonVolumeUp;
            break;
        case kHIDRemoteButtonCodeDown:
            mediaButton = SNRQueueCoordinatorMediaButtonVolumeDown;
            break;
        case kHIDRemoteButtonCodeLeft:
            mediaButton = SNRQueueCoordinatorMediaButtonPrevious;
            break;
        case kHIDRemoteButtonCodeRight:
            mediaButton = SNRQueueCoordinatorMediaButtonNext;
            break;
        default:
            break;
    }
    if (button != SNRQueueCoordinatorMediaButtonNone) {
        [self handleMediaButton:mediaButton state:isPressed repeated:repeat];
    }
}

#pragma mark - Control Events

- (void)handleMediaButton:(SNRQueueCoordinatorMediaButton)button state:(BOOL)state repeated:(BOOL)repeated
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    switch (button) {
        case SNRQueueCoordinatorMediaButtonPlayPause: {
            if (state) { [self.activeQueueController playPause]; }
            break;
        } case SNRQueueCoordinatorMediaButtonNext: {
            if (!repeated && !state && !_mediaKeySeekRepeatCount) {
                [self.activeQueueController next];
            } else if (!repeated && !state && _mediaKeySeekRepeatCount) {
                _mediaKeySeekRepeatCount = 0;
            } else if (repeated && state) {
                _mediaKeySeekRepeatCount++;
                [self.activeQueueController seekForward:kQueueCoordinatorMediaKeySeekRepeatMultiplier * _mediaKeySeekRepeatCount];
            }
            break;
        } case SNRQueueCoordinatorMediaButtonPrevious: {
            if (!repeated && !state && !_mediaKeySeekRepeatCount) {
                [self.activeQueueController previous];
            } else if (!repeated && !state && _mediaKeySeekRepeatCount) {
                _mediaKeySeekRepeatCount = 0;
            } else if (repeated && state) {
                _mediaKeySeekRepeatCount++;
                [self.activeQueueController seekBackward:kQueueCoordinatorMediaKeySeekRepeatMultiplier * _mediaKeySeekRepeatCount];
            }
            break;
        } case SNRQueueCoordinatorMediaButtonVolumeUp: {
            float volume = ud.volume;
            if (volume < 1.f) {
                ud.volume = MIN(volume + kQueueCoordinatorVolumeButtonIncrement, 1.f);
            }
            break;
        } case SNRQueueCoordinatorMediaButtonVolumeDown: {
            float volume = ud.volume;
            if (volume > 0.f) {
                ud.volume = MAX(volume - kQueueCoordinatorVolumeButtonIncrement, 0.f);
            }
        } default:
            break;
    }
}

#pragma mark - NSMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    __weak SNRQueueCoordinator *weakSelf = self;
    [menu removeAllItems];
    NSMenuItem *repeatContainer = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Repeat", nil) action:nil keyEquivalent:@""];
    NSMenu *repeatMenu = [[NSMenu alloc] initWithTitle:@"Repeat"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    SNRBlockMenuItem *repeatNone = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"RepeatNone", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
        [ud setRepeatMode:SNRQueueControllerRepeatModeNone];
    }];
    repeatNone.state = self.repeatMode == SNRQueueControllerRepeatModeNone;
    [repeatMenu addItem:repeatNone];
    SNRBlockMenuItem *repeatAll = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"RepeatAll", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
        [ud setRepeatMode:SNRQueueControllerRepeatModeAll];
    }];
    repeatAll.state = self.repeatMode == SNRQueueControllerRepeatModeAll;
    [repeatMenu addItem:repeatAll];
    SNRBlockMenuItem *repeatOne = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"RepeatOne", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
        [ud setRepeatMode:SNRQueueControllerRepeatModeOne];
    }];
    repeatOne.state = self.repeatMode == SNRQueueControllerRepeatModeOne;
    [repeatMenu addItem:repeatOne];
    repeatContainer.submenu = repeatMenu;
    [menu addItem:repeatContainer];
    if ([[self.activeQueueController queue] count] > 1) {
        SNRBlockMenuItem *shuffle = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Shuffle", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
            SNRQueueCoordinator *strongSelf = weakSelf;
            [strongSelf.activeQueueController shuffle];
        }];
        [menu addItem:shuffle];
    }
    [menu addItem:[NSMenuItem separatorItem]];
    if ([[SNRLastFMEngine sharedInstance] isAuthenticated]) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        SNRBlockMenuItem *scrobble = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"ScrobbleTracks", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
            [item setState:!(BOOL)[item state]];
            [ud setScrobble:[item state]];
        }];
        [scrobble setState:[ud scrobble]];
        [menu addItem:scrobble];
        if ([self.activeQueueController currentQueueItem]) {
            SNRBlockMenuItem *love = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"LoveTrack", nil) keyEquivalent:@"l" block:^(NSMenuItem *item) {
                SNRQueueCoordinator *strongSelf = weakSelf;
                [[strongSelf.activeQueueController currentQueueItem] lastFMLoveTrack];
            }];
            [menu addItem:love];
        }
        [menu addItem:[NSMenuItem separatorItem]];
    }
    BOOL playing = [self.activeQueueController playerState] == SNRQueueControllerPlayerStatePlaying;
    SNRBlockMenuItem *play = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(playing ? @"Pause" : @"Play", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
        SNRQueueCoordinator *strongSelf = weakSelf;
        [strongSelf.activeQueueController playPause];
    }];
    if (!playing && ![[self.activeQueueController queue] count]) {
        play.target = nil;
        play.action = nil;
    }
    [menu addItem:play];
    SNRBlockMenuItem *previous = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Previous", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
        SNRQueueCoordinator *strongSelf = weakSelf;
        [strongSelf.activeQueueController previous];
    }];
    [menu addItem:previous];
    SNRBlockMenuItem *next = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
        SNRQueueCoordinator *strongSelf = weakSelf;
        [strongSelf.activeQueueController next];
    }];
    [menu addItem:next];
}

#pragma mark - Key Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath hasPrefix:@"values.eq"]) {
        for (SNRQueueController *controller in self.queueControllers) {
            [[self class] configureEqualizerForPlayer:[controller audioPlayer]];
        }
    } else if ([keyPath isEqualToString:@"values.repeatMode"]) {
        self.repeatMode = [[NSUserDefaults standardUserDefaults] repeatMode];
        [self resetRepeatButtonImage];
    } else if ([keyPath isEqualToString:@"playerState"]) {
        SNRQueueController *controller = object;
        if (controller.playerState == SNRQueueControllerPlayerStatePlaying) {
            for (SNRQueueController *c in self.queueControllers) {
                if (c != controller) { [c pause]; }
            }
        }
    }
}

- (void)resetRepeatButtonImage
{
    NSString *imageName = nil;
    switch (self.repeatMode) {
        case SNRQueueControllerRepeatModeAll:
            imageName = kImageRepeatAll;
            break;
        case SNRQueueControllerRepeatModeOne:
            imageName = kImageRepeatOne;
            break;
        default:
            imageName = kImageRepeat;
            break;
    }
    [self.repeatButton setImage:[NSImage imageNamed:imageName]];
}
@end
