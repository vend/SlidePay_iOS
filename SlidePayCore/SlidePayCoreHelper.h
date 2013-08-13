//
//  SlidePayCoreHelper.h
//  SlidePayCore
//
//  Created by Anderthan Hsieh on 8/12/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import <Foundation/Foundation.h>

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

typedef enum {
    CC_VISA,
    CC_MASTERCARD,
    CC_AMEX,
    CC_DISCOVER,
    CC_ERROR
} CC_CARD_TYPE;

typedef enum {
    PAYMENT_FAILURE_AMOUNT_TOO_SMALL,
    PAYMENT_FAILURE_NO_LOCATION,
    PAYMENT_FAILURE_INVALID_FIELDS,
    PAYMENT_FAILURE_MAINTENANCE,
    PAYMENT_FAILURE_NO_REASON
}PAYMENT_FAILURE_REASON;

typedef enum {
    DEVICE_ENCRYPTED_AUDIO,
    DEVICE_MAGTEK_IDYNAMO
}DEVICE_TYPE;

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

@property (retain, nonatomic) NSString *slidePayToken;
@property (retain, nonatomic) NSString *slidePayEndpoint;
@property (retain, nonatomic) SlidePayUserMaster *slidePayUser;
@property (retain, nonatomic) NSString *companyName;
@property (retain, nonatomic) NSString *locationName;
@property USER_PERMISSION_LEVEL userPermissionLevel;

@end

@interface SlidePayCoreHelper : NSObject



@end
