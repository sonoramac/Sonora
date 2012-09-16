//
//  SNRHotKeyManager.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-04-21.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MASShortcut+UserDefaults.h"

@interface SNRHotKeyManager : NSObject
+ (SNRHotKeyManager*)sharedManager;
- (void)registerHotKeys;
@end
