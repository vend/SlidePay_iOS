//
//  SwipeListener.h
//  SlidePayCore
//
//  Created by Alex Garcia on 10/4/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReaderController.h"

//these are the keys to the dictionary returned through the ReaderAPI
#define KEY_KSN @"ksn"
#define KEY_TRACK @"encTrack"
#define KEY_EXP @"expiryDate"
#define KEY_NAME @"cardHolderName"
#define KEY_MASKED @"maskedPAN"

//these are they keys present in the dictionary passed to the RamblerSwipeComplete block. The keys in this dictionary mirror those necessary to make a payment through the payment API.
#define SPKEY_KSN      @"encryption_ksn"
#define SPKEY_VENDOR   @"encryption_vendor"
#define SPKEY_TRACK1   @"cc_track1data"
#define SPKEY_MONTH    @"cc_expiry_month"
#define SPKEY_YEAR     @"cc_expiry_year"
#define SPKEY_METHOD   @"method"
#define SPKEY_NOTES    @"notes"
#define SPKEY_AMOUNT   @"amount"


typedef enum RamblerState {
    DEVICE_UNPLUGGED  = 0,
    DEVICE_PLUGGED_IN = 1,
    DEVICE_IDLE       = 2,
    DEVICE_WAITING    = 3,
    DEVICE_RECORDING  = 4,
    DEVICE_DECODING   = 5
}RamblerState;

typedef void(^RamblerStatusChanged)(RamblerState status);
typedef void(^RamblerSwipeComplete)(NSDictionary *swipe,int errorCode, NSString *errorMessage);


@interface SwipeListener : NSObject

@property (copy) RamblerStatusChanged stateChangedBlock;
@property (copy) RamblerSwipeComplete swipeCompleteBlock;
@property (strong) ReaderController *readerController;

-(void) start;
-(void) stop;
-(void) testSwipe;
-(RamblerState) state;

@end
