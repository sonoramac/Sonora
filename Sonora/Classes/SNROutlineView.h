//
//  SNROutlineView.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SNROutlineViewDelegate;
@interface SNROutlineView : NSOutlineView
@property (nonatomic, assign) id<SNROutlineViewDelegate> delegate;
@end

@protocol SNROutlineViewDelegate <NSOutlineViewDelegate>
@optional
- (void)outlineView:(NSOutlineView*)outlineView deleteRowsAtIndexes:(NSIndexSet*)indexes;
@end