//
//  SPAuthenticate.m
//  SlidePayCore
//
//  Created by Alex Garcia on 9/24/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import "SPAuthenticate.h"

@implementation SPAuthenticate

-(id) init{
    [SPRemoteResource reset];
    if (self = [super init]) {

    }
    return self;
}

-(void) dealloc{
    NSLog(@"DEALLOC *** SPAuthenticate");
}

//-(void) getPermissions:(PermissionsSuccessBlock)success failure:(ResourceFailureBlock)failure{

//}

-(void) login:(LoginSuccessBlock)success failure:(ResourceFailureBlock)failure{
    
    [self.objectManager.HTTPClient setDefaultHeader:@"x-cube-email"    value:self.username];
    [self.objectManager.HTTPClient setDefaultHeader:@"x-cube-password" value:self.password];
    
    //success and failure are on the heap by virtue of being copied when passed as method parameters
    [self.objectManager.HTTPClient getPath:@"login" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL goodToGo = [SPRemoteResource checkResponseObjectForSuccessFlag:responseObject failure:failure];
        if(goodToGo){
            [SPRemoteResource configureWithResponse:responseObject];
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSNumber *errorCode;
        NSString *errorMessage;
        [SPRemoteResource responseSanityCheck:[SPRemoteResource responseFromOperation:operation] errorCode:&errorCode errorMessage:&errorMessage];
        failure(errorCode ? errorCode.integerValue : 0,errorMessage,error);
    }];
    
}

@end
