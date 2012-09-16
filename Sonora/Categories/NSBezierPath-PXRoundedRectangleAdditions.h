//
//  NSBezierPath+PXRoundedRectangleAdditions.h
//  OpenHUD
//
//  Created by Andy Matuschak on 7/3/05.
//  Copyright 2005 Andy Matuschak. All rights reserved.
//

typedef enum _OSCornerTypes
{
	OSTopLeftCorner = 1,
	OSBottomLeftCorner = 2,
	OSTopRightCorner = 4,
	OSBottomRightCorner = 8
} OSCornerType;

@interface NSBezierPath(PXRoundedRectangle)
+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)aRect cornerRadius:(float)radius;
+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)aRect cornerRadius:(float)radius inCorners:(OSCornerType)corners;
@end