//
//  SNRMetadataWindowController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-01-30.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRMetadataWindowController.h"
#import "SNRSongMetadataViewController.h"
#import "SNRAlbumMetadataViewController.h"

#import "NSWindow+SNRAdditions.h"

NSString* const SNRMetadataWindowControllerSelectionChangedNotification = @"SNRMetadataWindowControllerSelectionChangedNotification";
NSString* const SNRMetadataWindowControllerSelectionChangedEntityNameKey = @"entityName";
NSString* const SNRMetadataWindowControllerSelectionChangedItemsKey = @"items";
NSString* const SNRMetadataWindowControllerSelectionChangedSelectedKey = @"selection";

@interface SNRMetadataWindowController ()
- (void)selectionChanged:(NSNotification *)notification;
- (void)loadMetadataForEntityName:(NSString *)entityName;
@property (nonatomic, retain) SNRMetadataViewController *metadataViewController;
@end

@implementation SNRMetadataWindowController {
    NSMutableDictionary *_selectedItems;
    NSMutableArray *_selectionStack;
    NSMutableArray *_viewControllers;
}
@synthesize metadataViewController = _metadataViewController;

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    if ((self = [super initWithWindowNibName:windowNibName])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionChanged:) name:SNRMetadataWindowControllerSelectionChangedNotification object:nil];
        _selectionStack = [NSMutableArray array];
        _selectedItems = [NSMutableDictionary dictionary];
        _viewControllers = [NSMutableArray array];
    }
    return self;
}

+ (SNRMetadataWindowController*)sharedWindowController;
{
    static SNRMetadataWindowController *controller;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        controller = [[self alloc] initWithWindowNibName:NSStringFromClass([self class])];
    });
    return controller;
}

- (void)showWindow:(id)sender
{
    [self.window fadeIn:nil];
}

- (void)hideWindow:(id)sender
{
    [self.window fadeOut:nil];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self loadMetadataForEntityName:nil];
}

- (void)selectionChanged:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSString *entityName = [userInfo valueForKey:SNRMetadataWindowControllerSelectionChangedEntityNameKey];
    NSArray *items = [userInfo valueForKey:SNRMetadataWindowControllerSelectionChangedItemsKey];
    NSIndexSet *selection = [userInfo valueForKey:SNRMetadataWindowControllerSelectionChangedSelectedKey];
    NSUInteger count = [items count];
    if (count) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:items, SNRMetadataWindowControllerSelectionChangedItemsKey, selection, SNRMetadataWindowControllerSelectionChangedSelectedKey, nil];
        [_selectedItems setValue:dict forKey:entityName];
        [_selectionStack removeObject:entityName];
        [_selectionStack addObject:entityName];
        [self loadMetadataForEntityName:entityName];
    } else {
        [_selectedItems setValue:nil forKey:entityName];
        [_selectionStack removeObject:entityName];
        [self loadMetadataForEntityName:[_selectionStack lastObject]];
    }
}

- (void)setMetadataViewController:(SNRMetadataViewController *)metadataViewController
{
    if (_metadataViewController != metadataViewController) {
        [_metadataViewController.view removeFromSuperview];
        _metadataViewController = metadataViewController;
        [_viewControllers addObject:_metadataViewController];
    }
}

- (void)loadMetadataForEntityName:(NSString *)entityName
{
    if ([entityName isEqualToString:kEntityNameSong]) {
        NSDictionary *dict = [_selectedItems valueForKey:kEntityNameSong];
        NSArray *songs = [dict valueForKey:SNRMetadataWindowControllerSelectionChangedItemsKey];
        NSNumber *selected = [dict valueForKey:SNRMetadataWindowControllerSelectionChangedSelectedKey];
        if (![self.metadataViewController isKindOfClass:[SNRSongMetadataViewController class]]) {
            self.metadataViewController = [[SNRSongMetadataViewController alloc] init];
        }
        [self.metadataViewController setMetadataItems:songs selectedIndex:selected];
        NSUInteger count = (selected != nil) ? 1 : [songs count];
        self.window.title = [NSString stringWithFormat:@"%lu %@ %@", count, NSLocalizedString((count == 1) ? @"song" : @"songs", nil), NSLocalizedString(@"selected", nil)];
    } else if ([entityName isEqualToString:kEntityNameAlbum]) {
        NSDictionary *dict = [_selectedItems valueForKey:kEntityNameAlbum];
        NSArray *albums = [dict valueForKey:SNRMetadataWindowControllerSelectionChangedItemsKey];
        if (![self.metadataViewController isKindOfClass:[SNRAlbumMetadataViewController class]]) {
            self.metadataViewController = [[SNRAlbumMetadataViewController alloc] init];
        }
        [self.metadataViewController setMetadataItems:albums selectedIndex:nil];
        NSUInteger count = [albums count];
        self.window.title = [NSString stringWithFormat:@"%lu %@ %@", count, NSLocalizedString((count == 1) ? @"album" : @"albums", nil), NSLocalizedString(@"selected", nil)];
    } else {
        self.metadataViewController = [[SNRMetadataViewController alloc] init];
        self.window.title = NSLocalizedString(@"MetadataEditor", nil);
    }
    if (self.metadataViewController) {
        self.metadataViewController.delegate = self;
        NSView *metadataView = self.metadataViewController.view;
        metadataView.frame = NSMakeRect(0.f, 0.f, metadataView.frame.size.width, metadataView.frame.size.height);
        metadataView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        NSRect frame = [self.window frameRectForContentRect:metadataView.frame];
        NSRect newFrame = self.window.frame;
        newFrame.origin.y += (newFrame.size.height - frame.size.height);
        newFrame.size.height = frame.size.height;
        [self.window setFrame:newFrame display:YES animate:YES];
        [self.window.contentView addSubview:metadataView];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)metadataViewControllerEndedMetadataEditing:(SNRMetadataViewController*)controller
{
    [self hideWindow:nil];
    [_viewControllers removeObject:controller];
}
@end
