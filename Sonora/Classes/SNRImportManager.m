//
//  SNRImportManager.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-04-29.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRImportManager.h"
#import "SNRQueueCoordinator.h"

#import "NSUserDefaults-SNRAdditions.h"

@interface SNRImportManager ()
- (void)setProgressBarVisible:(BOOL)visible;
@end

@implementation SNRImportManager {
    NSOperationQueue *_importQueue;
}
@synthesize progressBar = _progressBar;

- (id)init
{
    if ((self = [super init])) {
        _importQueue = [NSOperationQueue new];
        [_importQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

+ (SNRImportManager*)sharedImportManager
{
    static SNRImportManager *manager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)performiTunesSync
{
    SNRiTunesImportOperation *operation = [SNRiTunesImportOperation new];
	operation.delegate = self;
	[_importQueue addOperation:operation];
}

- (void)setProgressBarVisible:(BOOL)visible
{
    if (visible) {
        [_progressBar setAlphaValue:0.f];
        [_progressBar setHidden:NO];
        [[_progressBar animator] setAlphaValue:1.f];
    } else {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [_progressBar setHidden:YES];
        }];
        [[_progressBar animator] setAlphaValue:0.f];
        [NSAnimationContext endGrouping];
    }
}

#pragma mark - SNRiTunesImportOperationDelegate

- (void)iTunesImportOperation:(SNRiTunesImportOperation*)operation finishedImporting:(NSUInteger)count
{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self setProgressBarVisible:NO];
    }];
    [_progressBar setDoubleValue:[_progressBar maxValue]];
    [CATransaction commit];
	if ([[NSUserDefaults standardUserDefaults] growlNewImport] && count) {
		NSString *title = [NSString stringWithFormat:NSLocalizedString(@"GrowlImportediTunesTracksTitle", nil), count];
		NSString *description = [NSString stringWithFormat:NSLocalizedString(@"GrowlImportediTunesTracksDescription", nil), count];
		[GrowlApplicationBridge notifyWithTitle:title description:description notificationName:kGrowlNotificationImportediTunesTracks iconData:nil priority:0 isSticky:NO clickContext:@""];
	}
}

- (void)iTunesImportOperation:(SNRiTunesImportOperation*)operation willBeginImporting:(NSUInteger)count
{
    if (count) {
        [_progressBar setDoubleValue:0];
        [_progressBar setMaxValue:count];
        [self setProgressBarVisible:YES];
    }
}

- (void)iTunesImportOperation:(SNRiTunesImportOperation*)operation importedFile:(NSString*)path success:(BOOL)success
{
    [_progressBar incrementBy:1.0];
}

#pragma mark - SNRFileImportOperationDelegate

- (void)importFiles:(NSArray*)files play:(BOOL)play
{
	BOOL import = YES;
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	if ([ud firstImport]) {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"FirstImportTitle", nil) defaultButton:NSLocalizedString(@"FirstImportDefaultButton", nil) alternateButton:NSLocalizedString(@"FirstImportAlternateButton", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"FirstImportMessage", nil)];
		[alert setShowsSuppressionButton:YES];
		NSButton *suppressionButton = [alert suppressionButton];
		[suppressionButton setState:[ud copyMusic]];
		[suppressionButton setTitle:NSLocalizedString(@"FirstImportCheckboxTitle", nil)];
		NSInteger response = [alert runModal];
		if (response == NSAlertDefaultReturn) {
			[ud setCopyMusic:[[alert suppressionButton] state]];
		} else {
			import = NO;
		}
		[ud setFirstImport:NO];
	}
	if (import) { 
		SNRFileImportOperation *operation = [[SNRFileImportOperation alloc] initWithFiles:files];
		operation.delegate = self;
		operation.play = play;
		[_importQueue addOperation:operation];
	}
}

- (void)fileImportOperationDidFinishImport:(SNRFileImportOperation*)operation withObjectIDs:(NSArray*)objectIDs
{
	if (operation.play) {
		NSMutableArray *songs = [NSMutableArray array];
		for (NSManagedObjectID *objectID in objectIDs) {
			SNRSong *song = (SNRSong*)[SONORA_MANAGED_OBJECT_CONTEXT existingObjectWithID:objectID error:nil];
			if (song) { [songs addObject:song]; }
		}
		if ([songs count]) {
            [SNR_MainQueueController playSongs:songs];
		}
	}
	if ([[NSUserDefaults standardUserDefaults] growlNewImport] && [objectIDs count]) {
		NSString *title = [NSString stringWithFormat:NSLocalizedString(@"GrowlImportediTunesTracksTitle", nil), operation.files.count];
		NSString *description = [NSString stringWithFormat:NSLocalizedString(@"GrowlImportedTracksDescription", nil), operation.files.count];
		[GrowlApplicationBridge notifyWithTitle:title description:description notificationName:kGrowlNotificationImportediTunesTracks iconData:nil priority:0 isSticky:NO clickContext:@""];
	}
    [self setProgressBarVisible:NO];
}

- (void)fileImportOperation:(SNRFileImportOperation*)operation importedFileAtPath:(NSString*)path success:(BOOL)success
{
    [_progressBar incrementBy:1.0];
}

- (void)fileImportOperation:(SNRFileImportOperation*)operation willBeginImporting:(NSUInteger)count
{
    if (count) {
        [_progressBar setDoubleValue:0];
        [_progressBar setMaxValue:count];
        [self setProgressBarVisible:YES];
    }
}
@end
