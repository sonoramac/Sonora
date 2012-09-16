//
//  SNRAlbumGridViewCell.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-02.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "OEGridViewCell.h"

@protocol SNRAlbumGridViewCellDelegate;
@interface SNRAlbumGridViewCell : OEGridViewCell
@property (nonatomic, copy) NSString *albumName;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, copy) NSString *albumDuration;
@property (nonatomic, retain) id representedObject;
@property (nonatomic, assign) BOOL displayGenericArtwork;
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, assign) id<SNRAlbumGridViewCellDelegate> delegate;
+ (CGFloat)selectionInset;
@end

@protocol SNRAlbumGridViewCellDelegate <NSObject>
- (void)albumGridViewCell:(SNRAlbumGridViewCell*)cell acceptedArtworkImageData:(NSData*)artworkData originalImageData:(NSData*)original;
@end