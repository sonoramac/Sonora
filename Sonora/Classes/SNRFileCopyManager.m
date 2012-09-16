//
//  SNRFileCopyManager.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-09-19.
//  Copyright 2011 PCWiz Computer. All rights reserved.
//

#import "SNRFileCopyManager.h"

@interface SNRFileCopyManager ()
- (void)queueNextCopyOperation;
- (void)clearCopyInformation;

- (void)delegateFailedCopyForCurrentFile;
- (void)delegateCopiedBytes;
- (void)delegateDidCopyCurrentFile;
- (void)delegateDidFinishCopy;
@end

@interface SNRFileCopyManagerCopy ()
@property (nonatomic, assign, readwrite) unsigned long long size;
@property (nonatomic, assign, readwrite) unsigned long long progress;
@property (nonatomic, weak, readwrite) SNRFileCopyManager *fileCopyManager;
@end

@implementation SNRFileCopyManager {
    NSMutableArray *_queuedCopies;
    FSFileOperationRef _operation;
    unsigned long long _completedFileProgress;
}
@synthesize delegate = _delegate;
@synthesize totalSize = _totalSize;
@synthesize totalProgress = _totalProgress;
@synthesize currentCopy = _currentCopy;
@synthesize representedObject = _representedObject;

#pragma mark - FSFileOperation Callbacks

static void statusCallback (FSFileOperationRef fileOp, const FSRef *currentItem, FSFileOperationStage stage, OSStatus error, CFDictionaryRef statusDictionary,void *info) {
    if (statusDictionary) {
        CFNumberRef bytesCompleted;
        bytesCompleted = (CFNumberRef) CFDictionaryGetValue(statusDictionary, kFSOperationBytesCompleteKey);
        CGFloat floatBytesCompleted;
        CFNumberGetValue (bytesCompleted, kCFNumberMaxType, &floatBytesCompleted);
        unsigned long long bytes = (unsigned long long)floatBytesCompleted;
        SNRFileCopyManager *manager = (__bridge id)info;
        manager.currentCopy.progress = bytes;
        manager->_totalProgress = manager->_completedFileProgress + bytes;
        [manager delegateCopiedBytes];
        if (stage == kFSOperationStageComplete) {
            manager->_completedFileProgress += manager.currentCopy.size;
            manager->_totalProgress = manager->_completedFileProgress;
            [manager delegateDidCopyCurrentFile];
            [manager queueNextCopyOperation];
        }
    }
}

#pragma mark - Initialization

- (id)initWithSourcesAndDestinations:(NSString*)firstSource, ...
{
    if ((self = [super init])) {
        _queuedCopies = [[NSMutableArray alloc] init];
        va_list args;
        va_start(args, firstSource);
        BOOL isDestination = NO;
        SNRFileCopyManagerCopy *copy = nil;
        NSFileManager *fm = [NSFileManager defaultManager];
        for (NSString *arg = firstSource; arg != nil; arg = (__bridge NSString*)va_arg(args, void*)) {
            if (!isDestination) {
                copy = [SNRFileCopyManagerCopy new];
                copy.sourcePath = arg;
                copy.fileCopyManager = self;
                NSNumber *size = nil;
                NSDictionary *sourceAttributes = [fm attributesOfItemAtPath:arg error:nil];
                if ((size = [sourceAttributes valueForKey:NSFileSize])) {
                    copy.size = [size unsignedLongLongValue];
                    _totalSize += copy.size;
                }
            } else {
                copy.destinationPath = arg;
                [_queuedCopies addObject:copy];
                copy = nil;
            }
            isDestination = !isDestination;
        }
        va_end(args);
    }
    return self;
}

- (id)initWithCopies:(NSArray*)copies
{
    if ((self = [super init])) {
        _queuedCopies = [[NSMutableArray alloc] init];
        NSFileManager *fm = [NSFileManager defaultManager];
        for (SNRFileCopyManagerCopy *copy in copies) {
            copy.fileCopyManager = self;
            NSNumber *size = nil;
            NSDictionary *sourceAttributes = [fm attributesOfItemAtPath:copy.sourcePath error:nil];
            if ((size = [sourceAttributes valueForKey:NSFileSize])) {
                copy.size = [size unsignedLongLongValue];
                _totalSize += copy.size;
            }
            [_queuedCopies addObject:copy];
        }
    }
    return self;
}

#pragma mark - Copying

- (void)startCopy
{
    if ([self.delegate respondsToSelector:@selector(fileCopyManagerWillBeginCopy:)]) {
        [self.delegate fileCopyManagerWillBeginCopy:self];
    }
    [self queueNextCopyOperation];
}

- (void)cancelCopy
{
    if (_operation) {
        FSFileOperationCancel(_operation);
        CFRelease(_operation);
        _operation = NULL;
    }
    [_queuedCopies removeAllObjects];
}

#pragma mark - Private

- (void)clearCopyInformation
{
    [_queuedCopies removeObjectIdenticalTo:self.currentCopy];
    _currentCopy = nil;
    if (_operation) {
        CFRelease(_operation);
        _operation = NULL;
    }
}

- (void)delegateFailedCopyForCurrentFile
{
    if ([self.delegate respondsToSelector:@selector(fileCopyManager:failedToCopy:)]) {
        [self.delegate fileCopyManager:self failedToCopy:self.currentCopy];
    }
    [self clearCopyInformation];
    [self queueNextCopyOperation];
}

- (void)delegateCopiedBytes
{
    if ([self.delegate respondsToSelector:@selector(fileCopyManager:copiedBytesOfCopy:)]) {
        [self.delegate fileCopyManager:self copiedBytesOfCopy:self.currentCopy];
    }
}

- (void)delegateDidCopyCurrentFile
{
    if ([self.delegate respondsToSelector:@selector(fileCopyManager:didCopy:)]) {
        [self.delegate fileCopyManager:self didCopy:self.currentCopy];
    }
    [self clearCopyInformation];
}

- (void)delegateDidFinishCopy
{
    [self clearCopyInformation];
    _totalProgress = 0;
    _totalSize = 0;
    if ([self.delegate respondsToSelector:@selector(fileCopyManagerDidFinishCopy:)]) {
        [self.delegate fileCopyManagerDidFinishCopy:self];
    }
}
                 
- (void)queueNextCopyOperation
{
    if (![_queuedCopies count]) { 
        [self delegateDidFinishCopy];
        return; 
    }
    _currentCopy = [_queuedCopies objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (_currentCopy.size) {
        if ([self.delegate respondsToSelector:@selector(fileCopyManager:willCopy:)]) {
            [self.delegate fileCopyManager:self willCopy:self.currentCopy];
        }
    } else {
        [self delegateFailedCopyForCurrentFile];
    }
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    _operation = FSFileOperationCreate(kCFAllocatorDefault);
    OSStatus status = FSFileOperationScheduleWithRunLoop(_operation, runLoop, kCFRunLoopDefaultMode);
    if (status != noErr) {
        [self delegateFailedCopyForCurrentFile];
        return;
    }
    NSDictionary *destAttributes = [fm attributesOfItemAtPath:self.currentCopy.destinationPath error:nil];
    NSString *type = nil;
    if (!(type = [destAttributes valueForKey:NSFileType])) {
        type = NSFileTypeRegular;
    }
    NSString *destDirPath = self.currentCopy.destinationPath;
    NSString *destFileName = nil;
    if (![type isEqualToString:NSFileTypeDirectory]) {
        destFileName = [self.currentCopy.destinationPath lastPathComponent];
        destDirPath = [self.currentCopy.destinationPath stringByDeletingLastPathComponent];
    }
    const char *sourceRep = [self.currentCopy.sourcePath fileSystemRepresentation];
    const char *destRep = [destDirPath fileSystemRepresentation];
    FSRef source;
    FSRef destination;
    FSPathMakeRef((const UInt8*)sourceRep, &source, NULL);
    FSPathMakeRef((const UInt8*)destRep, &destination, NULL);
    FSFileOperationClientContext clientContext = {0};
    clientContext.info = (__bridge void*)self;
    status = FSCopyObjectAsync(_operation, &source, &destination, (__bridge CFStringRef)destFileName, kFSFileOperationOverwrite, statusCallback, 1.0, &clientContext);
    if (status != noErr) {
        [self delegateFailedCopyForCurrentFile];
        return;
    }
}

#pragma mark - Memory Management

- (void)dealloc
{
    if (_operation) {
        CFRelease(_operation);
    }
}
@end

@implementation SNRFileCopyManagerCopy
@synthesize fileCopyManager = _fileCopyManager;
@synthesize sourcePath = _sourcePath;
@synthesize destinationPath = _destinationPath;
@synthesize size = _size;
@synthesize progress = _progress;
@synthesize representedObject = _representedObject;
@end
