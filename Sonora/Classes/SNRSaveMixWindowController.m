//
//  SNRSaveMixWindowController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-05-03.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRSaveMixWindowController.h"
#import "SNRSaveMixImageView.h"
#import "SNRMix.h"
#import "SNRArtistsViewController.h"

#import "NSManagedObjectContext-SNRAdditions.h"

@implementation SNRSaveMixWindowController {
    NSData *_artworkData;
}
@synthesize nameField = _nameField;
@synthesize songs = _songs;

- (id)init
{
    return [super initWithWindowNibName:NSStringFromClass([self class])];
}

- (id)initWithSongs:(NSArray*)songs
{
    if ((self = [super initWithWindowNibName:NSStringFromClass([self class])])) {
        _songs = songs;
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [[self window] setAnimationBehavior:NSWindowAnimationBehaviorDocumentWindow];
}

#pragma mark - SNRSaveMixImageView delegate

- (void)imageView:(SNRSaveMixImageView*)imageView droppedImageWithData:(NSData*)data
{
    _artworkData = [SNRAlbum artworkDataForImageData:data size:NSZeroSize cropped:NO];
    imageView.image = [[NSImage alloc] initWithData:_artworkData];
}

- (void)imageViewRemovedArtwork:(SNRSaveMixImageView*)imageView
{
    _artworkData = nil;
    imageView.image = nil;
}

#pragma mark - Button Actions

- (IBAction)ok:(id)sender
{
    NSManagedObjectContext *context = SONORA_MANAGED_OBJECT_CONTEXT;
    SNRMix *mix = [context createObjectOfEntityName:kEntityNameMix];
    NSString *name = [self.nameField stringValue];
    mix.name = ([name length] > 0) ? name : NSLocalizedString(@"UntitledMix", nil);
    mix.dateModified = [NSDate date];
    mix.songs = [NSOrderedSet orderedSetWithArray:self.songs];
    if (_artworkData) {
        [mix setArtworkWithData:_artworkData cropped:YES];
    }
    [context saveChanges];
    [[self window] close];
    SNRArtistsStaticNode *node = [[SNRArtistsStaticNode alloc] initWithType:SNRArtistsStaticNodeTypeMixes];
    [SNR_ArtistsViewController selectArtist:node];
}

- (IBAction)cancel:(id)sender
{
    [[self window] close];
}
@end
