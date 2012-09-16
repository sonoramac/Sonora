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
