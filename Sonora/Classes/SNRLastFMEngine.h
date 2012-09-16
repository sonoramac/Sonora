//
//  SNRLastFMEngine.h
//
//  Created by Indragie Karunaratne on 10-11-24.
//  Copyright 2010 Indragie Karunaratne. All rights reserved.
//
/* Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

#import <Foundation/Foundation.h>

#define API_ROOT @"http://ws.audioscrobbler.com/2.0/"

typedef enum {
	SNRHTTPMethodGET = 0,
	SNRHTTPMethodPOST = 1
} SNRHTTPMethod;

typedef enum {
    SNRLastFMEngineImageSizeSmall = 0,
    SNRLastFMEngineImageSizeMedium = 1,
    SNRLastFMEngineImageSizeLarge = 2,
    SNRLastFMEngineImageSizeExtraLarge = 3,
    SNRLastFMEngineImageSizeMega = 4
} SNRLastFMImageSize;

@interface SNRLastFMEngine : NSObject
/** Username property MUST be set to make authenticated API calls and is used to retrieve the session key from the OS X Keychain */
@property (nonatomic, retain) NSString *username;

#pragma mark -
#pragma mark Initialization

+ (SNRLastFMEngine*)sharedInstance;

/**
 Initializes a new SNRLastFMEngine object with the specified username
 @param user the username
 @return a new SNRLastFMEngine object
 */
- (id)initWithUsername:(NSString*)user;
/**
 Initializes a new autoreleased SNRLastFMEngine object
 @return a new SNRLastFMEngine object
 */
+ (id)lastFMEngine;
/**
 Initializes a new autoreleased SNRLastFMEngine object with the specified username
 @param user the username
 @return a new SNRLastFMEngine object
 */
+ (id)lastFMEngineWithUsername:(NSString*)user;

#pragma mark -
#pragma mark Basic

/**
 Calls a method on the Last.fm API with the specified parameters and calls the completion block with the data receieved.
 @param method the method to call
 @param params method parameters
 @param auth whether the method requires authentication or not
 @param http the HTTP method to use (SNRHTTPMethodGET or SNRHTTPMethodPOST)
 @param handler a completion handler block
 */
- (void)callMethod:(NSString*)method withParameters:(NSDictionary*)params requireAuth:(BOOL)auth HTTPMethod:(SNRHTTPMethod)http completionBlock:(void (^)(NSDictionary *response, NSError *error))handler;

#pragma mark -
#pragma mark Authentication

/**
 Used by desktop & web authentication. Retrieves a session key using a given token and stores it in the OS X Keychain
 @param token an authentication token
 @param handler a completion handler block
 */
- (void)retrieveAndStoreSessionKeyWithToken:(NSString*)token completionHandler:(void (^)(NSString *user, NSError *error))handler;

#pragma mark -
#pragma mark Web Authentication

/**
 Returns a web authentication URL that can have a callback URL.
 @param callback Callback URL to open when the user has authenticated with Last.fm
 See here for more info on custom auth handlers <http://www.last.fm/api/webauth#create_an_authentication_handler>
 */
+ (NSURL*)webAuthenticationURLWithCallbackURL:(NSURL*)callback;

#pragma mark -
#pragma mark Desktop Authentication

/**
 Retrieves a new authentication token from the Last.fm API
 @param handler a completion handler block
 */
- (void)retrieveAuthenticationToken:(void (^)(NSString *token, NSError *error))handler;

/**
 Returns an authentication URL that can be opened in a browser to authenticate your application with a user's Last.fm account
 @param token an authentication token obtained from the -retrieveAuthenticationToken: method
 @returns an authenticantion URL
 */
+ (NSURL*)authenticationURLWithToken:(NSString*)token;

#pragma mark -
#pragma mark Mobile Authentication

/**
 Returns an authorization token with the specified credentials
 @param username the user's username
 @param password the user's password
 @param handler a completion handler block
 */
- (void)retrieveAndStoreSessionKeyWithUsername:(NSString*)username password:(NSString*)password completionHandler:(void (^)(NSError *error))handler;

#pragma mark -
#pragma mark Keychain Access

/**
 Checks if the specified user has credentials stored in the keychain
 @param user the username
 @returns whether the user has stored credentials or not
 */
+ (BOOL)userHasStoredCredentials:(NSString*)user;

/** 
 Deletes the credentials for the specified user from the keychain
 @param user the username
 */
+ (void)removeCredentialsForUser:(NSString*)user;

/**
 Checks whether the current instance of SNRLastFMEngine is authenticated
 */
- (BOOL)isAuthenticated;

#pragma mark -
#pragma mark Convenience

///////////////////////////////////////////////////////////////////////////////////////
//                                                                                   //
//  These are convenience methods that I included because I use them in my own apps  //
//  and they are just a few of the many things that the Last.fm API is capable of.   //
//  For full API documentation please see:                                           //
//  http://www.last.fm/api/intro                                                     //
//                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Scrobbling/Now Playing

/**
 Scrobbles a track with the given parameters
 @param name the track name
 @param album the name of the track's album
 @param artist the name of the track's artist
 @param albumArtist the name of the track's album artist
 @param track the track number
 @param duration the duration of the track (must be an integer)
 @param timestamp the timestamp at which the track was played --> use [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]] because the timestamp *must* be an integer
 @param handler a completion handler block
 */
- (void)scrobbleTrackWithName:(NSString*)name album:(NSString*)album artist:(NSString*)artist albumArtist:(NSString*)albumArtist trackNumber:(NSInteger)trackNumber duration:(NSInteger)duration timestamp:(NSInteger)timestamp completionHandler:(void (^)(NSDictionary *scrobbles, NSError *error))handler;

/**
 Sets the current user's now playing track with the given parameters
 @param name the track name
 @param album the name of the track's album
 @param artist the name of the track's artist
 @param albumArtist the name of the track's album artist
 @param track the track number
 @param duration the duration of the track
 @param timestamp the timestamp at which the track was played --> use [NSNumber numberWithInteger:[[NSDate date] timeIntervalSince1970]] because the timestamp *must* be an integer
 @param handler a completion handler block
 */
- (void)updateNowPlayingTrackWithName:(NSString*)name album:(NSString*)album artist:(NSString*)artist albumArtist:(NSString*)albumArtist trackNumber:(NSInteger)trackNumber duration:(NSInteger)duration completionHandler:(void (^)(NSDictionary *response, NSError *error))handler;
- (void)loveTrackWithName:(NSString*)name artist:(NSString*)artist completionHandler:(void (^)(NSDictionary *response, NSError *error))handler;

#pragma mark - Artwork

- (void)infoForAlbumWithName:(NSString*)name artist:(NSString*)artist completionHandler:(void (^)(NSDictionary *response, NSError *error))handler;
- (void)artworkDataForAlbumWithName:(NSString*)name artist:(NSString*)artist completionHandler:(void (^)(NSData *data, NSError *error))handler;
@end
