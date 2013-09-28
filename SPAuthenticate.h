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

@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *password;

/**
 *  Logs you in.
 *
 *  @param success A block called when the login operation has completed successfully
 *  @param failure A block called when the login operation has failed to complete successfully
 */
-(void) login:(LoginSuccessBlock)success failure:(ResourceFailureBlock)failure;
//-(void) getPermissions:(PermissionsSuccessBlock)success failure:(ResourceFailureBlock)failure; coming soon

@end
