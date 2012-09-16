//
//  SNRRestorationManager.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-19.
//

#import <Foundation/Foundation.h>

@protocol SNRRestorableState <NSObject>
- (void)encodeRestorableStateWithArchiver:(NSKeyedArchiver *)archiver;
- (void)decodeRestorableStateWithArchiver:(NSKeyedUnarchiver *)unarchiver;
@end

@interface SNRRestorationManager : NSObject
@property (nonatomic, strong, readonly) NSSet *restorableObjects;
+ (instancetype)sharedManager;
- (void)registerRestorationObject:(id<SNRRestorableState>)object;
- (void)deregisterRestorationObject:(id<SNRRestorableState>)object;
- (void)deleteRestorationState;
@end
