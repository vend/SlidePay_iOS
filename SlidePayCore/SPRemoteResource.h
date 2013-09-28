//
//  SPRemoteResource.h
//  SlidePayCore
//
//  Created by Alex Garcia on 9/23/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

#define WRONG_OBJECT -1
#define SUCCESS_FLAG_FALSE -2




/**
 *  Typedef for the block response handler used when a remote resource request fails
 *
 *  @param serverCode    The SlidePay error code returned by the server.
 *  @param serverMessage A human readable string describing the server error. Can be nil.
 *  @param error         If an error occured during the request, it's provided here. Can be nil.
 */
typedef void(^ResourceFailureBlock)(NSInteger serverCode, NSString* serverMessage, NSError*error);

@interface SPRemoteResource : NSObject

/**
 *  The resource desginator portion of the URL.
 */
@property (nonatomic) NSString * resource;

/**
 *  The base URL for a network request.
 */
@property (nonatomic,readonly) NSString * endpoint;
@property (nonatomic,readonly) NSString * authToken;
@property (nonatomic,copy) RKObjectManager * objectManager;
@property (nonatomic,readonly) NSString * TAG;


+(void) configureWithResponse:(NSDictionary*)response;
+(NSIndexSet*) successCodes;
+(NSIndexSet*) failureCodes;
+(BOOL)responseSanityCheck:(NSDictionary*)response errorCode:(NSNumber**)errorCode errorMessage:(NSString**)errorMessage;
+(BOOL) checkResponseObjectForSuccessFlag:(id)responseObject failure:(ResourceFailureBlock)failure;
+(void)reset;
+(NSDictionary*)responseFromOperation:(AFHTTPRequestOperation*)operation;
//+(BOOL) checkResponseForSuccessFlag:(NSDictionary*)response;

//
+(RKObjectManager*) sharedManager;

@end
