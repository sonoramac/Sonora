//
//  SNRAlbumsGridView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-03.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRAlbumsGridView.h"

#define kGridViewRowSpacing 30.f
#define kGridViewColumnSpacing 10.f

@implementation SNRAlbumsGridView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.minimumColumnSpacing = kGridViewColumnSpacing;
        self.rowSpacing = kGridViewRowSpacing;
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, NSTIFFPboardType, nil]];
    }
    return self;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    return NSDragOperationCopy;
}
@end
