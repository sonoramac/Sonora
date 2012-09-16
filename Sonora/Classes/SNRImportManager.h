//
//  SNRImportManager.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-04-29.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRiTunesImportOperation.h"
#import "SNRFileImportOperation.h"

@interface SNRImportManager : NSObject <SNRiTunesImportOperationDelegate, SNRFileImportOperationDelegate>
@property (nonatomic, weak) NSProgressIndicator *progressBar;
+ (SNRImportManager*)sharedImportManager;
- (void)performiTunesSync;
- (void)importFiles:(NSArray*)files play:(BOOL)play;
@end
