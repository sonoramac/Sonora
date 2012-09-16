//
//  SNRDiscogsEngine.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-11-18.
//

#import "SNRDiscogsEngine.h"
#import "AFJSONRequestOperation.h"

static NSString* const kDiscogsUserAgent = @"Sonora/1.0 +http://getsonora.com";
static NSString* const kDiscogsAPIBaseURL = @"http://api.discogs.com/";

@interface SNRDiscogsEngine ()
- (NSURLRequest*)discogsRequestWithMethod:(NSString*)method parameters:(NSDictionary*)params;
- (NSURLRequest*)discogsRequestWithURL:(NSURL*)url;
@end

@implementation SNRDiscogsEngine {
    NSOperationQueue *_queue;
}

- (id)init
{
    if ((self = [super init])) {
        _queue = [NSOperationQueue new];
    }
    return self;
}

- (NSURLRequest*)discogsRequestWithMethod:(NSString*)method parameters:(NSDictionary*)params;
{
    NSMutableString *parameters = [NSMutableString string];
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        [parameters appendFormat:@"%@=%@&", key, [[value description] URLEncodedString]];
    }
    NSString *path = [kDiscogsAPIBaseURL stringByAppendingFormat:@"%@?%@", method, parameters];
    return [self discogsRequestWithURL:[NSURL URLWithString:path]];
}

- (NSURLRequest*)discogsRequestWithURL:(NSURL*)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:kDiscogsUserAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    return request;
}

- (void)releaseURLForAlbumWithTitle:(NSString*)title artist:(NSString*)artist completionHandler:(void (^)(NSURL *url, NSError *error))handler
{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"release", @"type", artist, @"artist", title, @"release_title", nil];
    NSURLRequest *request = [self discogsRequestWithMethod:@"database/search" parameters:parameters]; 
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
        if (handler) {
            NSArray *results = [JSON objectForKey:@"results"];
            if ([results count]) {
                NSDictionary *result = [results objectAtIndex:0];
                NSString *resource = [result valueForKey:@"resource_url"];
                if (resource) { handler((resource != nil) ? [NSURL URLWithString:resource] : nil, nil); }
            } else {
                handler(nil, nil);
            }
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (handler) { handler(nil, error); }
    }];
    [_queue addOperation:operation];
}

- (void)artworkURLForAlbumWithTitle:(NSString*)title artist:(NSString*)artist completionHandler:(void (^)(NSURL *url, NSError *error))handler
{
    __weak SNRDiscogsEngine *weakSelf = self;
    [self releaseURLForAlbumWithTitle:title artist:artist completionHandler:^(NSURL *url, NSError *error) {
        if (handler) {
            if (url) {
                SNRDiscogsEngine *strongSelf = weakSelf;
                NSURLRequest *request = [strongSelf discogsRequestWithURL:url];
                AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSURLResponse *response, id JSON) {
                    NSArray *images = [JSON objectForKey:@"images"];;
                    for (NSDictionary *image in images) {
                        if ([[image valueForKey:@"type"] isEqualToString:@"primary"]) {
                            NSString *resource = [image valueForKey:@"resource_url"];
                            handler((resource != nil) ? [NSURL URLWithString:resource] : nil, nil);
                            break;
                        }
                    } 
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    handler(nil, error);
                }];
                [strongSelf->_queue addOperation:operation];
            } else if (error) {
                handler(nil, error);
            } else {
                handler(nil, nil);
            }
        }
    }];
}

- (void)artworkDataForAlbumWithTitle:(NSString*)title artist:(NSString*)artist completionHandler:(void (^)(NSData *data, NSError *error))handler
{
    __weak SNRDiscogsEngine *weakSelf = self;
    [self artworkURLForAlbumWithTitle:title artist:artist completionHandler:^(NSURL *url, NSError *error) {
        if (handler) {
            if (url) {
                SNRDiscogsEngine *strongSelf = weakSelf;
                NSURLRequest *request = [strongSelf discogsRequestWithURL:url];
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if (handler) { handler(responseObject, nil); }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if (handler) { handler(nil, error); }
                }];
                [strongSelf->_queue addOperation:operation];
            } else if (error) {
                handler(nil, error);
            } else {
                handler(nil, nil);
            }
        }
    }];
}
@end
