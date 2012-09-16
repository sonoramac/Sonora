//
//  NSWindow+SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-10-31.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

@interface NSWindow (SNRAdditions)
- (BOOL)isFullscreen;
- (BOOL)drawAsActive;
- (IBAction)fadeIn:(id)sender;
- (IBAction)fadeOut:(id)sender;
- (void)endEditingPreservingFirstResponder:(BOOL)preserve;
@end
