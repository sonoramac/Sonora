//
//  SNRArtworkImageView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-05-03.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArtworkImageView.h"
#import "SNRBlockMenuItem.h"

@interface SNRArtworkImageView ()
- (void)commonInitForSNRArtworkImageView;
@end

@implementation SNRArtworkImageView
@synthesize delegate = _delegate;
@synthesize image = _image;

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInitForSNRArtworkImageView];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        [self commonInitForSNRArtworkImageView];
    }
    return self;
}

- (void)commonInitForSNRArtworkImageView
{
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, NSTIFFPboardType, nil]];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    [self.image drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.f];
}

#pragma mark - Accessors

- (void)setImage:(NSImage *)image
{
    if (_image != image) {
        _image = image;
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drag and Drop

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    if ([sender draggingSource]) { return NSDragOperationNone; } // this means that the drag started in Sonora
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSData *imageData = [pboard dataForType:NSTIFFPboardType];
    if (imageData) { return NSDragOperationCopy; }
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    NSString *imageFile = [files objectAtIndex:0];
    NSString *extension = [imageFile pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    BOOL conforms = UTTypeConformsTo(fileUTI, kUTTypeImage);
    CFRelease(fileUTI);
    return conforms ? NSDragOperationCopy : NSDragOperationNone;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSData *imageData = [pboard dataForType:NSTIFFPboardType];
    if (!imageData) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        NSString *imageFile = [files objectAtIndex:0];
        imageData = [[NSData alloc] initWithContentsOfFile:imageFile];
    }
    if (imageData && [self.delegate respondsToSelector:@selector(imageView:droppedImageWithData:)]) {
        [self.delegate imageView:self droppedImageWithData:imageData];
    }
    return YES;
}

#pragma mark - NSView Overrides

- (NSMenu *)menuForEvent:(NSEvent *)event
{
    if (!self.image) { return nil; }
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Artwork"];
    __weak SNRArtworkImageView *weakSelf = self;
    SNRBlockMenuItem *remove = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"RemoveArtwork", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
        SNRArtworkImageView *strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(imageViewRemovedArtwork:)]) {
            [strongSelf.delegate imageViewRemovedArtwork:strongSelf];
        }
        strongSelf.image = nil;
    }];
    [menu addItem:remove];
    return menu;
}
@end
