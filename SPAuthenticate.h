//
//  SPAuthenticate.h
//  SlidePayCore
//
//  Created by Alex Garcia on 9/24/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import "SPRemoteResource.h"


typedef void(^LoginSuccessBlock)();
typedef void(^PermissionsSuccessBlock)();

/**
 *  Interacting with our remote layer requires authentication. We provide two ways of doing this:
 
    API Key Authentication - not available w/ the iOS SDK (yet)
    Username/Password  Authenitcation - @see -loginWithSuccess:failure:
*/

@interface SPAuthenticate : SPRemoteResource

@property (nonatomic) NSString *username;
@property (nonatomic) NSString *password;
//@property (nonatomic) NSString *token;


-(void) login:(LoginSuccessBlock)success failure:(ResourceFailureBlock)failure;
-(void) getPermissions:(PermissionsSuccessBlock)success failure:(ResourceFailureBlock)failure;

@end
