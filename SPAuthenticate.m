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

-(void) getPermissions:(PermissionsSuccessBlock)success failure:(ResourceFailureBlock)failure{
    
}

-(void) login:(LoginSuccessBlock)success failure:(ResourceFailureBlock)failure{
    
    [self.objectManager.HTTPClient setDefaultHeader:@"x-cube-email"    value:self.username];
    [self.objectManager.HTTPClient setDefaultHeader:@"x-cube-password" value:self.password];
    
    //success and failure are on the heap by virtue of being copied when passed as method parameters
    //    __weak LoginSuccessBlock weakSuccess = success;
    //    __weak ResourceFailureBlock weakFailure = failure;
    
    [self.objectManager.HTTPClient getPath:@"login" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
//        __strong LoginSuccessBlock localScopeSuccess = weakSuccess;
//        __strong ResourceFailureBlock localScopeFailure = weakFailure;
        
        //make sure the response object is a dictionary
        /*
        if([responseObject isKindOfClass:[NSDictionary class]]){
            NSNumber *errorCode;
            NSString *errorMessage;
            BOOL successFlag = [SPRemoteResource responseSanityCheck:responseObject errorCode:&errorCode errorMessage:&errorMessage];
            if(successFlag == FALSE){
                if(errorCode && errorMessage){
                    failure(errorCode.integerValue,errorMessage,nil);
                }else{
                    failure(0,nil,[NSError errorWithDomain:@"Login Request" code:WRONG_OBJECT userInfo:@{NSLocalizedDescriptionKey:@"Success flag is false"}]);
                }
            }else{
                [SPRemoteResource configureWithResponse:responseObject];
                success();
            }
        }else{
            failure(0,nil,[NSError errorWithDomain:@"Login Request" code:SUCCESS_FLAG_FALSE userInfo:@{NSLocalizedDescriptionKey:@"The object returned by the request was not a dictionary."}]);
        }*/
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
