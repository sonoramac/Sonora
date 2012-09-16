//
//  SNRArtworkImageView.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-05-03.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SNRArtworkImageViewDelegate;
@interface SNRArtworkImageView : NSView
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, assign) IBOutlet id<SNRArtworkImageViewDelegate> delegate;
@end

@protocol SNRArtworkImageViewDelegate <NSObject>
- (void)imageView:(SNRArtworkImageView*)imageView droppedImageWithData:(NSData*)data;
- (void)imageViewRemovedArtwork:(SNRArtworkImageView*)imageView;
@end