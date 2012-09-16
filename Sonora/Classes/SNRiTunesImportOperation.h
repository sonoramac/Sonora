//
//  SNRiTunesImportOperation.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-11-18.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNRiTunesImportOperationDelegate;
@interface SNRiTunesImportOperation : NSOperation
@property (nonatomic, assign) BOOL importAll;
@property (nonatomic, assign) id<SNRiTunesImportOperationDelegate> delegate;
+ (NSURL*)iTunesLibraryURL;
@end

@protocol SNRiTunesImportOperationDelegate <NSObject>
@optional
- (void)iTunesImportOperation:(SNRiTunesImportOperation*)operation willBeginImporting:(NSUInteger)count;
- (void)iTunesImportOperation:(SNRiTunesImportOperation*)operation finishedImporting:(NSUInteger)count;
- (void)iTunesImportOperation:(SNRiTunesImportOperation*)operation importedFile:(NSString*)path success:(BOOL)success;
@end