//
//  SNRAppKitNavigationController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-14.
//  Copyright 2011 PCWiz Computer. All rights reserved.
//

#import "SNRAppKitNavigationController.h"
#import "SNRAppKitViewController.h"

@interface SNRAppKitNavigationController ()
- (void)pushToViewControllerAnimated:(NSViewController*)viewController;
- (NSArray*)popToViewControllerAnimated:(NSViewController*)viewController;
- (void)pushToViewControllerNotAnimated:(NSViewController*)viewController;
- (NSArray*)popToViewControllerNotAnimated:(NSViewController*)viewController;
- (void)displayViewControllerWithoutAnimation:(NSViewController*)viewController;
- (void)delegateDidShowViewController:(NSViewController*)viewController animated:(BOOL)animated;
- (void)delegateWillShowViewController:(NSViewController*)viewController animated:(BOOL)animated;
- (void)clearViewControllers;
- (void)layoutViewController:(NSViewController*)viewController;
@end

@implementation SNRAppKitNavigationController  {
    NSMutableArray *sViewControllers;
}
@synthesize viewControllers = sViewControllers;
@synthesize delegate = sDelegate;

#pragma mark -
#pragma mark Initialization

- (id)initWithRootViewController:(NSViewController*)rootViewController
{
    if ((self = [super initWithNibName:nil bundle:nil])) {
        [self setView:[[NSView alloc] initWithFrame:NSZeroRect]];
        [[self view] setWantsLayer:YES];
        [self pushToViewControllerAnimated:rootViewController];
        sViewControllers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        sViewControllers = [[NSMutableArray alloc] init];
        [[self view] setWantsLayer:YES];
    }
    return self;
}

#pragma mark -
#pragma mark View Controllers

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    if (![viewControllers count]) { return; }
    [self clearViewControllers];
    NSViewController *lastViewController = [viewControllers lastObject];
    @synchronized(self) {
        [sViewControllers addObjectsFromArray:[viewControllers subarrayWithRange:NSMakeRange(0, [viewControllers count] - 1)]];
    }
    [self pushViewController:lastViewController animated:animated];
}

- (NSViewController*)topViewController
{
    @synchronized(self) {
        return [sViewControllers lastObject];
    }
}

- (NSViewController*)visibleViewController
{
    return self.topViewController;
}

- (void)pushViewController:(NSViewController*)viewController animated:(BOOL)animated
{
    animated ? [self pushToViewControllerAnimated:viewController] : [self pushToViewControllerNotAnimated:viewController];
}

- (NSViewController*)popViewControllerAnimated:(BOOL)animated
{
    NSViewController *popController = self.topViewController;
    if (!popController) { return nil; }
    [self popToViewController:popController animated:animated];
    return popController;
}

- (NSArray*)popToRootViewControllerAnimated:(BOOL)animated
{
    @synchronized(self) {
        if (![sViewControllers count]) { return nil; }
        return [self popToViewController:[sViewControllers objectAtIndex:0] animated:animated];
    }
}

- (NSArray*)popToViewController:(NSViewController*)viewController animated:(BOOL)animated
{
    @synchronized(self) {
        if (![sViewControllers count]) { return nil; }
        return (animated ? [self popToViewControllerAnimated:viewController] : [self popToViewControllerNotAnimated:viewController]);
    }
}

#pragma mark -
#pragma mark Animation

- (void)pushToViewControllerAnimated:(NSViewController*)viewController
{
    __block __unsafe_unretained SNRAppKitNavigationController *bself = self;
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self delegateWillShowViewController:viewController animated:YES];
    [self layoutViewController:viewController];
    [CATransaction begin];
    CAMediaTimingFunction *function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [CATransaction setAnimationTimingFunction:function];
    [CATransaction setCompletionBlock:^(void) {
        @synchronized(self) {
            [bself->sViewControllers addObject:viewController];
        }
        [bself delegateDidShowViewController:viewController animated:YES];
    }];
    [[self view] setAnimations:[NSDictionary dictionaryWithObject:transition forKey:@"subviews"]];
    if (self.topViewController) {
        [[[self view] animator] replaceSubview:[self.topViewController view] with:[viewController view]];
    } else {
        [[[self view] animator] addSubview:[viewController view]];
    }
    [CATransaction commit];
}

- (NSArray*)popToViewControllerAnimated:(NSViewController*)viewController
{
     __block __unsafe_unretained SNRAppKitNavigationController *bself = self;
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self delegateWillShowViewController:viewController animated:YES];
    [self layoutViewController:viewController];
    @synchronized(self) {
        NSUInteger index = [bself->sViewControllers indexOfObject:viewController];
        NSRange range = NSMakeRange(index, [sViewControllers count] - index);
        NSArray *controllers = [sViewControllers subarrayWithRange:range];
        [CATransaction begin];
        CAMediaTimingFunction *function = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [CATransaction setAnimationTimingFunction:function];
        [CATransaction setCompletionBlock:^(void) {
            @synchronized(self) {
                [bself->sViewControllers removeObjectsInRange:range];
            }
            [bself delegateDidShowViewController:viewController animated:YES];
        }];
        [[self view] setAnimations:[NSDictionary dictionaryWithObject:transition forKey:@"subviews"]];
        [[[self view] animator] replaceSubview:[self.topViewController view] with:[viewController view]];
        [CATransaction commit];
        return controllers;
    }
}

#pragma mark -
#pragma mark Delegate Methods

- (void)delegateDidShowViewController:(NSViewController*)viewController animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.delegate navigationController:self didShowViewController:viewController animated:animated];
    }
}

- (void)delegateWillShowViewController:(NSViewController*)viewController animated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.delegate navigationController:self didShowViewController:viewController animated:animated];
    }
}

#pragma mark -
#pragma mark Private

- (void)clearViewControllers
{
    [self.view setSubviews:[NSArray array]];
    @synchronized(self) {
        [sViewControllers removeAllObjects];
    }
}

- (void)layoutViewController:(NSViewController*)viewController
{
    if ([viewController isKindOfClass:[SNRAppKitViewController class]]) {
        [(SNRAppKitViewController*)viewController setNavigationController:self];
    }
    [[viewController view] setFrame:[[self view] bounds]];
    [[viewController view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
}

- (void)displayViewControllerWithoutAnimation:(NSViewController*)viewController
{
    [[[self topViewController] view] removeFromSuperview];
    [self layoutViewController:viewController];
    [[self view] addSubview:[viewController view]];
}

- (void)pushToViewControllerNotAnimated:(NSViewController*)viewController
{
    [self delegateWillShowViewController:viewController animated:NO];
    [self displayViewControllerWithoutAnimation:viewController];
    @synchronized(self) {
        [sViewControllers addObject:viewController];
    }
    [self delegateDidShowViewController:viewController animated:NO];
}

- (NSArray*)popToViewControllerNotAnimated:(NSViewController*)viewController
{
    [self delegateWillShowViewController:viewController animated:NO];
    @synchronized(self) {
        NSUInteger index = [sViewControllers indexOfObject:viewController];
        NSRange range = NSMakeRange(index, [sViewControllers count] - index);
        NSArray *controllers = [sViewControllers subarrayWithRange:range];
        [self displayViewControllerWithoutAnimation:viewController];
        [sViewControllers removeObjectsInRange:range];
        [self delegateDidShowViewController:viewController animated:NO];
        return controllers;
    }
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
    [self clearViewControllers];
}
@end
