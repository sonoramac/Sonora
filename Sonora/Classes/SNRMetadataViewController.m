//
//  SNRMetadataViewController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-12-22.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRMetadataViewController.h"

@implementation SNRMetadataViewController
@synthesize delegate = _delegate;
@synthesize metadataItems = _metadataItems;
@synthesize selectedItems = _selectedItems;

- (id)init
{
    return [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)setMetadataItems:(NSArray *)metadataItems selectedIndex:(NSNumber*)index
{
    self.metadataItems = metadataItems;
    self.selectedItems = (index != nil) ? [NSArray arrayWithObject:[metadataItems objectAtIndex:[index unsignedIntegerValue]]] : metadataItems;
}

- (IBAction)cancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(metadataViewControllerEndedMetadataEditing:)]) {
        [self.delegate metadataViewControllerEndedMetadataEditing:self];
    }
}

- (IBAction)done:(id)sender
{
}
@end
