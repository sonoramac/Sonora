//
//  SNRSearchViewController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-04-10.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SNRSearchController;
@protocol SNRSearchViewControllerDelegate;
@interface SNRSearchViewController : NSViewController <NSTextFieldDelegate>
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet NSTextField *searchField;
@property (nonatomic, retain, readonly) SNRSearchController *searchController;
@property (nonatomic, assign) IBOutlet id<SNRSearchViewControllerDelegate> delegate;
- (IBAction)enqueueItem:(id)sender;
@end


@protocol SNRSearchViewControllerDelegate <NSObject>
@optional
- (void)searchViewControllerDidUpdateSearchResults:(SNRSearchViewController*)controller;
- (void)searchViewControllerDidClearSearchResults:(SNRSearchViewController*)controller;
- (void)searchViewControllerDidBeginEditingSearchField:(SNRSearchViewController*)controller;
- (void)searchViewControllerDidEndEditingSearchField:(SNRSearchViewController*)controller;
@end