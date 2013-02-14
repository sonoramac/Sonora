//
//  SNRArtworkStore.m
//  Sonora
//
//  Created by Edward Barnard on 13/02/2013.
//  Copyright (c) 2013 Sonora. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

#import "SNRArtworkStore.h"
#import "SNRAlbum.h"
#import "SNRArtwork.h"
#import "SNRArtist.h"
#import "SNRCommon.h"

@implementation SNRArtworkStore
{
    NSString* _storeName;
}

- (id)initWithName:(NSString*)name
{
    if ((self = [super init])) {
        _storeName = name;
    }
    return self;
}

- (void)setArtworkForObject:(id)object data:(NSData *)data
{
    if(!object) return;
    NSData* uuidData = [object uuid];
    NSUUID* uuid;
    if ([uuidData length] == 0)
    {
        uuid = [NSUUID UUID];
        unsigned char bytes[16];
        [uuid getUUIDBytes:bytes];
        [object setValue:[NSData dataWithBytes:bytes length:16] forKey:@"uuid"];
    }
    else
        uuid = [[NSUUID alloc] initWithUUIDBytes:[uuidData bytes]];
    
    NSURL* artworkPath = [self artworkPathForObject:object];
    NSError* error;

    if(![[NSFileManager defaultManager] createDirectoryAtPath:[[artworkPath path] stringByDeletingLastPathComponent] withIntermediateDirectories:true attributes:nil error:&error])
    {
        [[NSApplication sharedApplication] presentError:error];
        return;
    }
    // Atomic so no need for locks
    if(![data writeToURL:artworkPath options:NSDataWritingAtomic error:&error])
    {
        [[NSApplication sharedApplication] presentError:error];
        return;
    }
}

- (NSURL*)artworkDirectory
{
    return [[SONORA_APPDELEGATE applicationFilesDirectory] URLByAppendingPathComponent:_storeName];
}

- (NSURL*)artworkPathForObject:(id)object
{
    if(!object) return nil;
    NSUUID* uuid = [[NSUUID alloc] initWithUUIDBytes:[[object uuid] bytes]];
    NSString* fileName = [uuid UUIDString];
    NSString* folderName = [fileName substringToIndex:2];
    return [[[self artworkDirectory] URLByAppendingPathComponent: folderName] URLByAppendingPathComponent:fileName];
}

- (NSData*)artworkForObject:(id)object
{
    if(!object) return nil;
    NSURL* artworkPath = [self artworkPathForObject:object];
    NSError* error;
    NSFileHandle * file = [NSFileHandle fileHandleForReadingFromURL:artworkPath error: &error];
    return [file readDataToEndOfFile];
}

@end
