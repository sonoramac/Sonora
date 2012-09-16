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

#import "SNRQueueView.h"
#import "OEGridLayer.h"
#import "OEGridViewCell.h"
#import "OEGridViewCell+OEGridView.h"
#import "SNRQueueScrollView.h"
#import "SNRQueueReturnLayer.h"

#import "CALayer+SNRAdditions.h"
#import "NSView-SNRAdditions.h"
#import "NSManagedObjectContext-SNRAdditions.h"

const NSTimeInterval SNRInitialPeriodicDelay = 0.4;
const NSTimeInterval SNRPeriodicInterval     = 0.075;

static NSString* const SNRQueueRearrangeDragIdentifier = @"com.iktm.Sonora.queueRearrange";
NSString* const SNRQueueSongsDragIdentifier = @"com.iktm.Sonora.queueSongs";

#define kQueueViewScrollBufferWidth 10.f
#define kQueueViewAnimationDuration 0.2f
#define kQueueViewReturnLayerWidth 60.f
#define kQueueViewShadowWidth 3.f

@interface SNRQueueView ()
- (void)commonQueueViewInit;
- (void)clipViewFrameChanged:(NSNotification*)notification;

- (void)setNeedsLayoutQueueViewAnimated:(BOOL)animated;
- (void)layoutQueueViewAnimated:(BOOL)animated;
- (void)layoutQueueViewIfNeeded;

- (void)enqueueCell:(OEGridViewCell*)cell;
- (void)enqueueCells:(NSSet*)cells;
- (void)enqueueCellsAtIndexes:(NSIndexSet*)indexes;

- (void)calculateCachedValuesAndQueryForDataChanges:(BOOL)query;
- (void)checkForDataReload;
- (void)setNeedsReloadData;
- (void)reloadDataIfNeeded;

- (void)centerNoItemsView;
- (void)reorderSublayers;
- (void)updateDecorativeLayers;

- (NSPoint)pointInViewFromEvent:(NSEvent*)theEvent;
- (NSPoint)pointInViewFromDraggingInfo:(id<NSDraggingInfo>)info;
- (NSPoint)convertPointToRootLayer:(const NSPoint)point;
- (OEGridLayer*)layerForPoint:(const NSPoint)point;
- (OEGridViewCell*)cellForPoint:(const NSPoint)point;

- (NSUInteger)insertionIndexForDraggingInfo:(id<NSDraggingInfo>)info;
@end

@implementation SNRQueueView {
    OEGridLayer *_rootLayer;
    NSView *_noItemsView;
    NSMutableSet *_visibleCells;
    NSMutableIndexSet *_visibleCellsIndexes;
    NSMutableSet *_reuseableCells;
    NSDraggingSession *_draggingSession;
    OEGridLayer *_prevDragDestinationLayer;
    OEGridLayer *_dragDestinationLayer;
    NSDragOperation *_lastDragOperation;
    OEGridLayer *_trackingLayer;
    OEGridLayer *_hoveringLayer;
    NSPoint _initialPoint;
    BOOL _needsReloadData;
    BOOL _needsLayoutQueueView;
    BOOL _needsLayoutQueueViewAnimated;
    BOOL _animatingQueueViewLayout;
    NSUInteger _cachedNumberOfVisibleItems;
    NSUInteger _cachedNumberOfItems;
    NSUInteger _cachedPlayingIndex;
    NSPoint _cachedContentOffset;
    NSSize _cachedViewSize;
    CGSize _cachedCellSize;
    NSTrackingArea *_trackingArea;
    struct
    {
        unsigned int viewForNoItemsInQueueView : 1;
        unsigned int pasteboardWriterForIndex : 1;
        unsigned int menuForItemAtIndex : 1;
    } _dataSourceHas;
    struct
    {
        unsigned int clickedItemAtIndex : 1;
        unsigned int removeItemAtIndex : 1;
        unsigned int moveItemFromIndexToIndex : 1;
        unsigned int insertSongsAtIndex : 1;
    } _delegateHas;
    SNRQueueReturnLayer *_returnLayer;
    CAGradientLayer *_shadowLayer;
    
    id _swipeTouchIdentity;
    NSPoint _swipePosition;
    OEGridViewCell *_swipeCell;
    
    NSUInteger _deletionIndex;
    NSUInteger _insertionIndex;
    NSPoint _draggingPoint;
    NSRect _insertionRect;
    BOOL _draggingEntered;
}
@synthesize backgroundLayer = _backgroundLayer;
@synthesize foregroundLayer = _foregroundLayer;
@synthesize interCellSpacing = _interCellSpacing;
@synthesize verticalContentInset = _verticalContentInset;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize playingIndex = _playingIndex;

- (id)initWithFrame:(NSRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		[self commonQueueViewInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		[self commonQueueViewInit];
	}
	return self;
}

- (void)commonQueueViewInit
{
    _playingIndex         = NSNotFound;
	_verticalContentInset = 5.f;
	_interCellSpacing     = 7.f;
	_visibleCells         = [[NSMutableSet alloc] init];
	_visibleCellsIndexes  = [[NSMutableIndexSet alloc] init];
	_reuseableCells       = [[NSMutableSet alloc] init];
    
    [self registerForDraggedTypes:[NSArray arrayWithObjects:SNRQueueRearrangeDragIdentifier, SNRQueueSongsDragIdentifier, nil]];
    [self setAcceptsTouchEvents:YES];
	[self setWantsLayer:YES];
	[self setLayer:[CALayer layer]];
	[[self layer] setFrame:[self bounds]];
    
     _rootLayer = [OEGridLayer layer];
	[[self layer] addSublayer:_rootLayer];
	[_rootLayer setInteractive:YES];
    if (!SNR_RunningMountainLion) {
        [_rootLayer setGeometryFlipped:YES];
    }
	[_rootLayer setLayoutManager:[OEGridViewLayoutManager layoutManager]];
	[_rootLayer setDelegate:self];
	[_rootLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
	[_rootLayer setFrame:[self bounds]];
    _returnLayer = [SNRQueueReturnLayer layer];
    _shadowLayer = [CAGradientLayer layer];
    CGColorRef black = CGColorCreateGenericGray(0.f, 0.4f);
    CGColorRef clear = CGColorGetConstantColor(kCGColorClear);
    _shadowLayer.colors = [NSArray arrayWithObjects:(__bridge id)clear, (__bridge id)black, nil];
    CGColorRelease(black);
    _shadowLayer.startPoint = CGPointMake(0.f, 0.5f);
    _shadowLayer.endPoint = CGPointMake(1.f, 0.5f);
    _returnLayer.hidden = YES;
    __weak SNRQueueView *weakSelf = self;
    [_returnLayer setMouseUpBlock:^(SNRQueueReturnLayer *layer) {
        SNRQueueView *strongSelf = weakSelf;
        [strongSelf scrollToPlayingIndexAnimated:YES];
    }];
	[self reorderSublayers];
	[self setNeedsReloadData];
}

#pragma mark -
#pragma mark Query Data Sources

- (id)dequeueReusableCell
{
	if([_reuseableCells count] == 0) return nil;
	OEGridViewCell *cell = [_reuseableCells anyObject];
	[_reuseableCells removeObject:cell];
	[cell prepareForReuse];
	return cell;
}

- (NSUInteger)numberOfItems
{
	return _cachedNumberOfItems;
}

- (OEGridViewCell *)cellForItemAtIndex:(NSUInteger)index makeIfNecessary:(BOOL)necessary
{
	__block OEGridViewCell *result = nil;
	if ([_visibleCells count] > 0) {
		[_visibleCells enumerateObjectsUsingBlock:^(OEGridViewCell *obj, BOOL *stop) {
			 if ([self indexForCell:obj] == index) {
				 result = obj;
				 *stop = YES;
			 }
		 }];
	}
	if (!result && necessary)
	{
		result = [_dataSource queueView:self cellForItemAtIndex:index];
		[result OE_setIndex:index];
		[result setFrame:[self rectForCellAtIndex:index]];
		[result layoutIfNeeded];
	}
	return result;
}

#pragma mark -
#pragma mark Query Cells

- (NSUInteger)indexForCell:(OEGridViewCell *)cell
{
	return [cell OE_index];
}

- (NSArray *)visibleCells
{
	return [_visibleCells allObjects];
}

- (NSIndexSet *)indexesForVisibleCells
{
	return [_visibleCellsIndexes copy];
}

- (CGSize)cellSize
{
    CGFloat height = [self bounds].size.height - (_verticalContentInset * 2.f);;
    return CGSizeMake(145.f, height);
}

- (NSRect)rectForCellAtIndex:(NSUInteger)index
{
    NSUInteger insertion = _insertionIndex;
    if (insertion > _deletionIndex) { insertion--; }
    if (index == _deletionIndex) {
        return NSMakeRect(-10.f, -10.f, 0.f, 0.f);
    } else if (_deletionIndex < insertion && _deletionIndex < index && index <= insertion) {
        index--;
    } else if (_deletionIndex > insertion && insertion <= index && index < _deletionIndex) {
        index++;
    }
    CGSize cellSize = [self cellSize];
	return NSMakeRect(_interCellSpacing + (_cachedCellSize.width * index), _verticalContentInset, cellSize.width, cellSize.height);
}

- (void)enqueueCell:(OEGridViewCell *)cell
{
	[_reuseableCells addObject:cell];
	[_visibleCells removeObject:cell];
	[cell removeFromSuperlayer];
}

- (void)enqueueCells:(NSSet *)cells
{
	for (OEGridViewCell *cell in cells)
		[self enqueueCell:cell];
}

- (void)enqueueCellsAtIndexes:(NSIndexSet *)indexes
{
	[indexes enumerateIndexesUsingBlock:
	 ^(NSUInteger idx, BOOL *stop) {
         OEGridViewCell *cell = [self cellForItemAtIndex:idx makeIfNecessary:NO];
		 if (cell) { [self enqueueCell:cell]; }
	 }];
}

- (void)calculateCachedValuesAndQueryForDataChanges:(BOOL)shouldQueryForDataChanges
{
	static BOOL alreadyCalculatingCachedValues = NO;
	if(alreadyCalculatingCachedValues) return;
	alreadyCalculatingCachedValues = YES;
    
	NSScrollView *enclosingScrollView = [self enclosingScrollView];
	NSRect visibleRect = (enclosingScrollView ? [enclosingScrollView documentVisibleRect] : [self bounds]);
	const NSSize cachedContentSize = [self bounds].size;
	const NSSize viewSize = visibleRect.size;
    NSPoint contentOffset = visibleRect.origin;
    
    NSUInteger numberOfVisibleItems = _cachedNumberOfVisibleItems;
    NSUInteger numberOfItems = _cachedNumberOfItems;
    CGSize cellSize = [self cellSize];
    cellSize.width += _interCellSpacing;
    NSSize contentSize = cachedContentSize;
    NSUInteger playingIndex = _playingIndex;
    
    BOOL checkForDataReload = NO;
    
	if (shouldQueryForDataChanges && _dataSource) {
        numberOfItems = [_dataSource numberOfItemsInQueueView:self];
    }
    if (_cachedViewSize.width != viewSize.width || !CGSizeEqualToSize(_cachedCellSize, cellSize)) {
        numberOfVisibleItems = ceil(viewSize.width / cellSize.width) + 2;
        contentSize.height = viewSize.height;
    }
    if (_cachedNumberOfItems != numberOfItems || _cachedNumberOfVisibleItems != numberOfVisibleItems || !CGSizeEqualToSize(_cachedCellSize, cellSize) || !NSEqualSizes(_cachedViewSize, viewSize) || playingIndex != _cachedPlayingIndex) {
        checkForDataReload = YES;
        contentSize.width = MAX(viewSize.width, ceil(numberOfItems * cellSize.width) + _interCellSpacing);
        if (playingIndex != NSNotFound) {
            NSRect rect = [self rectForCellAtIndex:playingIndex];
            NSPoint point = NSMakePoint(floor(rect.origin.x - _interCellSpacing - (cellSize.width/ 3.f)), 0.f);
            CGFloat scrollWidth = point.x + visibleRect.size.width;
            contentSize.width = MAX(contentSize.width, scrollWidth);
        }
        [super setFrameSize:contentSize];
        contentOffset = visibleRect.origin;
        if (_cachedNumberOfVisibleItems != numberOfVisibleItems || !CGSizeEqualToSize(_cachedCellSize, cellSize)) {
            [self setNeedsLayoutQueueViewAnimated:NO];
        }
        _cachedNumberOfVisibleItems   = numberOfVisibleItems;
        _cachedContentOffset          = contentOffset;
        _cachedPlayingIndex           = playingIndex;
        _cachedViewSize               = viewSize;
        _cachedNumberOfItems          = numberOfItems;
        _cachedCellSize               = cellSize;
    }
	alreadyCalculatingCachedValues = NO;
	if(checkForDataReload && _cachedNumberOfItems > 0) [self checkForDataReload];
}

- (void)checkForDataReload
{
	NSScrollView    *enclosingScrollView = [self enclosingScrollView];
	const NSRect     visibleRect         = (enclosingScrollView ? [enclosingScrollView documentVisibleRect] : [self bounds]);
	const NSSize     contentSize         = [self bounds].size;
	const NSSize     viewSize            = visibleRect.size;
	const CGFloat    maxContentOffset    = MAX(contentSize.width - viewSize.width, contentSize.height - _cachedCellSize.width);
	const CGFloat    contentOffsetX      = MAX(MIN(_cachedContentOffset.x, maxContentOffset), 0.0);
	const NSUInteger firstVisibleIndex   = floor(contentOffsetX / _cachedCellSize.width);
	const NSUInteger visibleIndexLength  = MIN(_cachedNumberOfVisibleItems, _cachedNumberOfItems - firstVisibleIndex);
	const NSRange    visibleIndexRange   = NSMakeRange(firstVisibleIndex, visibleIndexLength);

	NSIndexSet *visibleCellsIndexSet = [NSIndexSet indexSetWithIndexesInRange:visibleIndexRange];
	if ([_visibleCellsIndexes isEqualToIndexSet:visibleCellsIndexSet]) return;
	if([_visibleCellsIndexes count] != 0)
	{
		NSMutableIndexSet *removeIndexSet = [_visibleCellsIndexes mutableCopy];
		[removeIndexSet removeIndexes:visibleCellsIndexSet];
        
		if([removeIndexSet count] != 0) [self enqueueCellsAtIndexes:removeIndexSet];
	}
	NSMutableIndexSet *addIndexSet = [visibleCellsIndexSet mutableCopy];
	if([_visibleCellsIndexes count] != 0)
	{
		[addIndexSet removeIndexes:_visibleCellsIndexes];
		[_visibleCellsIndexes removeAllIndexes];
	}
	[_visibleCellsIndexes addIndexes:visibleCellsIndexSet];
	if([addIndexSet count] != 0) [self reloadCellsAtIndexes:addIndexSet];
}

- (void)setNeedsReloadData
{
	_needsReloadData = YES;
	[_rootLayer setNeedsLayout];
}

- (void)reloadDataIfNeeded
{
	if(_needsReloadData) [self reloadData];
}

- (void)reloadData
{
	[_visibleCells makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
	[_visibleCells removeAllObjects];
	[_visibleCellsIndexes removeAllIndexes];
	[_reuseableCells removeAllObjects];
    
	_cachedNumberOfItems          = 0;
    _cachedNumberOfVisibleItems   = 0;
	_cachedContentOffset          = NSZeroPoint;
	_cachedViewSize               = NSZeroSize;
	_cachedCellSize               = CGSizeZero;
    _cachedPlayingIndex           = NSNotFound;
    _deletionIndex                = NSNotFound;
    _insertionIndex               = NSNotFound;
    
	[_noItemsView removeFromSuperview];
	_noItemsView = nil;
    
	[self calculateCachedValuesAndQueryForDataChanges:YES];
	if(_cachedNumberOfItems == 0)
	{
		[self enqueueCells:_visibleCells];
		[_visibleCellsIndexes removeAllIndexes];
		if(_dataSourceHas.viewForNoItemsInQueueView)
		{
			_noItemsView = [_dataSource viewForNoItemsInQueueView:self];
			if(_noItemsView)
			{
				[self addSubview:_noItemsView];
				[_noItemsView setHidden:NO];
				[self centerNoItemsView];
			}
		}
	}
	else if(_noItemsView)
	{
		[_noItemsView removeFromSuperview];
		_noItemsView = nil;
	}
	_needsReloadData = NO;
}

- (void)reloadCellsAtIndexes:(NSIndexSet *)indexes
{
	if([indexes count] == 0) return;
	[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		 if ([_visibleCellsIndexes containsIndex:idx]) {
			 OEGridViewCell *newCell = [_dataSource queueView:self cellForItemAtIndex:idx];
			 OEGridViewCell *oldCell = [self cellForItemAtIndex:idx makeIfNecessary:NO];
			 if (newCell != oldCell) {
				 if (oldCell) [newCell setFrame:[oldCell frame]];
				 if (newCell) {
					 [newCell OE_setIndex:idx];
					 if(oldCell) {
						 [oldCell removeFromSuperlayer];
						 [self enqueueCell:oldCell];
					 }
					 [newCell setOpacity:1.0];
					 [newCell setHidden:NO];
					 if (!oldCell) [newCell setFrame:[self rectForCellAtIndex:idx]];
					 [_visibleCells addObject:newCell];
					 [_rootLayer addSublayer:newCell];
				 }
				 [self setNeedsLayoutQueueViewAnimated:NO];
			 }
		 }
	 }];
	[self reorderSublayers];
}

- (void)scrollToCellAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSRect rect = [self rectForCellAtIndex:index];
    NSPoint point = NSMakePoint(floor(rect.origin.x - _interCellSpacing - (_cachedCellSize.width / 3.f)), 0.f);
    NSClipView *clipView = [[self enclosingScrollView] contentView];
    animated ? [self scrollPointAnimated:point] : [self scrollPoint:[clipView constrainScrollPoint:point]];
}

- (void)scrollToPlayingIndexAnimated:(BOOL)animated
{
    if (_playingIndex != NSNotFound) {
        [self scrollToCellAtIndex:_playingIndex animated:animated];
    }
}
#pragma mark -
#pragma mark View Operations

- (BOOL)isFlipped
{
	return YES;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    [self updateTrackingAreas];
}


- (void)viewWillMoveToSuperview:(NSView *)newSuperview
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	NSClipView           *newClipView        = ([newSuperview isKindOfClass:[NSClipView class]] ? (NSClipView *)newSuperview : nil);
	NSClipView           *oldClipView        = [[self enclosingScrollView] contentView];
    
	if (oldClipView) {
		[notificationCenter removeObserver:self name:NSViewBoundsDidChangeNotification object:oldClipView];
		[notificationCenter removeObserver:self name:NSViewFrameDidChangeNotification object:oldClipView];
	}
    if (newClipView) {
		[self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
		[notificationCenter addObserver:self selector:@selector(clipViewFrameChanged:) name:NSViewBoundsDidChangeNotification object:newClipView];
		[notificationCenter addObserver:self selector:@selector(clipViewFrameChanged:) name:NSViewFrameDidChangeNotification object:newClipView];
		[newClipView setPostsBoundsChangedNotifications:YES];
		[newClipView setPostsFrameChangedNotifications:YES];
	}
}

- (void)clipViewFrameChanged:(NSNotification *)notification
{
	NSScrollView *enclosingScrollView = [self enclosingScrollView];
	if (_noItemsView) {
		[self setFrame:[enclosingScrollView bounds]];
		[self centerNoItemsView];
	} else {
		const NSRect visibleRect = (enclosingScrollView ? [enclosingScrollView documentVisibleRect] : [self bounds]);
		if (!NSEqualSizes(_cachedViewSize, visibleRect.size)) {
			[self calculateCachedValuesAndQueryForDataChanges:NO];
		} else if(!NSEqualPoints(_cachedContentOffset, visibleRect.origin)) {
			_cachedContentOffset = visibleRect.origin;
			[self checkForDataReload];
		}
		[self updateDecorativeLayers];
	}
}

- (void)centerNoItemsView
{
	if(!_noItemsView) return;
	NSView       *enclosingScrollView = [self enclosingScrollView] ? : self;
	const NSRect  visibleRect         = [enclosingScrollView visibleRect];
	const NSSize  viewSize            = [_noItemsView frame].size;
	const NSRect  viewFrame           = NSMakeRect(ceil((NSWidth(visibleRect) - viewSize.width) / 2.0),
												   ceil((NSHeight(visibleRect) - viewSize.height) / 2.0),
												   viewSize.width, viewSize.height);
	[_noItemsView setFrame:viewFrame];
}

#pragma mark - CALayer Delegate

- (BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale
   fromWindow:(NSWindow *)window
{
    return YES;
}

#pragma mark -
#pragma mark Layer Operations

- (id)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
	return [NSNull null];
}

- (void)reorderSublayers
{
	[_rootLayer insertSublayer:_backgroundLayer atIndex:0];
	unsigned int index = (unsigned int)[[_rootLayer sublayers] count];
	[_rootLayer insertSublayer:_foregroundLayer atIndex:index];
    [_rootLayer insertSublayer:_shadowLayer above:_foregroundLayer];
    [_rootLayer insertSublayer:_returnLayer above:_shadowLayer];
}

- (void)updateDecorativeLayers
{
	NSScrollView *enclosingScrollView   = [self enclosingScrollView];
	const NSRect visibleRect            = (enclosingScrollView ? [enclosingScrollView documentVisibleRect] : [self bounds]);
	const NSRect decorativeFrame        = NSIntegralRect(NSOffsetRect((enclosingScrollView ? [enclosingScrollView frame] : visibleRect), NSMinX(visibleRect), NSMinY(visibleRect)));
    const NSRect shadowFrame            = NSMakeRect(NSMaxX(visibleRect) - kQueueViewShadowWidth, visibleRect.origin.y, kQueueViewShadowWidth, visibleRect.size.height);
    if (_playingIndex != NSNotFound && _playingIndex != _deletionIndex) {
        const NSRect playingRect        = [self rectForCellAtIndex:_playingIndex];
        if (!NSContainsRect(visibleRect, playingRect)) {
            BOOL right =  NSMaxX(visibleRect) < NSMaxX(playingRect);
            _returnLayer.showRightArrow = right;
            const NSRect returnFrame    = NSMakeRect(right ? NSMaxX(visibleRect) - kQueueViewReturnLayerWidth : visibleRect.origin.x, visibleRect.origin.y, kQueueViewReturnLayerWidth, visibleRect.size.height);
            [_returnLayer setFrame:returnFrame];
            _returnLayer.opacity = MAX(MIN(((right ? (NSMidX(playingRect) - NSMaxX(returnFrame)) : (returnFrame.origin.x - NSMidX(playingRect))) / (playingRect.size.width / 2.f)), 1.0), 0.0);
            
            _returnLayer.hidden = NO;
        } else {
            _returnLayer.hidden = YES;
        }
    } else {
        _returnLayer.hidden = YES;
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
	[_backgroundLayer setFrame:decorativeFrame];
	[_foregroundLayer setFrame:decorativeFrame];
    [_shadowLayer setFrame:shadowFrame];
    [CATransaction commit];
}

- (void)setNeedsLayoutQueueViewAnimated:(BOOL)animated
{
	_needsLayoutQueueView = YES;
    _needsLayoutQueueViewAnimated = animated;
	[_rootLayer setNeedsLayout];
}

- (void)layoutQueueViewIfNeeded
{
	if(_needsLayoutQueueView) [self layoutQueueViewAnimated:_needsLayoutQueueViewAnimated];
}

- (void)layoutQueueViewAnimated:(BOOL)animated
{
	if([_visibleCells count] == 0 || _animatingQueueViewLayout) return;
    CAMediaTimingFunction *function = nil;
    if (animated) {
        function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _animatingQueueViewLayout = YES;
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            _animatingQueueViewLayout = NO;
        }];
    }
	[_visibleCells enumerateObjectsUsingBlock:
	 ^(id obj, BOOL *stop) {
         NSUInteger index = [self indexForCell:obj];
         NSRect frame = [self rectForCellAtIndex:index];
         if (animated) {
             [obj animateFromFrame:[obj frame] toFrame:frame duration:kQueueViewAnimationDuration timingFunction:function];
         }
		 [obj setFrame:frame];
	 }];
    if (animated) {
        [CATransaction commit];
    }
	_needsLayoutQueueView = NO;
    _needsLayoutQueueViewAnimated = NO;
}

- (void)layoutSublayers
{
	[self reloadDataIfNeeded];
	[self updateDecorativeLayers];
	[self layoutQueueViewIfNeeded];
}

#pragma mark -
#pragma mark Responder Chain

- (BOOL)acceptsFirstResponder
{
	return YES;
}

#pragma mark - Tracking Areas

- (void)updateTrackingAreas
{
	[super updateTrackingAreas];
	if (_trackingArea) { [self removeTrackingArea:_trackingArea]; }
	NSTrackingAreaOptions options = (NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow);
	_trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:options owner:self userInfo:nil];
	[self addTrackingArea:_trackingArea];
}

#pragma mark -
#pragma mark Mouse Handling Operations

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (NSPoint)pointInViewFromEvent:(NSEvent *)theEvent
{
	return [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

- (NSPoint)pointInViewFromDraggingInfo:(id<NSDraggingInfo>)info
{
    return [self convertPoint:[info draggingLocation] fromView:nil];
}

- (NSPoint)convertPointToRootLayer:(const NSPoint)point
{
	NSPoint result = point;
	if([self isFlipped]) result.y = CGRectGetMaxY([_rootLayer frame]) - result.y - 1.0;
	return result;
}

- (OEGridLayer *)layerForPoint:(const NSPoint)point
{
    NSEnumerator *reverseEnumerator = [[_rootLayer sublayers] reverseObjectEnumerator];
	for(OEGridLayer *obj in reverseEnumerator){
		if(![obj isKindOfClass:[OEGridLayer class]]) continue;
		OEGridLayer *hitLayer = (OEGridLayer *)[obj hitTest:point];
		if([hitLayer isKindOfClass:[OEGridLayer class]]) return hitLayer;
	}
	return nil;
}

- (OEGridViewCell*)cellForPoint:(const NSPoint)point
{
    OEGridLayer *layer = [self layerForPoint:point];
    while (layer && ![layer isKindOfClass:[OEGridViewCell class]]) {
        layer = (OEGridLayer*)[layer superlayer];
    }
    if ([layer isKindOfClass:[OEGridViewCell class]]) {
        return (OEGridViewCell*)layer;
    }
    return nil;
}

- (NSUInteger)indexForCellAtPoint:(NSPoint)point
{
    OEGridViewCell *cell = [self cellForPoint:point];
    if (cell) { return [self indexForCell:cell]; }
    return NSNotFound;
}

- (NSMenu*)menuForEvent:(NSEvent *)event
{
	[[self window] makeFirstResponder:self];
	NSPoint mouseLocationInWindow = [event locationInWindow];
	NSPoint mouseLocationInView = [self convertPoint:mouseLocationInWindow fromView:nil];
	NSUInteger index = [self indexForCellAtPoint:mouseLocationInView];
	if (index != NSNotFound && _dataSourceHas.menuForItemAtIndex)
	{
		return [[self dataSource] queueView:self menuForItemAtIndex:index];
	}
	return [self menu];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    const NSPoint pointInView = [self pointInViewFromEvent:theEvent];
    OEGridLayer *newLayer = [self layerForPoint:pointInView];
    while (newLayer && ![newLayer receivesHoverEvents]) {
        newLayer = (OEGridLayer*)[newLayer superlayer];
        if (![newLayer isKindOfClass:[OEGridLayer class]]) {
            newLayer = nil;
        }
    }
    OEGridLayer *oldLayer = _hoveringLayer;
    _hoveringLayer = newLayer;
    const NSPoint pointInLayer = [_rootLayer convertPoint:pointInView toLayer:_hoveringLayer];
    if (oldLayer != _hoveringLayer) {
        [oldLayer mouseExitedAtPointInLayer:pointInLayer withEvent:theEvent];
        [_hoveringLayer mouseEnteredAtPointInLayer:pointInLayer withEvent:theEvent];
    } else {
        [_hoveringLayer mouseMovedAtPointInLayer:pointInLayer withEvent:theEvent];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    if (_hoveringLayer) {
        const NSPoint pointInView = [self pointInViewFromEvent:theEvent];
        const NSPoint pointInLayer = [_rootLayer convertPoint:pointInView toLayer:_hoveringLayer];
        [_hoveringLayer mouseExitedAtPointInLayer:pointInLayer withEvent:theEvent];
        _hoveringLayer = nil;
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
	const NSPoint pointInView = [self pointInViewFromEvent:theEvent];
	_trackingLayer            = [self layerForPoint:pointInView];
	if (![_trackingLayer isInteractive]) {
        if (_trackingLayer && _trackingLayer != _rootLayer) {
            _trackingLayer = [self cellForPoint:pointInView];
        } else {
            _trackingLayer = _rootLayer;
        }
    }
	OEGridViewCell *cell = nil;
	if ([_trackingLayer isKindOfClass:[OEGridViewCell class]]) {
		cell = (OEGridViewCell *)_trackingLayer;
        cell.highlighted = YES;
    }
	if (cell == nil && _trackingLayer != nil && _trackingLayer != _rootLayer) {
		const NSPoint pointInLayer = [_rootLayer convertPoint:pointInView toLayer:_trackingLayer];
		[_trackingLayer mouseDownAtPointInLayer:pointInLayer withEvent:theEvent];
		if(![_trackingLayer isTracking]) _trackingLayer = nil;
	}
    NSEvent *lastMouseDragEvent = nil;
	BOOL periodicEvents = (_trackingLayer == _rootLayer);
    
	_initialPoint = pointInView;
	if (periodicEvents) {
        [NSEvent startPeriodicEventsAfterDelay:SNRInitialPeriodicDelay withPeriod:SNRPeriodicInterval];
    }
	const NSUInteger mask = NSLeftMouseUpMask | NSLeftMouseDraggedMask | NSKeyDownMask | (periodicEvents ? NSPeriodicMask : 0);
	while (_trackingLayer && (theEvent = [[self window] nextEventMatchingMask:mask])) {
		if (periodicEvents && [theEvent type] == NSPeriodic) {
			if (lastMouseDragEvent) {
				[self mouseDragged:lastMouseDragEvent];
				const NSPoint point = [self convertPoint:[lastMouseDragEvent locationInWindow] fromView:nil];
				if(!NSPointInRect(point, [self bounds])) lastMouseDragEvent = nil;
			}
		} else if ([theEvent type] == NSLeftMouseDragged) {
			const NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
			lastMouseDragEvent  = (NSPointInRect(point, [self visibleRect]) ? nil : theEvent);
			[self mouseDragged:theEvent];
		} else if ([theEvent type] == NSLeftMouseUp) {
			[self mouseUp:theEvent];
			break;
		} else if([theEvent type] == NSKeyDown) {
			NSBeep();
		}
	}
	lastMouseDragEvent = nil;
	_trackingLayer     = nil;
    if (periodicEvents) [NSEvent stopPeriodicEvents];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if (_trackingLayer == nil) return;
	const NSPoint pointInView = [self pointInViewFromEvent:theEvent];
	if ([_trackingLayer isKindOfClass:[OEGridViewCell class]]) {
		if (_dataSourceHas.pasteboardWriterForIndex) {
			NSUInteger index = [self indexForCellAtPoint:pointInView];
            if (index != NSNotFound) {
                id<NSPasteboardWriting> item = [_dataSource queueView:self pasteboardWriterForIndex:index];
                if (item) {
                    NSDraggingItem *dragItem = [[NSDraggingItem alloc] initWithPasteboardWriter:item];
                    OEGridViewCell *cell = [self cellForItemAtIndex:index makeIfNecessary:YES];
                    [dragItem setDraggingFrame:NSOffsetRect([cell hitRect], NSMinX([cell frame]), NSMinY([cell frame])) contents:[cell draggingImage]];
                    _draggingSession = [self beginDraggingSessionWithItems:[NSArray arrayWithObject:dragItem] event:theEvent source:self];
                    [_draggingSession.draggingPasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:[NSNumber numberWithUnsignedInteger:index]] forType:SNRQueueRearrangeDragIdentifier];
                    _draggingSession.animatesToStartingPositionsOnCancelOrFail = NO;
                    [_draggingSession setDraggingFormation:NSDraggingFormationStack];
                    _deletionIndex = index;
                    _insertionIndex = index;
                    [self setNeedsLayoutQueueViewAnimated:NO];
                }
            }
            [(OEGridViewCell*)_trackingLayer setHighlighted:NO];
            _trackingLayer = nil;
		} else {
            [(OEGridViewCell*)_trackingLayer setHighlighted:NO];
			_trackingLayer = nil;
		}
	} else if(_trackingLayer != _rootLayer) {
		const NSPoint pointInLayer = [_rootLayer convertPoint:pointInView toLayer:_trackingLayer];
		[_trackingLayer mouseDraggedAtPointInLayer:pointInLayer withEvent:theEvent];
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if (_trackingLayer == nil) return;
	const NSPoint pointInView = [self pointInViewFromEvent:theEvent];
	if ([_trackingLayer isKindOfClass:[OEGridViewCell class]]) {
        [(OEGridViewCell*)_trackingLayer setHighlighted:NO];
		if(_delegateHas.clickedItemAtIndex) {
			OEGridViewCell *cell = (OEGridViewCell *)[self layerForPoint:pointInView];
			if ([cell isKindOfClass:[OEGridViewCell class]])
				[_delegate queueView:self clickedItemAtIndex:[self indexForCell:cell]];
		}
	} else if(_trackingLayer != _rootLayer) {
		const NSPoint pointInLayer = [_rootLayer convertPoint:pointInView toLayer:_trackingLayer];
		[_trackingLayer mouseUpAtPointInLayer:pointInLayer withEvent:theEvent];
	}
    _trackingLayer = nil;
}

#pragma mark - 
#pragma mark Gestures

- (void)touchesBeganWithEvent:(NSEvent *)event
{
    if (_deletionIndex != NSNotFound) { return; } // swipe is already in progress
    const NSPoint pointInView = [self pointInViewFromEvent:event];
    OEGridViewCell *layer     = [self cellForPoint:pointInView];
    if (layer && _playingIndex != [self indexForCell:(OEGridViewCell*)layer]) {
        NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self];
        // Track only two finger gestures
        if ([touches count] == 2) {
            // Cache the touch identity and cell for access in the other touch responder methods
            NSTouch *touch = [touches anyObject];
            _swipeTouchIdentity = touch.identity;
            _swipeCell = (OEGridViewCell*)layer;
            _swipePosition = touch.normalizedPosition;
        }
    }
}

- (void)touchesMovedWithEvent:(NSEvent *)event
{
    if (!_swipeCell || !_swipeTouchIdentity) { return; }
    const NSRect swipeCellRect = [self rectForCellAtIndex:[self indexForCell:_swipeCell]];
    NSRect swipeHitRect = swipeCellRect;
    swipeHitRect.origin.y = 0.f;
    swipeHitRect.size.height = [self bounds].size.height;
    const NSPoint pointInView = [self pointInViewFromEvent:event];
    // If the touch has moved to a different cell, then end the gesture
    if (!NSPointInRect(pointInView, swipeCellRect)) { 
        [self touchesEndedWithEvent:event];
        return;
    }
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseMoved inView:self];
    if ([touches count]) {
        NSTouch *trackingTouch = nil;
        // Attempt to locate the same touch that the gesture originated with
        for (NSTouch *touch in touches) {
            if ([touch.identity isEqual:_swipeTouchIdentity]) {
                trackingTouch = touch;
                break;
            }
        }
        if (trackingTouch) {
            CGFloat deltaX = trackingTouch.normalizedPosition.x - _swipePosition.x;
            CGFloat deltaY = trackingTouch.normalizedPosition.y - _swipePosition.y;
            CGFloat angle = fabs(atan(deltaY / deltaX));
            BOOL validDelta = angle > 1.0; // approx 57 degrees
            SNRQueueScrollView *scrollView = (SNRQueueScrollView*)[self enclosingScrollView];
            scrollView.blockScrollEvents = validDelta || !CGRectEqualToRect(_swipeCell.frame, swipeCellRect);
            if (validDelta) {
                _swipePosition = trackingTouch.normalizedPosition;
                CGRect newSwipeFrame = _swipeCell.frame;
                newSwipeFrame.origin.y -= newSwipeFrame.size.height * deltaY * 3.f;
                newSwipeFrame.origin.y = MIN(swipeCellRect.origin.y, newSwipeFrame.origin.y);
                _swipeCell.frame = newSwipeFrame;
            }
        }
    }
}

- (void)touchesEndedWithEvent:(NSEvent *)event
{
    SNRQueueScrollView *scrollView = (SNRQueueScrollView*)[self enclosingScrollView];
    if (_swipeCell) {
        NSUInteger cellIndex = [self indexForCell:_swipeCell];
        NSRect originalFrame = [self rectForCellAtIndex:cellIndex];
        BOOL removedCell = NO;
        // If the cell has moved up more than 1/3 of the way off screen, this constitutes a removal
        if ((originalFrame.origin.y - [_swipeCell frame].origin.y) > (originalFrame.size.height / 3.f)) {
            // Move the cell off screen
            originalFrame.origin.y = -originalFrame.size.height * 2.f;
            removedCell = YES;
        }
        [CATransaction begin];
        if (removedCell) {
            [CATransaction setCompletionBlock:^{
                // If the cell has been removed, layout the queue view
                // temporarily to remove the cell and then remove it from the playback controller
                _deletionIndex = cellIndex;
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    _deletionIndex = NSNotFound;
                    scrollView.blockScrollEvents = NO;
                    if (_delegateHas.removeItemAtIndex) {
                        [self.delegate queueView:self removeItemAtIndex:cellIndex];
                    }
                }];
                [self setNeedsLayoutQueueViewAnimated:YES];
                [CATransaction commit];
            }];
        } else {
            scrollView.blockScrollEvents = NO;
        }
        // Animate and change the frame of the cell
        [_swipeCell animateFromFrame:[_swipeCell frame] toFrame:originalFrame duration:kQueueViewAnimationDuration timingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [_swipeCell setFrame:originalFrame];
        [CATransaction commit];
        // Reset all the variables
        _swipeCell = nil;
        _swipeTouchIdentity = nil;
        _swipePosition = NSZeroPoint;
    } else {
        scrollView.blockScrollEvents = NO;
    }
}

- (void)touchesCancelledWithEvent:(NSEvent *)event
{
    [self touchesEndedWithEvent:event];
}

#pragma mark -
#pragma mark NSDraggingDestination

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    _draggingEntered = YES;
    [NSCursor pop]; // Show original cursor
    return [self draggingUpdated:sender];
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    // Don't update the insertion index if layout is already in progress
    if (!_animatingQueueViewLayout) {
        NSUInteger insertion = [self insertionIndexForDraggingInfo:sender];
        // If the insertion index has changed, layout the view again
        if (_insertionIndex != insertion) {
            _insertionIndex = insertion;
            [self setNeedsLayoutQueueViewAnimated:YES];
        }
    }
    // If the drag originated inside the view (rearrange operation) return move
    return (_deletionIndex != NSNotFound) ? NSDragOperationMove : NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    _draggingEntered = NO;
    // Show the poof cursor once the mouse has exited view bounds
    [[NSCursor disappearingItemCursor] push];
    // Layout the queue view and remove the insertion space
    if (_insertionIndex != NSNotFound) {
        _insertionIndex = NSNotFound;
        [self setNeedsLayoutQueueViewAnimated:YES];
    }
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
    // Show the original cursor
    [NSCursor pop];
    // If there is no deletion or insertion index then there's nothing to do
    if (_deletionIndex == NSNotFound && _insertionIndex == NSNotFound) { return; }
    // Check if the item should be removed depending on whether the drag ended outside the view
    BOOL removeItem = !_draggingEntered && _delegateHas.removeItemAtIndex && _deletionIndex != NSNotFound;
    if (removeItem) {
        // Show the poof animation
        NSShowAnimationEffect(NSAnimationEffectPoof, [NSEvent mouseLocation], NSZeroSize, NULL, NULL, NULL);
    }
    if (removeItem) {
        [self.delegate queueView:self removeItemAtIndex:_deletionIndex];
    }
    _deletionIndex = NSNotFound;
    _insertionIndex = NSNotFound;
    [self setNeedsLayoutQueueViewAnimated:NO];
}

- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender
{
    if (_deletionIndex != NSNotFound) { // Rearranging
        // Only proceed if the insertion index is valid
        return _insertionIndex != NSNotFound && _insertionIndex != _deletionIndex && _delegateHas.moveItemFromIndexToIndex;
    } else {
        return _insertionIndex != NSNotFound && _delegateHas.insertSongsAtIndex;
    }
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    if (_deletionIndex != NSNotFound) { // Rearrange
        CGSize cellSize = [self cellSize];
        NSRect frame = NSMakeRect(_interCellSpacing + (_cachedCellSize.width * ((_insertionIndex > _deletionIndex) ? _insertionIndex - 1 : _insertionIndex)), _verticalContentInset, cellSize.width, cellSize.height);
        [[self cellForItemAtIndex:_deletionIndex makeIfNecessary:NO] setFrame:frame];
        [sender enumerateDraggingItemsWithOptions:0 forView:self classes:[NSArray arrayWithObject:[NSPasteboardItem class]] searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
            [draggingItem setDraggingFrame:frame];
        }];
    }
    return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
    if (_deletionIndex != NSNotFound) {
        if (_deletionIndex != _insertionIndex) {
            [self.delegate queueView:self moveItemAtIndex:_deletionIndex toIndex:_insertionIndex];
        }
    } else {
        NSMutableArray *URIs = [NSMutableArray array];
        [sender enumerateDraggingItemsWithOptions:NSDraggingItemEnumerationClearNonenumeratedImages forView:self classes:[NSArray arrayWithObject:[NSPasteboardItem class]] searchOptions:nil usingBlock:^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
            NSData *data = [[draggingItem item] dataForType:SNRQueueSongsDragIdentifier];
            if (data) {
                NSArray *URIArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [URIs addObjectsFromArray:URIArray];
            }
        }];
        NSArray *songs = [SONORA_MANAGED_OBJECT_CONTEXT objectsWithURLs:URIs];
        [self.delegate queueView:self insertSongs:songs atIndex:_insertionIndex];
    }
}

- (NSUInteger)insertionIndexForDraggingInfo:(id<NSDraggingInfo>)info
{
    if (!_cachedNumberOfItems) { return 0; }
    NSPoint point = [self pointInViewFromDraggingInfo:info];
    point.y = NSMidY([self bounds]);
    OEGridViewCell *cell = [self cellForPoint:point];
    if (cell) {
        NSUInteger index = [self indexForCell:cell];
        if (point.x > _draggingPoint.x) { index++; }
        _draggingPoint = point;
        return index;
    } else {
        _draggingPoint = point;
        NSRect firstCellRect = [self rectForCellAtIndex:0];
        NSRect lastCellRect = [self rectForCellAtIndex:_cachedNumberOfItems - 1];
        if (_draggingPoint.x < NSMidX(firstCellRect)) {
            return 0;
        } else if (_draggingPoint.x > NSMidX(lastCellRect)) {
            return _cachedNumberOfItems;
        } else {
            return _insertionIndex;
        }
    }
}

#pragma mark -
#pragma mark NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
	return context == NSDraggingContextWithinApplication ? NSDragOperationCopy : NSDragOperationNone;
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
	_draggingSession = nil;
}

#pragma mark - Accessors

- (void)setForegroundLayer:(CALayer *)foregroundLayer
{
	if(_foregroundLayer == foregroundLayer) return;
    
	[_foregroundLayer removeFromSuperlayer];
	_foregroundLayer = foregroundLayer;
    
	if(_foregroundLayer) [self reorderSublayers];
}

- (CALayer *)foregroundLayer
{
	return _foregroundLayer;
}

- (void)setBackgroundLayer:(CALayer *)backgroundLayer
{
	if(_backgroundLayer == backgroundLayer) return;
    
	[_backgroundLayer removeFromSuperlayer];
	_backgroundLayer = backgroundLayer;
    
	if(_backgroundLayer) [self reorderSublayers];
}

- (CALayer *)backgroundLayer
{
	return _backgroundLayer;
}

- (void)setVerticalContentInset:(CGFloat)verticalContentInset
{
    if (_verticalContentInset == verticalContentInset) return;
    _verticalContentInset = verticalContentInset;
    [self calculateCachedValuesAndQueryForDataChanges:NO];
}

- (CGFloat)verticalContentInset
{
    return _verticalContentInset;
}

- (void)setInterCellSpacing:(CGFloat)interCellSpacing
{
    if (_interCellSpacing == interCellSpacing) return;
    _interCellSpacing = interCellSpacing;
    [self calculateCachedValuesAndQueryForDataChanges:NO];
}

- (void)setPlayingIndex:(NSUInteger)playingIndex
{
    _playingIndex = playingIndex;
    [self calculateCachedValuesAndQueryForDataChanges:YES];
}

- (void)setDataSource:(id<SNRQueueViewDataSource>)dataSource
{
	if (_dataSource != dataSource) {
		_dataSource = dataSource;
		_dataSourceHas.viewForNoItemsInQueueView           = [_dataSource respondsToSelector:@selector(viewForNoItemsInQueueView:)];
		_dataSourceHas.pasteboardWriterForIndex           = [_dataSource respondsToSelector:@selector(queueView:pasteboardWriterForIndex:)];
		_dataSourceHas.menuForItemAtIndex              = [_dataSource respondsToSelector:@selector(queueView:menuForItemAtIndex:)];
		[self setNeedsReloadData];
	}
}

- (void)setDelegate:(id<SNRQueueViewDelegate>)delegate
{
	if (_delegate != delegate) {
		_delegate = delegate;
        _delegateHas.clickedItemAtIndex = [_delegate respondsToSelector:@selector(queueView:clickedItemAtIndex:)];
        _delegateHas.removeItemAtIndex = [_delegate respondsToSelector:@selector(queueView:removeItemAtIndex:)];
        _delegateHas.moveItemFromIndexToIndex = [_delegate respondsToSelector:@selector(queueView:moveItemAtIndex:toIndex:)];
        _delegateHas.insertSongsAtIndex = [_delegate respondsToSelector:@selector(queueView:insertSongs:atIndex:)];
	}
}
@end
