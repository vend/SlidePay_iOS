//
//  SlidePayCore.h
//  SlidePayCore
//
//  Created by Anderthan Hsieh on 8/7/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SlidePayCoreHelper.h"



/*
 slidePayPaymentDelegate
 
 On a successful swipe, we will provide you with a NSDictionary.  All you will need to do is convert it to JSON.  We've provided a class method for you to to do so also.
 
 Example:
 
 - (void) paymentDictionaryCreated: (NSDictionary *) simplePaymentDictionary {
 NSString *jsonRepresentationOfSimplePayment = [CubeSimplePayment convertIDToJSONString:simplePaymentDictionary]
 }
 
 On a failed swipe, the delegate will call swipeFailed.
 */

@class SlidePayCore;

@protocol SlidePayCoreDelegate <NSObject>

@optional
- (void) loginRequestCompletedWithData: (SlidePayLoginObject *) loginObject withError: (NSError *) error;
- (void) paymentFinishedWithResponse: (NSDictionary *) responseDictionary withError: (NSError *) error;
- (void) refundFinishedWithResponse: (NSDictionary *) responseDictionary withError: (NSError *) error;
- (void) swipeFailed;
- (void) readerConnected: (BOOL) flag withType: (DEVICE_TYPE) type;
- (void) readerProcessingStarted: (DEVICE_TYPE) type;

@optional
- (BOOL) didCreatePaymentDictionary:(NSMutableDictionary*)paymentDictionary; //if you return TRUE, or don't implement the method, then, upon return, the payment will be submitted automatically


@end





@interface SlidePayCore : NSObject

+ (SlidePayCore *) sharedInstance;

- (void) loginWithEmail: (NSString *) emailAddress withPassword: (NSString *) password;

@property (weak, nonatomic) id <SlidePayCoreDelegate> slidePayCoreDelegate;
@property SlidePayUserMaster *userMaster;


/*
 This section is related to payments
 */

/*
 This is the amount that you will charge the user.  You will need to set this amount before the user swipes, as the dictionary is formed with the amount from cube_amount_to_charge.
 */
@property double amountToCharge;
-(void) makePayment:(NSDictionary*)paymentDictionary; //when you implement -didCreatePaymentDictionary: and return FALSE, then you'll need to call this with your (potentially modified) paymentDictionary. If you call this with the dictionary from -didCreatePaymentDictionary: after returning TRUE, then you will MAKE A DUPLICATE PAYMENT.

/*
 If you want to turn off audio swipe detection for Rambler, use the method turnOnAudioSwipeDetection.
 
 To turn off audio swiping:
 [[SlidePayCore sharedInstance] turnOnAudioSwipeDetection:NO];
 
 To turn on audio swiping (when you initialize the sharedInstance, audio swiping is turned ON by default:
 [[SlidePayCore sharedInstance] turnOnAudioSwipeDetection:YES];
 */
- (void) turnOnAudioSwipeDetection: (BOOL) flag;

/*
 createTypedInCardArgumentsWithZip will require five fields (zip code, cvv, expiry month, expiry year, and the credit card number).  This is for keyed in transactions, and we will create an object from there and send it back to you through the paymentDictionaryCreated object.
 */
- (void) createCNPWithZip: (NSString *) zipCode withCVV: (NSString *) cvv withExpiryMonth: (NSString *) expiryMonth withExpiryYear: (NSString *) expiryYear withCardNumber: (NSString *) cardNumber;
- (void) refundPayment: (int) paymentID;

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




