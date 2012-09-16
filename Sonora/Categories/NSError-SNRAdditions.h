//
//  NSError-SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-28.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

@interface NSError (SNRAdditions)
+ (NSError*)errorWithCode:(NSInteger)code description:(NSString*)desc;
+ (NSError*)genericErrorWithDescription:(NSString*)desc;
@end
