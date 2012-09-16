//
//  SNRQueueView.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-03-19.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "OEGridViewLayoutManager.h"

extern NSString* const SNRQueueSongsDragIdentifier;

@class OEGridViewCell, OEGridLayer;
@protocol SNRQueueViewDelegate, SNRQueueViewDataSource;
@interface SNRQueueView : NSView <OEGridViewLayoutManagerProtocol, NSDraggingSource, NSDraggingDestination>
#pragma mark -
#pragma mark Query Data Sources

- (CGSize)cellSize;
- (id)dequeueReusableCell;
- (NSUInteger)numberOfItems;
- (OEGridViewCell *)cellForItemAtIndex:(NSUInteger)index makeIfNecessary:(BOOL)necessary;

#pragma mark -
#pragma mark Query Cells

- (NSUInteger)indexForCell:(OEGridViewCell *)cell;
- (NSArray *)visibleCells;
- (NSIndexSet *)indexesForVisibleCells;
- (NSRect)rectForCellAtIndex:(NSUInteger)index;
- (NSUInteger)indexForCellAtPoint:(NSPoint)point;

- (void)reloadData;
- (void)reloadCellsAtIndexes:(NSIndexSet *)indexes;

- (void)scrollToCellAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)scrollToPlayingIndexAnimated:(BOOL)animated;

@property(nonatomic, assign) CGFloat interCellSpacing;
@property(nonatomic, assign) CGFloat verticalContentInset;
@property(nonatomic, retain) CALayer *foregroundLayer;
@property(nonatomic, retain) CALayer *backgroundLayer;
@property(nonatomic, assign) NSUInteger playingIndex;
@property(nonatomic, assign) IBOutlet id<SNRQueueViewDataSource> dataSource;
@property(nonatomic, assign) IBOutlet id<SNRQueueViewDelegate> delegate;
@end

@protocol SNRQueueViewDelegate <NSObject>
- (void)queueView:(SNRQueueView*)queueView clickedItemAtIndex:(NSUInteger)index;
- (void)queueView:(SNRQueueView*)queueView removeItemAtIndex:(NSUInteger)index;
- (void)queueView:(SNRQueueView*)queueView moveItemAtIndex:(NSUInteger)from toIndex:(NSUInteger)to;
- (void)queueView:(SNRQueueView*)queueView insertSongs:(NSArray*)songs atIndex:(NSUInteger)index;
@end

@protocol SNRQueueViewDataSource <NSObject>
- (OEGridViewCell*)queueView:(SNRQueueView*)queueView cellForItemAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfItemsInQueueView:(SNRQueueView*)queueView;
@optional
- (NSView*)viewForNoItemsInQueueView:(SNRQueueView*)queueView;
- (id<NSPasteboardWriting>)queueView:(SNRQueueView*)queueView pasteboardWriterForIndex:(NSInteger)index;
- (NSMenu*)queueView:(SNRQueueView*)queueView menuForItemAtIndex:(NSUInteger)index;
@end
