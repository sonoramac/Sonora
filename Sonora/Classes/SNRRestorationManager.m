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

#import "SNRRestorationManager.h"
#import "NSObject+AssociatedObjects.h"

static void* const kSNRRestorationHasRestoredKey = "snr_hasRestored";

@interface SNRRestorationManager ()
// Notifications
- (void)encodeRestorableState;
- (void)decodeRestorableState;
- (void)applicationDidLaunch;

// Restoration
- (void)restoreStateForObject:(id<SNRRestorableState>)object;

// Locations
- (NSString *)restorationStatePath;
@end

@implementation SNRRestorationManager {
    NSMutableSet *_restorableObjects;
    NSMutableDictionary *_hasRestored;
    NSKeyedUnarchiver *_lastUnarchiver;
}
@synthesize restorableObjects = _restorableObjects;
+ (instancetype)sharedManager
{
    static SNRRestorationManager *manager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (id)init
{
    if ((self = [super init])) {
        _restorableObjects = [NSMutableSet set];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(encodeRestorableState) name:NSApplicationDidResignActiveNotification object:nil];
        [nc addObserver:self selector:@selector(encodeRestorableState) name:NSApplicationWillTerminateNotification object:nil];
        [nc addObserver:self selector:@selector(applicationDidLaunch) name:NSApplicationDidFinishLaunchingNotification object:nil];
    }
    return self;
}

- (void)registerRestorationObject:(id<SNRRestorableState>)object
{
    [_restorableObjects addObject:object];
    [self restoreStateForObject:object];
}

- (void)deregisterRestorationObject:(id<SNRRestorableState>)object
{
    [_restorableObjects removeObject:object];
}

- (void)applicationDidLaunch
{
    [self decodeRestorableState];
}

#pragma mark - Notifications

- (void)encodeRestorableState
{
    if (!_lastUnarchiver) { return; }
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    for (id<SNRRestorableState> object in self.restorableObjects) {
        [object encodeRestorableStateWithArchiver:archiver];
    }
    [archiver finishEncoding];
    [data writeToFile:[self restorationStatePath] atomically:YES];
}

- (void)decodeRestorableState
{
    NSData *data = [NSData dataWithContentsOfFile:[self restorationStatePath]];
    if (data) {
        if (_lastUnarchiver) { [_lastUnarchiver finishDecoding]; }
        _lastUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        for (id<SNRRestorableState> object in self.restorableObjects) {
            [self restoreStateForObject:object];
        }
    }
}

- (void)restoreStateForObject:(id<SNRRestorableState>)object
{
    if (_lastUnarchiver && ![[(NSObject*)object associatedValueForKey:kSNRRestorationHasRestoredKey] boolValue]) {
        [object decodeRestorableStateWithArchiver:_lastUnarchiver];
        [(NSObject*)object associateValue:[NSNumber numberWithBool:YES] withKey:kSNRRestorationHasRestoredKey];
    }
}

#pragma mark - Locations

- (NSString *)restorationStatePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *path = [basePath stringByAppendingPathComponent:bundleName];
    return [path stringByAppendingPathComponent:@"state"];
}

- (void)deleteRestorationState
{
    [_lastUnarchiver finishDecoding];
    _lastUnarchiver = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[self restorationStatePath] error:nil];
}
@end
