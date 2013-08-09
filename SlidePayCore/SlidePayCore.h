//
//  SlidePayCore.h
//  SlidePayCore
//
//  Created by Anderthan Hsieh on 8/7/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlidePayCoreEnumerations.h"

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

@protocol SlidePayCoreDelegate <NSObject>

- (void) loginRequestCompletedWithData: (SlidePayLoginObject *) loginObject withError: (NSError *) error;

@end

/*
 slidePayPaymentDelegate
 
 On a successful swipe, we will provide you with a NSDictionary.  All you will need to do is convert it to JSON.  We've provided a class method for you to to do so also.
 
 Example:
 
- (void) paymentDictionaryCreated: (NSDictionary *) simplePaymentDictionary {
 NSString *jsonRepresentationOfSimplePayment = [CubeSimplePayment convertIDToJSONString:simplePaymentDictionary]
 }
 
 On a failed swipe, the delegate will call swipeFailed.
 */

@protocol slidePayPaymentDelegate <NSObject>

- (void) paymentDictionaryCreated: (NSDictionary *) simplePaymentDictionary;
- (void) swipeFailed;
- (void) magtekConnected: (BOOL) on;
- (void) ramblerConnected: (BOOL) on;
- (void) magtekProcessingStarted;

@end



@interface SlidePayCore : NSObject

+ (SlidePayCore *) sharedInstance;

- (void) loginWithEmail: (NSString *) emailAddress withPassword: (NSString *) password;

@property (weak, nonatomic) id <SlidePayCoreDelegate> slidePayCoreDelegate;



/*
 This section is related to payments
 */

/*
 This is the amount that you will charge the user this.  You will need to set this amount before the user swipes, as the dictionary is formed with the amount from cube_amount_to_charge.
 */
@property double amountToCharge;
@property SlidePayUserMaster *userMaster;
@property (weak, nonatomic) id <slidePayPaymentDelegate> paymentDelegate;


/*
 If you want to turn off audio swipe detection for Rambler, use the method turnOnAudioSwipeDetection.
 
 To turn off audio swiping:
 [[CubeSimplePayment sharedInstance] turnOnAudioSwipeDetection:NO];
 
 To turn on audio swiping (when you initialize the sharedInstance, audio swiping is turned ON by default:
 [[CubeSimplePayment sharedInstance] turnOnAudioSwipeDetection:YES];
 */
- (void) turnOnAudioSwipeDetection: (BOOL) flag;

/*
 createTypedInCardArgumentsWithZip will require five fields (zip code, cvv, expiry month, expiry year, and the credit card number).  This is for keyed in transactions, and we will create an object from there and send it back to you through the paymentDictionaryCreated object.
 */
- (NSDictionary *) createCNPWithZip: (NSString *) zipCode withCVV: (NSString *) cvv withExpiryMonth: (NSString *) expiryMonth withExpiryYear: (NSString *) expiryYear withCardNumber: (NSString *) cardNumber;


/*
 Helper Methods
 */

//Allows you to convert id => json string to make web service calls easier
+ (NSString *) convertIDToJSONString: (id) object;

/*
 obtainCardTypeFromCardNumber: We take in a string which contains the card number.  We then use our regex to determine what type of card this is and return it back.  If it there is an error, we will return CC_ERROR.
 */

+ (CC_CARD_TYPE) obtainCardTypeFromCardNumber: (NSString*) cardNumber;
@end




