//
//  SNRFileCopyManager.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-09-19.
//  Copyright 2011 PCWiz Computer. All rights reserved.
//

@protocol SNRFileCopyManagerDelegate;
@class SNRFileCopyManagerCopy;
@interface SNRFileCopyManager : NSObject
@property (nonatomic, retain) id representedObject; // optional
@property (nonatomic, readonly, retain) SNRFileCopyManagerCopy *currentCopy;
@property (nonatomic, assign, readonly) unsigned long long totalSize;
@property (nonatomic, assign, readonly) unsigned long long totalProgress;
@property (nonatomic, weak) id<SNRFileCopyManagerDelegate> delegate;
- (id)initWithSourcesAndDestinations:(NSString*)firstSource, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithCopies:(NSArray*)copies; // array of SNRFileCopyManagerCopy objects with the sourcePath and destinationPath set
- (void)startCopy;
- (void)cancelCopy;
@end

@interface SNRFileCopyManagerCopy : NSObject
@property (nonatomic, retain) id representedObject; // optional
@property (nonatomic, copy) NSString *sourcePath;
@property (nonatomic, copy) NSString *destinationPath;
@property (nonatomic, assign, readonly) unsigned long long size;
@property (nonatomic, assign, readonly) unsigned long long progress;
@property (nonatomic, weak, readonly) SNRFileCopyManager *fileCopyManager;
@end

@protocol SNRFileCopyManagerDelegate <NSObject>
@optional
- (void)fileCopyManagerWillBeginCopy:(SNRFileCopyManager*)manager;
- (void)fileCopyManager:(SNRFileCopyManager*)manager willCopy:(SNRFileCopyManagerCopy*)copy;
- (void)fileCopyManager:(SNRFileCopyManager*)manager copiedBytesOfCopy:(SNRFileCopyManagerCopy*)copy;
- (void)fileCopyManager:(SNRFileCopyManager*)manager didCopy:(SNRFileCopyManagerCopy*)copy;
- (void)fileCopyManager:(SNRFileCopyManager*)manager failedToCopy:(SNRFileCopyManagerCopy*)copy;
- (void)fileCopyManagerDidFinishCopy:(SNRFileCopyManager*)manager;
@end