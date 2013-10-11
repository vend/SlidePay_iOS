//
//  SPPayment.h
//  SlidePayCore
//
//  Created by Alex Garcia on 9/23/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import "SPRemoteResource.h"
/**
 *  Typedef for the block response handler used when a payment is made successfully
 *
 *  @param paymentID    The paymentID for the processed payment.
 *  @param orderID      The orderID for the processed payment.
 *  @param responseData The complete response as a UTF-8 encoded JSON string.
 */
typedef void(^PaymentSuccessBlock)(NSInteger paymentID,NSInteger orderID,NSData* responseData);
/**
 *  A block to invoke when a refund completes successfully.
 *
 *  @param paymentID The payment id for the payment that was refunded.
 *  @param refundID  The unique identifier for the refund.
 */
typedef void(^RefundSuccess)(NSInteger paymentID);

/**
 *  A payment has been successfully retrieved from the backend.
 */
@class SPPayment;
typedef void(^GetPaymentSuccess)(SPPayment*);

/** This class governs the creation of objects that encapsulate a payment, performing a transaction using that payment, and refunding a payment. Authentication is required to use any method which creates, refunds, or retieves a payment.
 
 Card not present payments are initialized through initWithCardNumber:zipCode:cvv:expMonth:expYear:
 
 Card present payments are initialized through initWithPaymentDictionary:

 To pay, initialize the payment, set the amount property, and call payWithSuccessHandler:failure:
 
 If you'd like to process the payment from a different device/location, then you can call asJSON to get a JSON string representation of the payment object. This can, for example, be passed to your Rails backend for use with out Ruby SDK.
 
 If you don't have access to the payment object you'd like to refund, refundPaymentWithID:success:failure: will refund the payment corrponding to the specified payment id. Otherwise, -refundWithSuccess:failure: will perform a refund on the receiver.

 A payment can be retrieved by calling getPaymentWithID:success:failure:
 
 */
@interface SPPayment : SPRemoteResource

/** Creates, but does not process, a card present transaction.
 
   @param paymentDict The dictionary containing the key/value pairs created from a credit card swipe. The two hardware libraries, magtek and rambler, both provide NSDictionary output in the appropriate format. The format is as follows:
 
        @{@"ksn":<device ksn>,
          @"vendor":@"magensa" OR @"magtek"
          @"serial":<device serial>
          @"trackdata":<if using magensa, getResponseData; otherwise, getTrack2>
        };
 
   @return An initialized card present payment transaction. The payment is only processed when payWithSuccessHandler:failure: is called.
 
 */
-(id) initWithPaymentDictionary:(NSDictionary*)paymentDict;

/**
 *  Creates, but does not process, a card not present transaction.
 *
 *  @param cardNumber the full (unredacted and unencrypted) credit card number.
 *  @param zipCode    the zip code associated with the credit card being charged.
 *  @param cvv        the card cvv
 *  @param month      the expiration month in two digit format (January would be passed as @"01")
 *  @param year       the expiration year  in two digit format (2016 would be passed as @"16")
 *
 *  @return An initialized card not present payment transaction. The payment is only processed when payWithSuccessHandler:failure: is called.
 *  
 *  @see payWithSuccessHandler:failure:
 */
-(id) initWithCardNumber:(NSString*)cardNumber zipCode:(NSString*)zipCode cvv:(NSString*)cvv expMonth:(NSString*)month expYear:(NSString*)year;

/**
 *  Completes the payment by sending it to the SlidePay backend.
 *
 *  @param success A block to invoke upon successfully completing the transaction. The complete response is stored (as a utf-8 encoded JSON string) in the NSData argument. The paymentID is the unique identifier for this payment, and the orderID is the unique id for the payment's associated order. These are present in the JSON response, but have been helpfully extracted and provided to you here.
 *  @param failure A block to invoke up transaction failure.
 *
 *  
 */
-(void) payWithSuccessHandler:(PaymentSuccessBlock)success failure:(ResourceFailureBlock)failure;


/**
 *  Refunds a payment using a payment identifier.
 *
 *  @param paymentID The payment identifier for the payment that you'd like to refund.
 *  @param success   If the refund completes successfully, then this block is invoked.
 *  @param failure   If the refund fails to complete., then this block is ionvoked.
 *
 */
+(void) refundPaymentWithID:(NSInteger)paymentID success:(RefundSuccess)success failure:(ResourceFailureBlock)failure;

/**
 *  Performs a refund request on the receiver.
 *
 *  @param success If the refund completes successfully, then this block is invoked.
 *  @param failure If the refund fails to complete., then this block is ionvoked.
 *
 */
-(void) refundWithSuccess:(RefundSuccess)success failure:(ResourceFailureBlock)failure;


/**
 *  Populates the receiver with the remote data corresponding to the paymentID parameter
 *
 *  @param paymentID a payment identifier corresponding to the payment you'd like to retrieve
 *  @param success   Called when the operation completes successfully.
 *  @param failure   Called if the the operation fails.
 */
-(void) getPaymentWithID:(NSInteger)paymentID success:(GetPaymentSuccess)success failure:(ResourceFailureBlock)failure;


/**
 Returns a JSON representation of the payment object. If you aren't processing payments directly from your iOS app, then you'll probably be passing around the result of this method.

 @return A JSON representation of this object as an NSString. It is appropriate for use with the payment/simple API.
 */
-(NSString*) asJSON;
/**
 @return A representation of this payment as an NSDictionary. The key names match those of a JSON string representation appropriate for payment submission through the payment/simple API.
 */
-(NSDictionary *) asJSONObject;

@property (nonatomic, strong)NSNumber * amount;
@property (nonatomic, copy)NSString * notes;
@property (nonatomic, copy)NSString * latitude;
@property (nonatomic, copy)NSString * longitude;
@property (readonly) NSNumber * paymentID;



@end
