//
//  SNRSearchTableCellView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-08.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRSearchTableCellView.h"
#import "SNRShadowImageView.h"

#import "NSShadow-SNRAdditions.h"

#define kArtworkShadowOffset NSMakeSize(0.f, -1.f)
#define kArtworkShadowBlurRadius 3.f
#define kArtworkShadowColor [NSColor colorWithDeviceWhite:0.f alpha:0.75f]
#define kSeparatorColor [NSColor colorWithDeviceWhite:0.90f alpha:1.f]
#define kLayoutPlusButtonWidth 46.f

#define kSelectionBackgroundColor [NSColor colorWithDeviceRed:0.0f green:0.271f blue:0.604f alpha:0.14f]

@implementation SNRSearchTableCellView
@synthesize subtitleTextField = _subtitleTextField;
@synthesize statisticTextField = _statisticTextField;
@synthesize iconImageView = _iconImageView;
@synthesize artworkImageView = _artworkImageView;
@synthesize enqueueButton = _enqueueButton;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Manually configure the artwork view because it's custom
    [self.artworkImageView bind:@"image" toObject:self withKeyPath:@"objectValue.searchArtwork" options:nil];
    self.artworkImageView.shadow = [NSShadow shadowWithOffset:kArtworkShadowOffset blurRadius:kArtworkShadowBlurRadius color:kArtworkShadowColor];
}
@end

@implementation SNRSearchTableRowView

- (BOOL)isEmphasized
{
    return YES;
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    [super drawBackgroundInRect:dirtyRect];
    NSRect separatorRect = NSMakeRect(0.f, NSMaxY([self bounds]) - 1.f, [self bounds].size.width, 1.f);
    [kSeparatorColor set];
    NSRectFill(separatorRect);
    NSRect plusSeparator = NSMakeRect(NSMaxX([self bounds]) - kLayoutPlusButtonWidth, 0.f, 1.f, [self bounds].size.height);
    NSRectFill(plusSeparator);
}

@end

