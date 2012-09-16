//
//  SNRAppKitNavigationController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-14.
//  Copyright 2011 PCWiz Computer. All rights reserved.
//


@protocol SNRAppKitNavigationControllerDelegate;
@interface SNRAppKitNavigationController : NSViewController
@property (nonatomic, assign) IBOutlet id<SNRAppKitNavigationControllerDelegate> delegate;
@property (nonatomic, retain, readonly) NSArray *viewControllers;
@property (nonatomic, retain, readonly) NSViewController *visibleViewController;
@property (nonatomic, retain, readonly) NSViewController *topViewController;
- (id)initWithRootViewController:(NSViewController*)rootViewController;
- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated;

- (void)pushViewController:(NSViewController*)viewController animated:(BOOL)animated;
- (NSViewController*)popViewControllerAnimated:(BOOL)animated;
- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated;
- (NSArray*)popToViewController:(NSViewController*)viewController animated:(BOOL)animated;
@end

@protocol SNRAppKitNavigationControllerDelegate <NSObject>
@optional
- (void)navigationController:(SNRAppKitNavigationController*)navigationController willShowViewController:(NSViewController*)viewController animated:(BOOL)animated;
- (void)navigationController:(SNRAppKitNavigationController*)navigationController didShowViewController:(NSViewController*)viewController animated:(BOOL)animated;
@end