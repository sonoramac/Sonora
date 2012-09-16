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

#import "SNRLastFMEngine.h"
#import "INKeychainAccess.h"
#import "AFJSONRequestOperation.h"

#import "NSString-SNRAdditions.h"

#define K_ITEM_SERVICE @"Last.fm (com.iktm.Sonora)"

#define ERROR_DOMAIN @"LastFMErrorDomain"
#define DEFAULT_ERROR_CODE 9999
#define AUTH_ROOT_URL @"http://www.last.fm/api/auth/"

@interface SNRLastFMEngine ()
- (NSString*)methodSignatureWithParameters:(NSDictionary*)parameters;
- (NSData*)generatePOSTBodyWithParameters:(NSDictionary*)params;
- (NSString*)generateGETRequestURLWithParameters:(NSDictionary*)params;
- (NSError*)errorWithDictionary:(NSDictionary*)dictionary;
- (void)storeCredentialsWithUsername:(NSString*)username sessionKey:(NSString*)key error:(NSError**)error;
- (NSURLRequest*)URLRequestForMethod:(NSString*)method withParameters:(NSDictionary*)params requireAuth:(BOOL)auth HTTPMethod:(SNRHTTPMethod)http;
@property (nonatomic, retain) NSString *sk;
@end

@implementation SNRLastFMEngine {
    NSString *_username;
	NSString *_sk;
    NSOperationQueue *_queue;
}
@synthesize username = sUsername, sk = sSk;

#pragma mark -
#pragma mark Initialization

- (id)initWithUsername:(NSString*)user
{
	if ((self = [super init])) {
		self.username = user;
        _queue = [NSOperationQueue new];
	}
	return self;
}

+ (id)lastFMEngine
{
	return [[self alloc] initWithUsername:nil];
}

+ (id)lastFMEngineWithUsername:(NSString*)user
{
	return [[self alloc] initWithUsername:user];
}

+ (SNRLastFMEngine*)sharedInstance
{
    static SNRLastFMEngine *engine;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        engine = [[self alloc] initWithUsername:nil];
    });
    return engine;
}

#pragma mark -
#pragma mark Accessors

- (void)setUsername:(NSString *)newUsername
{
	if (_username != newUsername) {
		_username = newUsername;
        if ([_username length]) {
            NSString *key = [INKeychainAccess passwordForAccount:_username serviceName:K_ITEM_SERVICE error:nil];
            self.sk = key;
        } else {
            self.sk = nil;
        }
	}
}

#pragma mark -
#pragma mark Basic

- (NSURLRequest*)URLRequestForMethod:(NSString*)method withParameters:(NSDictionary*)params requireAuth:(BOOL)auth HTTPMethod:(SNRHTTPMethod)http
{
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionaryWithDictionary:params];
	[requestParameters setObject:method forKey:@"method"];
	[requestParameters setObject:kLastFMAPIKey forKey:@"api_key"];
	[requestParameters addEntriesFromDictionary:params];
	if (auth) {
		if (self.sk) { [requestParameters setObject:self.sk forKey:@"sk"]; }
		[requestParameters setObject:[self methodSignatureWithParameters:requestParameters] forKey:@"api_sig"];
	}
    [requestParameters setObject:@"json" forKey:@"format"];
    BOOL usingGET = (http == SNRHTTPMethodGET);
    NSURL *requestURL = usingGET ? [NSURL URLWithString:[self generateGETRequestURLWithParameters:requestParameters]] : [NSURL URLWithString:API_ROOT];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
	[request setHTTPMethod:usingGET ? @"GET" : @"POST"];
    if (!usingGET) {
        NSData *postData = [self generatePOSTBodyWithParameters:requestParameters];
        NSString *postLength = [NSString stringWithFormat:@"%lu", [postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
    }
    return request;
}

- (void)callMethod:(NSString*)method withParameters:(NSDictionary*)params requireAuth:(BOOL)auth HTTPMethod:(SNRHTTPMethod)http completionBlock:(void (^)(NSDictionary *response, NSError *error))handler
{
	NSURLRequest *request = [self URLRequestForMethod:method withParameters:params requireAuth:auth HTTPMethod:http];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
        if (handler) { handler(JSON, nil); }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (handler) { handler(nil, error); }
    }];
    [_queue addOperation:operation];
}

#pragma mark -
#pragma mark Authentication

#pragma mark -
#pragma mark Web Authentication

+ (NSURL*)webAuthenticationURLWithCallbackURL:(NSURL*)callback
{
    NSMutableString *URLString = [NSMutableString stringWithFormat:@"%@?api_key=%@", AUTH_ROOT_URL, kLastFMAPIKey];
    if (callback) { [URLString appendFormat:@"&cb=%@", callback]; }
    return [NSURL URLWithString:URLString];
}

#pragma mark -
#pragma mark Desktop Authentication

- (void)retrieveAuthenticationToken:(void (^)(NSString *token, NSError *error))handler;
{
    __weak SNRLastFMEngine *weakSelf = self;
	[self callMethod:@"auth.getToken" withParameters:nil requireAuth:YES HTTPMethod:SNRHTTPMethodGET completionBlock:^(NSDictionary *response, NSError *blockError){
        SNRLastFMEngine *strongSelf = weakSelf;
		NSString *token = [response valueForKey:@"token"];
		if (!token && response && !blockError) { // Create an error if the token is not found
            blockError = [strongSelf errorWithDictionary:response]; 
        } 
		if (handler) { handler(token, blockError); } // Call completion handler
	}];
}

+ (NSURL*)authenticationURLWithToken:(NSString*)token
{
	NSString *URLString = [NSString stringWithFormat:@"%@?api_key=%@&token=%@", AUTH_ROOT_URL, kLastFMAPIKey, token];
	return [NSURL URLWithString:URLString];
}

#pragma mark -
#pragma mark Mobile Authentication

- (void)retrieveAndStoreSessionKeyWithUsername:(NSString*)username password:(NSString*)password completionHandler:(void (^)(NSError *error))handler;
{
    NSString *authToken = [[NSString stringWithFormat:@"%@%@", [username lowercaseString], [password MD5]] MD5];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:username, @"username", authToken, @"authToken", nil];
    [self callMethod:@"auth.getMobileSession" withParameters:parameters requireAuth:YES HTTPMethod:SNRHTTPMethodGET completionBlock:^(NSDictionary *response, NSError *error) {
        if (!error) {
            NSDictionary *session = [response valueForKey:@"session"];
            NSString *key = [session valueForKey:@"key"];
            NSString *user = [session valueForKey:@"name"];
            [self storeCredentialsWithUsername:user sessionKey:key error:&error];
        }
        if (handler) { handler(error); }
    }];
}

#pragma mark -
#pragma mark Keychain Access

+ (BOOL)userHasStoredCredentials:(NSString*)user
{
    NSString *key = [INKeychainAccess passwordForAccount:user serviceName:K_ITEM_SERVICE error:nil];
	return [key length] != 0;
}

+ (void)removeCredentialsForUser:(NSString*)user
{
    [INKeychainAccess removeKeychainItemForAccount:user serviceName:K_ITEM_SERVICE error:nil];
}

- (void)retrieveAndStoreSessionKeyWithToken:(NSString*)token completionHandler:(void (^)(NSString *user, NSError *error))handler
{
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:token, @"token", nil];
	[self callMethod:@"auth.getSession" withParameters:params requireAuth:YES HTTPMethod:SNRHTTPMethodGET completionBlock:^(NSDictionary *response, NSError *blockError){
        NSString *user = nil;
		if (!blockError) { 
			NSDictionary *sessionDict = [response valueForKey:@"session"];
            NSString *key = [sessionDict valueForKey:@"key"]; // Parse JSON and obtain key and username
            user = [sessionDict valueForKey:@"name"];
			[self storeCredentialsWithUsername:user sessionKey:key error:&blockError];
		}
        if (handler) { handler(user, blockError); } // Call completion handler
	}];
}

- (BOOL)isAuthenticated
{
    return (self.sk != nil);
}

#pragma mark -
#pragma mark Scrobbling

- (void)scrobbleTrackWithName:(NSString*)name album:(NSString*)album artist:(NSString*)artist albumArtist:(NSString*)albumArtist trackNumber:(NSInteger)trackNumber duration:(NSInteger)duration timestamp:(NSInteger)timestamp completionHandler:(void (^)(NSDictionary *scrobbles, NSError *error))handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (name) { [params setObject:name forKey:@"track"]; }
    if (album) { [params setObject:album forKey:@"album"]; }
    if (artist) { [params setObject:artist forKey:@"artist"]; }
    if (albumArtist) { [params setObject:albumArtist forKey:@"albumArtist"]; }
    if (trackNumber) { [params setObject:[NSNumber numberWithInteger:trackNumber] forKey:@"trackNumber"]; }
    if (duration) { [params setObject:[NSNumber numberWithInteger:duration] forKey:@"duration"]; }
    if (timestamp) { [params setObject:[NSNumber numberWithInteger:timestamp] forKey:@"timestamp"]; }
    [self callMethod:@"track.scrobble" withParameters:params requireAuth:YES HTTPMethod:SNRHTTPMethodPOST completionBlock:^(NSDictionary *response, NSError *blockError) {
        if (handler) { handler(response, blockError); }
    }];
}

- (void)updateNowPlayingTrackWithName:(NSString*)name album:(NSString*)album artist:(NSString*)artist albumArtist:(NSString*)albumArtist trackNumber:(NSInteger)trackNumber duration:(NSInteger)duration completionHandler:(void (^)(NSDictionary *response, NSError *error))handler
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (name) { [params setObject:name forKey:@"track"]; }
    if (album) { [params setObject:album forKey:@"album"]; }
    if (artist) { [params setObject:artist forKey:@"artist"]; }
    if (albumArtist) { [params setObject:albumArtist forKey:@"albumArtist"]; }
    if (trackNumber) { [params setObject:[NSNumber numberWithInteger:trackNumber] forKey:@"trackNumber"]; }
    if (duration) { [params setObject:[NSNumber numberWithInteger:duration] forKey:@"duration"]; }
    [self callMethod:@"track.updateNowPlaying" withParameters:params requireAuth:YES HTTPMethod:SNRHTTPMethodPOST completionBlock:^(NSDictionary *response, NSError *blockError) {
        if (handler) { handler(response, blockError); }
    }];
}

- (void)infoForAlbumWithName:(NSString*)name artist:(NSString*)artist completionHandler:(void (^)(NSDictionary *response, NSError *error))handler
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:name, @"album", artist, @"artist", self.username, @"username", nil];
    [self callMethod:@"album.getInfo" withParameters:params requireAuth:NO HTTPMethod:SNRHTTPMethodGET completionBlock:^(NSDictionary *response, NSError *error) {
        if (handler) { handler(response, error); }
    }];
}

- (void)loveTrackWithName:(NSString*)name artist:(NSString*)artist completionHandler:(void (^)(NSDictionary *response, NSError *error))handler
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:name, @"track", artist, @"artist", nil];
    [self callMethod:@"track.love" withParameters:params requireAuth:YES HTTPMethod:SNRHTTPMethodPOST completionBlock:^(NSDictionary *response, NSError *error) {
        if (handler) { handler(response, error); }
    }];
}

- (void)artworkDataForAlbumWithName:(NSString*)name artist:(NSString*)artist completionHandler:(void (^)(NSData *data, NSError *error))handler
{
    [self infoForAlbumWithName:name artist:artist completionHandler:^(NSDictionary *response, NSError *error) {
        NSDictionary *album = [response valueForKey:@"album"];
        NSArray *images = [album valueForKey:@"image"];
        NSString *imageURL = nil;
        for (NSDictionary *image in images) {
            NSString *size = [image valueForKey:@"size"];
            if ([size isEqualToString:@"mega"]) {
                imageURL = [image valueForKey:@"#text"];
            }
        }
        if (imageURL) {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageURL]];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (handler) { handler(responseObject, nil); }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (handler) { handler(nil, error); }
            }];
            [_queue addOperation:operation];
        } else if (handler) {
            handler(nil, nil);
        }
    }];
}

#pragma mark -
#pragma mark Private

- (NSString*)methodSignatureWithParameters:(NSDictionary*)parameters
{
	NSArray *keys = [[parameters allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	NSMutableString *parameterString = [NSMutableString string];
	for (NSString *key in keys) { // Append each of the key-value pairs in alphabetical order
		[parameterString appendString:key];
		[parameterString appendString:[[parameters valueForKey:key] description]];
	}
	[parameterString appendString:kLastFMAPISecret]; // Append secret
	return [parameterString MD5]; // Create an MD5 hash
}

- (NSData*)generatePOSTBodyWithParameters:(NSDictionary*)params
{
    NSMutableString *requestURL = [NSMutableString string];
	NSArray *keys = [params allKeys];
	for (NSString *key in keys) {
		[requestURL appendFormat:@"%@=%@&", key, [[[params valueForKey:key] description] URLEncodedString]]; // Append each key
	}
    [requestURL deleteCharactersInRange:NSMakeRange([requestURL length] - 1, 1)];
    return [requestURL dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString*)generateGETRequestURLWithParameters:(NSDictionary*)params
{
	NSMutableString *requestURL = [NSMutableString stringWithFormat:@"%@?", API_ROOT];
	NSArray *keys = [params allKeys];
	for (NSString *key in keys) {
		[requestURL appendFormat:@"%@=%@&", key, [[[params valueForKey:key] description] URLEncodedString]]; // Append each key
	}
    [requestURL deleteCharactersInRange:NSMakeRange([requestURL length] - 1, 1)];
	return requestURL;
}

- (NSError*)errorWithDictionary:(NSDictionary*)dictionary
{
	NSNumber *errorCode = [dictionary valueForKey:@"error"];
    if (!errorCode) { return nil; }
	NSString *message = [dictionary valueForKey:@"message"];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message, NSLocalizedDescriptionKey, nil];
	// Create an error object with the error information returned by the API
	return [NSError errorWithDomain:ERROR_DOMAIN code:[errorCode integerValue] userInfo:userInfo];
}

- (void)storeCredentialsWithUsername:(NSString*)username sessionKey:(NSString*)key error:(NSError**)error
{
    NSError *keychainError = nil;
    if (![INKeychainAccess passwordForAccount:username serviceName:K_ITEM_SERVICE error:nil]) {
        [INKeychainAccess addKeychainItemForAccount:username withPassword:key serviceName:K_ITEM_SERVICE error:&keychainError];
    } else {
        [INKeychainAccess setPassword:key forAccount:username serviceName:K_ITEM_SERVICE error:&keychainError];
    }
    if (keychainError && error) {
        *error = keychainError;
    }
    self.username = username;
}
@end
