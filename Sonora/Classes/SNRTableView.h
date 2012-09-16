//
//  SNRTableView.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SNRTableViewDelegate;
@interface SNRTableView : NSTableView
@property (nonatomic, assign) IBOutlet id<SNRTableViewDelegate> delegate;
@end

@protocol SNRTableViewDelegate <NSTableViewDelegate>
@optional
- (void)tableView:(NSTableView*)aTableView deleteRowsAtIndexes:(NSIndexSet*)indexes;
- (NSDragOperation)tableView:(NSTableView*)tableView draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context;
@end