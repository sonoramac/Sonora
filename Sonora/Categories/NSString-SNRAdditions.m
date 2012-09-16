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

#import "NSString-SNRAdditions.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (SNRAdditions)
- (NSString*)normalizedString
{
    NSMutableString *result = [NSMutableString stringWithString:self];
    CFStringNormalize((__bridge CFMutableStringRef)result, kCFStringNormalizationFormD);
    CFStringFold((__bridge CFMutableStringRef)result, kCFCompareCaseInsensitive | kCFCompareDiacriticInsensitive | kCFCompareWidthInsensitive, NULL);
    return result;
}

- (NSString*)stringByRemovingExtraneousWhitespace
{
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
    NSPredicate *noEmptyStrings = [NSPredicate predicateWithFormat:@"SELF != ''"];
    NSArray *parts = [self componentsSeparatedByCharactersInSet:whitespaces];
    NSArray *filteredArray = [parts filteredArrayUsingPredicate:noEmptyStrings];
    return [filteredArray componentsJoinedByString:@" "];
}

- (NSString*)stringByRemovingNonAlphanumbericCharacters
{
    static NSMutableCharacterSet *unionSet = nil;
    if (!unionSet) {
        unionSet = [NSMutableCharacterSet alphanumericCharacterSet];;
        [unionSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return [self stringByFilteringToCharactersInSet:unionSet];
}

- (NSString*)stringByFilteringToCharactersInSet:(NSCharacterSet*)set
{
    NSMutableString *result = [NSMutableString stringWithCapacity:[self length]];
    NSScanner *scanner = [NSScanner scannerWithString:self];
    while ([scanner isAtEnd] == NO) {
        NSString *buffer = nil;
        if ([scanner scanCharactersFromSet:set intoString:&buffer]) {
            [result appendString:buffer];     
        } else {
            [scanner setScanLocation:([scanner scanLocation] + 1)];
        }
    }
    return result;
}

+ (NSString *)stringFromFileSize:(NSUInteger)theSize
{
	float floatSize = theSize;
	if (theSize < 1023)
		return [NSString stringWithFormat:@"%lu bytes",theSize];
	floatSize = floatSize / 1024;
	if (floatSize < 1023)
		return [NSString stringWithFormat:@"%1.1f KB",floatSize];
	floatSize = floatSize / 1024;
	if (floatSize < 1023)
		return [NSString stringWithFormat:@"%1.1f MB",floatSize];
	floatSize = floatSize / 1024;
	return [NSString stringWithFormat:@"%1.1f GB",floatSize];
}

- (NSString*)MD5 
{
	const char *cStr = [self UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [[NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			] lowercaseString];  
}

- (NSString*)URLEncodedString
{
    return [self URLEncodedStringForCharacters:@":/?#[]@!$&’()*+,;="];
}

- (NSString*)URLEncodedStringForCharacters:(NSString*)characters
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, NULL, (__bridge CFStringRef)characters, kCFStringEncodingUTF8);
}

- (NSString*)upperBoundsString
{
    NSUInteger length = [self length];
    NSString *baseString = nil;
    NSString *incrementedString = nil;
    
    if (length < 1) {
        return self;
    } else if (length > 1) {
        baseString = [self substringToIndex:(length-1)];
    } else {
        baseString = @"";
    }
    UniChar lastChar = [self characterAtIndex:(length-1)];
    UniChar incrementedChar;
    
    // We can't do a simple lastChar + 1 operation here without taking into account
    // unicode surrogate characters (http://unicode.org/faq/utf_bom.html#34)
    
    if ((lastChar >= 0xD800UL) && (lastChar <= 0xDBFFUL)) {         // surrogate high character
        incrementedChar = (0xDBFFUL + 1);
    } else if ((lastChar >= 0xDC00UL) && (lastChar <= 0xDFFFUL)) {  // surrogate low character
        incrementedChar = (0xDFFFUL + 1);
    } else if (lastChar == 0xFFFFUL) {
        if (length > 1 ) baseString = self;
        incrementedChar =  0x1;
    } else {
        incrementedChar = lastChar + 1;
    }
    
    incrementedString = [[NSString alloc] initWithFormat:@"%@%C", baseString, incrementedChar];
    
    return incrementedString;
}

+ (NSString*)timeStringForTimeInterval:(NSTimeInterval)interval
{
    NSInteger minutes = floor(interval / 60);
	NSInteger seconds = (NSUInteger)(interval - (minutes * 60));
	NSString *secondsString = nil;
	if (seconds == 0) {
		secondsString = @"00";
	} else if (seconds < 10) {
		secondsString = [NSString stringWithFormat:@"0%ld", seconds];
	} else {
		secondsString = [NSString stringWithFormat:@"%ld", seconds];
	}
	return [NSString stringWithFormat:@"%ld:%@", minutes, secondsString];
}

+ (NSString*)humanReadableStringForTimeInterval:(NSTimeInterval)interval
{
    if (interval < 1) { return @""; }
    if (interval < 60) {
        int rounded = floor(interval);
        if (rounded == 1) { return [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"second", nil)]; }
        return [NSString stringWithFormat:@"%d %@", rounded, NSLocalizedString(@"seconds", nil)];
    }
    interval = interval / 60;
    //if (interval < 60) {
        int rounded = floor(interval);
        if (rounded == 1) { return [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"minute", nil)]; }
        return [NSString stringWithFormat:@"%d %@", rounded, NSLocalizedString(@"minutes", nil)];
   // }
    /*interval = interval / 60;
    if (interval < 24) {
        int rounded = floor(interval);
        if (rounded == 1) { return [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"hour", nil)]; }
        return [NSString stringWithFormat:@"%d %@", rounded, NSLocalizedString(@"hours", nil)];
    }
    interval = interval / 24;
    if (interval < 7) {
        int rounded = floor(interval);
        if (rounded == 1) { return [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"day", nil)]; }
        return [NSString stringWithFormat:@"%d %@", rounded, NSLocalizedString(@"days", nil)];
    }
    interval = interval / 7;
    if (interval < 4) {
        int rounded = floor(interval);
        if (rounded == 1) { return [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"week", nil)]; }
        return [NSString stringWithFormat:@"%d %@", rounded, NSLocalizedString(@"weeks", nil)];
    }
    interval = interval / 4;
    if (interval < 12) {
        int rounded = floor(interval);
        if (rounded == 1) { return [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"month", nil)]; }
        return [NSString stringWithFormat:@"%d %@", rounded, NSLocalizedString(@"months", nil)];
    }
    interval = interval / 12;
    int rounded = floor(interval);
    if (rounded == 1) { return [NSString stringWithFormat:@"1 %@", NSLocalizedString(@"year", nil)]; }
    return [NSString stringWithFormat:@"%1.f %@", interval, NSLocalizedString(@"years", nil)];*/

}

- (NSArray*)spaceSeparatedComponents
{
    return [[self stringByRemovingExtraneousWhitespace] componentsSeparatedByString:@" "];
}

+ (NSString*)randomUUID
{
    CFUUIDRef cfuuid = CFUUIDCreate (kCFAllocatorDefault);
    NSString *string = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, cfuuid);
    CFRelease(cfuuid);
    return string;
}

+ (NSData*)HMACSHA256EncodedDataWithKey:(NSString*)key data:(NSString*)data
{
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:CC_SHA256_DIGEST_LENGTH];
}
@end

@implementation NSAttributedString (SNRAdditions)

- (NSAttributedString*)attributedStringWithColor:(NSColor*)color
{
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] 
                                            initWithAttributedString:self];
    int len = [attrTitle length];
    NSRange range = NSMakeRange(0, len);
    [attrTitle addAttribute:NSForegroundColorAttributeName 
                      value:color
                      range:range];
    [attrTitle fixAttributesInRange:range];
    return attrTitle;
}

- (NSColor*)color
{
    int len = [self length];
    NSRange range = NSMakeRange(0, MIN(len, 1)); // take color from first char
    NSDictionary *attrs = [self fontAttributesInRange:range];
    NSColor *textColor = [NSColor controlTextColor];
    if (attrs) {
        textColor = [attrs objectForKey:NSForegroundColorAttributeName];
    }
    return textColor;
}
@end
