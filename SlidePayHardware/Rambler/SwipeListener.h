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
#define KEY_TRACK @"encTracks"
#define KEY_EXP @"expiryDate"
#define KEY_NAME @"cardHolderName"
#define KEY_MASKED @"maskedPAN"
#define KEY_SERVICE @"serviceCode"

//these are they keys present in the dictionary passed to the RamblerSwipeComplete block. The keys in this dictionary mirror those necessary to make a payment through the payment API.
#define SPKEY_KSN      @"encryption_ksn"
#define SPKEY_VENDOR   @"encryption_vendor"
#define SPKEY_TRACK1   @"cc_track2data"
#define SPKEY_MONTH    @"cc_expiry_month"
#define SPKEY_YEAR     @"cc_expiry_year"
#define SPKEY_METHOD   @"method"
#define SPKEY_NOTES    @"notes"
#define SPKEY_AMOUNT   @"amount"


typedef enum RamblerState {
    DEVICE_UNPLUGGED        = 0,
    DEVICE_PLUGGED_IN       = 1,
    DEVICE_WAITING          = 2, //waiting for the device to be plugged in
    DEVICE_IDLE             = 3, //device has been stopped. Call -start to begin swiping
    DEVICE_WAITING_SWIPE    = 4, //waiting for a swipe
    DEVICE_RECORDING        = 5, //recording the swipe
    DEVICE_DECODING         = 6  //decoding the swipe
}RamblerState;

typedef void(^RamblerStatusChanged)(RamblerState status);
typedef void(^RamblerSwipeComplete)(NSDictionary *swipe,int errorCode, NSString *errorMessage);


@interface SwipeListener : NSObject

@property (copy) RamblerStatusChanged stateChangedBlock;
@property (copy) RamblerSwipeComplete swipeCompleteBlock;
@property (strong) ReaderController *readerController;

+ (SwipeListener *)sharedListener;

-(void) start;
-(void) stop;
-(void) testSwipe;
-(RamblerState) state;

@end
