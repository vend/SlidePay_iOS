//
//  SlidePayCore.h
//  SlidePayCore
//
//  Created by Anderthan Hsieh on 8/7/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlidePayUserMaster : NSObject

@property (strong, nonatomic) NSNumber *userMasterID;
@property (strong, nonatomic) NSNumber *companyID;
@property (strong, nonatomic) NSNumber *locationID;
@property (strong, nonatomic) NSNumber *firstName;
@property (strong, nonatomic) NSNumber *lastName;

@end

/*
 SlidePayLoginObject -
 */
@interface SlidePayLoginObject : NSObject

typedef enum {
    IS_CLERK,
    IS_LOCMGR,
    IS_COMGR
}USER_PERMISSION_LEVEL;

typedef enum {
    LOGIN_FAILURE_INVALID_ACCOUNT,
    LOGIN_FAILURE_INVALID_CREDENTIALS,
    LOGIN_FAILURE_CONNECTIVITY,
    LOGIN_FAILURE_OTHER
}LOGIN_FAILURE_TYPE;

@property (retain, nonatomic) NSString *slidePayToken;
@property (retain, nonatomic) NSString *slidePayEndpoint;
@property (retain, nonatomic) SlidePayUserMaster *slidePayUser;
@property (retain, nonatomic) NSString *companyName;
@property (retain, nonatomic) NSString *locationName;
@property USER_PERMISSION_LEVEL userPermissionLevel;

@end

@protocol SlidePayCoreDelegate <NSObject>

- (void) loginRequestCompletedWithData: (SlidePayLoginObject *) loginObject withError: (NSError *) error;

@end


@interface SlidePayCore : NSObject

+ (SlidePayCore *) sharedInstance;

- (void) loginWithEmail: (NSString *) emailAddress withPassword: (NSString *) password;

@property (weak, nonatomic) id <SlidePayCoreDelegate> slidePayCoreDelegate;

@end




