//
//  NSString-SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-06.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

@interface NSString (SNRAdditions)
- (NSString*)stringByRemovingExtraneousWhitespace;
- (NSString*)stringByFilteringToCharactersInSet:(NSCharacterSet*)set;
- (NSString*)stringByRemovingNonAlphanumbericCharacters;
+ (NSString*)stringFromFileSize:(NSUInteger)theSize;
- (NSString*)MD5;
- (NSString*)URLEncodedString;
- (NSString*)URLEncodedStringForCharacters:(NSString*)characters;
- (NSString*)normalizedString;
- (NSString*)upperBoundsString;
+ (NSString*)timeStringForTimeInterval:(NSTimeInterval)interval;
+ (NSString*)humanReadableStringForTimeInterval:(NSTimeInterval)interval;
- (NSArray*)spaceSeparatedComponents;
+ (NSString*)randomUUID;
+ (NSData*)HMACSHA256EncodedDataWithKey:(NSString*)key data:(NSString*)data;
@end

@interface NSAttributedString (SNRAdditions)
- (NSAttributedString*)attributedStringWithColor:(NSColor*)color;
- (NSColor*)color;
@end
