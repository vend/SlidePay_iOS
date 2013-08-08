//
//  SlidePayCore.m
//  SlidePayCore
//
//  Created by Anderthan Hsieh on 8/7/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import "SlidePayCore.h"


static SlidePayCore *_shared_model = nil;





@implementation SlidePayCore {
    NSString *myEndpointString;
    NSString *myPassword;
    NSString *myEmailAddress;
    NSString *myUserToken;
    NSMutableURLRequest *request;
    SlidePayLoginObject *loginObject;
}

@synthesize mySlidePayCoreDelegate;

+ (SlidePayCore *) sharedInstance {
    if (!_shared_model) {
        _shared_model = [[SlidePayCore alloc] init];
    }
    
    return _shared_model;
}

/*
 The logic behind logging in is the following.
 
 1.  User supplies e-mail address and password
 2.  We then first make a call to supervisor to check to see if the e-mail and password is legit. (REST call #1)
 3.  After obtaining the endpoint, I then make a call to /api/login addressing the correct endpoint (REST call #2)
 4.  After a successful login, I then make a call to /token/detail.  (REST call #3)
 
 After receiving all of this information, I will then construct an object to pass back which contains constructed information coming from /api/login and /token/detail
 */

- (void) loginWithEmail: (NSString *) emailAddress withPassword: (NSString *) password {
    NSError *loginError = nil;
    
    //We first need to make sure that the e-mail address provided and password passes basic validation (can't be nil or empty).
    if (![self validateLoginFieldsWithEmail:emailAddress withPassword:password]) {
        loginError = [NSError errorWithDomain:@"Attempting to login with invalid credentials" code:LOGIN_FAILURE_INVALID_CREDENTIALS userInfo:nil];
        return [self.mySlidePayCoreDelegate loginRequestCompletedWithData:nil withError:loginError];
    }
    
    //Next we make to supervisor to see which endpoint we need to specify
    NSURL *supervisorURL = [NSURL URLWithString:@"https://supervisor.getcube.com:65532/rest.svc/API/endpoint"];
    request = [[NSMutableURLRequest alloc] initWithURL:supervisorURL];
    request.HTTPMethod = @"GET";
    [request setValue:emailAddress forHTTPHeaderField:@"x-cube-email"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSError *supervisorError = [NSError errorWithDomain:@"Unable to obtain endpoint from e-mail address" code:LOGIN_FAILURE_INVALID_ACCOUNT userInfo:nil];
            [self.mySlidePayCoreDelegate loginRequestCompletedWithData:nil withError:supervisorError];
        }
        else {
            myPassword = password;
            myEmailAddress = emailAddress;
            [self processSupervisorData:data];
        }
            }];
    
}



#pragma mark - Private Helpers
/*
 processSupervisorData - this will take 
 */
- (void) processSupervisorData: (NSData *) data {
    NSError *error = nil;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    //need to do something if success = 0
    NSNumber *mySuccessNumber = (NSNumber *)[responseDictionary objectForKey:@"success"];
    if (mySuccessNumber.boolValue) {
        myEndpointString = (NSString *)[responseDictionary objectForKey:@"data"];
        [self loginToBackend];
    }
    else {
        NSError *supervisorError = [NSError errorWithDomain:@"Unable to obtain endpoint from e-mail address" code:LOGIN_FAILURE_INVALID_ACCOUNT userInfo:nil];
        [self.mySlidePayCoreDelegate loginRequestCompletedWithData:nil withError:supervisorError];
    }
        
}

//This method is called after a successful call to the backend for the endpoint
- (void) loginToBackend {
    NSURL *myLoginURL = [[SlidePayCore sharedInstance] urlByAppendingPath:@"login"];
    request = [[NSMutableURLRequest alloc] initWithURL:myLoginURL];
    request.HTTPMethod = @"GET";
    [request setValue:myEmailAddress forHTTPHeaderField:@"x-cube-email"];
    [request setValue:myPassword forHTTPHeaderField:@"x-cube-password"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSError * loginError = [NSError errorWithDomain:@"Attempting to login with invalid credentials" code:LOGIN_FAILURE_INVALID_CREDENTIALS userInfo:nil];
            [self.mySlidePayCoreDelegate loginRequestCompletedWithData:nil withError:loginError];
        }
       else {
           [self processLoginData:data];
       }
    }];
}

- (void) processLoginData: (NSData *) data {
    NSError *error = nil;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    NSNumber *mySuccessNumber = (NSNumber *)[responseDictionary objectForKey:@"success"];
    if (mySuccessNumber.boolValue) {
        NSString *tokenString = [responseDictionary objectForKey:@"data"];
        [request setValue:tokenString forHTTPHeaderField:@"x-cube-token"];
        
        myUserToken = tokenString;
        
        [self obtainTokenDetailFromBackend];
        
    }
    else {
        NSError * loginError = [NSError errorWithDomain:@"Attempting to login with invalid credentials" code:LOGIN_FAILURE_INVALID_CREDENTIALS userInfo:nil];
        [self.mySlidePayCoreDelegate loginRequestCompletedWithData:nil withError:loginError];
    }

}

//This method is called after a successful login call to the backend
- (void) obtainTokenDetailFromBackend {
    NSURL *myTokenDetailURL = [[SlidePayCore sharedInstance] urlByAppendingPath:@"token/detail"];
    [request setURL:myTokenDetailURL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSError * tokenDetailError = [NSError errorWithDomain:@"Unable to retrieve information from token detail" code:LOGIN_FAILURE_CONNECTIVITY userInfo:nil];
            [self.mySlidePayCoreDelegate loginRequestCompletedWithData:nil withError:tokenDetailError];
        }
        else {
            [self processTokenDetailData:data];
        }
    }];
}

- (void) processTokenDetailData: (NSData *) data {
    NSError *error = nil;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    NSNumber *mySuccessNumber = (NSNumber *)[responseDictionary objectForKey:@"success"];
    if (mySuccessNumber.boolValue) {
        NSDictionary *dataDictionary = (NSDictionary *)[responseDictionary objectForKey:@"data"];
        loginObject = [[SlidePayLoginObject alloc] init];
        
        loginObject.slidePayEndpoint = myEndpointString;
        loginObject.companyName = [dataDictionary objectForKey:@"company_name"];
        loginObject.locationName = [dataDictionary objectForKey:@"location_name"];
        loginObject.slidePayToken = myUserToken;
        
        if (((NSNumber *)[dataDictionary objectForKey:@"is_comgr"]).intValue > 0)
            loginObject.userPermissionLevel = IS_COMGR;
        else if (((NSNumber *)[dataDictionary objectForKey:@"is_locmgr"]).intValue > 0)
            loginObject.userPermissionLevel = IS_LOCMGR;
        else
            loginObject.userPermissionLevel = IS_CLERK;
        
        //Need to setup the user detail
        SlidePayUserMaster *temporaryUserMaster = [[SlidePayUserMaster alloc] init];
        temporaryUserMaster.firstName = [dataDictionary objectForKey:@"first_name"];
        temporaryUserMaster.lastName = [dataDictionary objectForKey:@"last_name"];
        temporaryUserMaster.userMasterID = [NSNumber numberWithInt:[[dataDictionary objectForKey:@"user_master_id"] intValue]];
        temporaryUserMaster.companyID = [NSNumber numberWithInt:[[dataDictionary objectForKey:@"company_id"] intValue]];
        temporaryUserMaster.locationID = [NSNumber numberWithInt:[[dataDictionary objectForKey:@"location_id"] intValue]];
        loginObject.slidePayUser = temporaryUserMaster;
        
        [self.mySlidePayCoreDelegate loginRequestCompletedWithData:loginObject withError:nil];
    }
    else {
        NSError * tokenDetailError = [NSError errorWithDomain:@"Unable to retrieve information from token detail" code:LOGIN_FAILURE_CONNECTIVITY userInfo:nil];
        [self.mySlidePayCoreDelegate loginRequestCompletedWithData:nil withError:tokenDetailError];
    }
}


- (BOOL) validateLoginFieldsWithEmail: (NSString *) emailAddress withPassword: (NSString *) password {
    if (!emailAddress || !password || emailAddress.length <= 0 || password.length <= 0)
        return false;
    else
        return true;
}


- (NSURL *) urlByAppendingPath: (NSString *) path {
    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:myEndpointString]];
}


@end

@implementation SlidePayUserMaster

@synthesize firstName,lastName,companyID,locationID,userMasterID;

@end

@implementation SlidePayLoginObject

@synthesize companyName,locationName,slidePayUser,slidePayEndpoint,userPermissionLevel, slidePayToken;

@end
