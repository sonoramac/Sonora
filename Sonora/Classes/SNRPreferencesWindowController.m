//
//  SNRPreferencesWindowController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-09-12.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRPreferencesWindowController.h"
#import "SNRLastFMEngine.h"
#import "SNRProgressWindowController.h"

#import "NSUserDefaults-SNRAdditions.h"
#import "MASShortcutView+UserDefaults.h"

static NSString* const kImageGeneral = @"general";
static NSString* const kImageSync = @"sync";
static NSString* const kImageLastFM = @"lastfm";

#define kPromptTextColor [NSColor colorWithDeviceWhite:0.5f alpha:1.f]

@interface SNRPreferencesWindowController ()
- (void)moveLibraryToURL:(NSURL*)url;
- (void)resetLastFMButtonAndTextField;
@end

@implementation SNRPreferencesWindowController
@synthesize general = _general;
@synthesize sync = _sync;
@synthesize lastFM = _lastFM;
@synthesize searchShortcutView = _searchShortcutView;
@synthesize lastFMButton = _lastFMButton;
@synthesize lastFMField = _lastFMField;

#pragma mark DBPrefsWindowController Overrides

+ (NSString *)nibName
{
    return NSStringFromClass([self class]);
}

- (void)setupToolbar
{
    [self addView:self.general label:NSLocalizedString(@"PreferencesGeneral", nil) image:[NSImage imageNamed:kImageGeneral]];
    [self addView:self.sync label:NSLocalizedString(@"PreferencesSync", nil) image:[NSImage imageNamed:kImageSync]];
    [self addView:self.lastFM label:NSLocalizedString(@"PreferencesLastFM", nil) image:[NSImage imageNamed:kImageLastFM]];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self resetLastFMButtonAndTextField];
    [self.searchShortcutView setAssociatedUserDefaultsKey:kUserDefaultsSearchShortcutKey];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.lastFMUsername" options:0 context:NULL];
}

- (IBAction)authenticateLastFM:(id)sender
{
    SNRLastFMEngine *engine = [SNRLastFMEngine sharedInstance];
    if ([engine isAuthenticated]) {
        engine.username = nil;
        [[NSUserDefaults standardUserDefaults] setLastFMUsername:nil];
    } else {
        [[NSWorkspace sharedWorkspace] openURL:[SNRLastFMEngine webAuthenticationURLWithCallbackURL:nil]];
    }
}

- (IBAction)changePath:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanCreateDirectories:YES];
    [openPanel setTitle:NSLocalizedString(@"ChooseMusicFolderLocation", nil)];
    [openPanel setPrompt:NSLocalizedString(@"Choose", nil)];
    NSURL *url = [NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] libraryPath]];
    [openPanel setDirectoryURL:url];
    NSInteger response = [openPanel runModal];
    if (response == NSFileHandlingPanelOKButton) {
        [self moveLibraryToURL:[openPanel URL]];
    }
}

- (IBAction)resetPath:(id)sender
{
    [self moveLibraryToURL:[SonoraAppDelegate defaultMusicDirectory]];
}

#pragma mark - Key Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self resetLastFMButtonAndTextField];
}

#pragma mark - Private

- (void)resetLastFMButtonAndTextField
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = ud.lastFMUsername;
    if (username) {
        [self.lastFMButton setTitle:NSLocalizedString((username != nil) ? @"SignOut" : @"SignIn", nil)];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSCenterTextAlignment];
        NSDictionary *promptAttributes = [NSDictionary dictionaryWithObjectsAndKeys:kPromptTextColor, NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
        NSMutableAttributedString *prompt = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"SignedInAs", nil) attributes:promptAttributes];
        NSAttributedString *user = [[NSAttributedString alloc] initWithString:username];
        [prompt appendAttributedString:user];
        [self.lastFMField setAttributedStringValue:prompt];
    } else {
        [self.lastFMField setStringValue:@""];
    }
    
}

- (void)moveLibraryToURL:(NSURL*)url
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSURL *currentURL = [NSURL fileURLWithPath:[ud libraryPath]];
    NSString *currentPath = [currentURL path];
    if (![url isEqual:currentURL]) {
        NSString *newPath = [url path];
        if ([[NSFileManager defaultManager] fileExistsAtPath:currentPath]) {
            NSString *label = [NSString stringWithFormat:NSLocalizedString(@"MovingMusicFolder", nil), newPath];
            [SONORA_APPDELEGATE setBlockTermination:YES];
            SNRProgressWindowController *progress = [[SNRProgressWindowController alloc] initWithLabel:label];
            [progress showWindow:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *error = nil;
                NSFileManager *fm = [[NSFileManager alloc] init];
                NSArray *subpaths = [fm contentsOfDirectoryAtPath:currentPath error:&error];
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                if ([subpaths count] && !error) {
                    dispatch_sync(mainQueue, ^{
                        [progress.progressIndicator setIndeterminate:NO];
                        [progress.progressIndicator setMaxValue:[subpaths count]];
                    });
                    for (NSString *subpath in subpaths) {
                        NSString *srcPath = [currentPath stringByAppendingPathComponent:subpath];
                        NSString *destPath = [newPath stringByAppendingPathComponent:subpath];
                        [fm moveItemAtPath:srcPath toPath:destPath error:&error];
                        if (error) { break; }
                        dispatch_sync(mainQueue, ^{
                            [progress.progressIndicator incrementBy:1.0];
                        });
                    }
                }
                dispatch_async(mainQueue, ^{
                    [[progress window] orderOut:nil];
                    [SONORA_APPDELEGATE setBlockTermination:NO];
                    if (error) {
                        NSAlert *alert = [NSAlert alertWithError:error];
                        [alert runModal];
                    } else {
                        [SONORA_APPDELEGATE setSonoraLibraryURL:url];
                    }
                });
            });
        } else {
            [SONORA_APPDELEGATE setSonoraLibraryURL:url];
        }
    }
}

@end
