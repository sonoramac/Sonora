//
//  SNRBlockMenuItem.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-25.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

@interface SNRBlockMenuItem : NSMenuItem
@property (copy, readwrite) void (^block)(NSMenuItem *item);
- (id)initWithTitle:(NSString *)title keyEquivalent:(NSString *)key block:(void (^)(NSMenuItem *item))block;
@end
