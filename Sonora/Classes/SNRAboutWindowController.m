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

#import "SNRAboutWindowController.h"

static NSString* const kURLTwitter = @"https://twitter.com/SonoraApp";
static NSString* const kURLFacebook = @"https://www.facebook.com/SonoraApp";
static NSString* const kURLWeb = @"http://getsonora.com";
static NSString* const kURLIndragie = @"https://twitter.com/indragie";
static NSString* const kURLTyler = @"https://twitter.com/tylrmurphy";

#define kLinkTextColor [NSColor colorWithDeviceRed:0.24f green:0.21f blue:0.62f alpha:1.f]
#define kNormalTextColor [NSColor colorWithDeviceRed:0.54f green:0.52f blue:0.74f alpha:1.f]

@implementation SNRAboutWindowController
@synthesize facebookButton = _facebookButton;
@synthesize twitterButton = _twitterButton;
@synthesize webButton = _webButton;
@synthesize versionLabel = _versionLabel;
@synthesize mainView = _mainView;
@synthesize creditsView = _creditsView;
@synthesize creditsTextView = _creditsTextView;

+ (SNRAboutWindowController*)sharedWindowController
{
    static SNRAboutWindowController *controller;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        controller = [[self alloc] initWithWindowNibName:NSStringFromClass([self class])];
    });
    return controller;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    [self.versionLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Version", nil), version]];
    
    NSString *creditsPath = [[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"rtf"];
    NSData *rtfData = [NSData dataWithContentsOfFile:creditsPath];
    NSMutableAttributedString *rtf = [[NSMutableAttributedString alloc] initWithRTF:rtfData documentAttributes:NULL];
    [rtf addAttribute:NSForegroundColorAttributeName value:kNormalTextColor range:NSMakeRange(0, [rtf length])];
    NSDictionary *linkAttr = [NSDictionary dictionaryWithObjectsAndKeys:kLinkTextColor, NSForegroundColorAttributeName, [NSCursor pointingHandCursor], NSCursorAttributeName, nil];
    [self.creditsTextView setLinkTextAttributes:linkAttr];
    [[self.creditsTextView textStorage] setAttributedString:rtf];
}

- (IBAction)facebook:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kURLFacebook]];
}

- (IBAction)twitter:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kURLTwitter]];
}

- (IBAction)web:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kURLWeb]];
}

- (IBAction)indragie:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kURLIndragie]];
}

- (IBAction)tyler:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kURLTyler]];
}

- (IBAction)credits:(id)sender
{
    BOOL mainView = [self.mainView superview] != nil;
    NSView *firstView = mainView ? self.mainView : self.creditsView;
    NSView *secondView = mainView ? self.creditsView : self.mainView;
    [secondView setAlphaValue:0.f];
    [secondView setFrame:[firstView frame]];
    [[firstView superview] addSubview:secondView];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [firstView removeFromSuperview];
    }];
    [[firstView animator] setAlphaValue:0.f];
    [[secondView animator] setAlphaValue:1.f];
    [NSAnimationContext endGrouping];
}

@end
