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
