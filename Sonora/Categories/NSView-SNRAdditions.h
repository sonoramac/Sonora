//
//  NSView-SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-09-08.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

typedef enum {
    SNRViewAnimationDirectionLeft,
    SNRViewAnimationDirectionRight
} SNRViewAnimationDirection;

@interface NSView (SNRAdditions)
- (void)scrollPointAnimated:(NSPoint)point;
- (void)scrollPointAnimated:(NSPoint)point completionBlock:(void (^)())block;
@property (readonly) NSImage *NSImage;
- (void)pushToView:(NSView*)view direction:(SNRViewAnimationDirection)direction;
@end
