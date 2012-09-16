//
//  SNRRestorationManager.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-19.
//

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
