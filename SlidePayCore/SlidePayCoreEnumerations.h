//
//  SlidePayCoreEnumerations.h
//  SlidePayCore
//
//  Created by Anderthan Hsieh on 8/8/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#ifndef SlidePayCore_SlidePayCoreEnumerations_h
#define SlidePayCore_SlidePayCoreEnumerations_h

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

#endif
