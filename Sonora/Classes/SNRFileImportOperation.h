//
//  SNRFileImportOperation.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-11-18.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRFileCopyManager.h"

@protocol SNRFileImportOperationDelegate;
@interface SNRFileImportOperation : NSOperation <SNRFileCopyManagerDelegate>
@property (nonatomic, assign) id<SNRFileImportOperationDelegate> delegate;
@property (nonatomic, readonly) NSArray *files;
@property (nonatomic, assign) BOOL play;
- (id)initWithFiles:(NSArray*)files;
+ (BOOL)validateFiles:(NSArray*)files;
@end

@protocol SNRFileImportOperationDelegate <NSObject>
@optional
- (void)fileImportOperation:(SNRFileImportOperation*)operation importedFileAtPath:(NSString*)path success:(BOOL)success;
- (void)fileImportOperationDidFinishImport:(SNRFileImportOperation*)operation withObjectIDs:(NSArray*)objectIDs;
- (void)fileImportOperation:(SNRFileImportOperation*)operation willBeginImporting:(NSUInteger)count;
@end