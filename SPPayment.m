//
//  SPPayment.m
//  SlidePayCore
//
//  Created by Alex Garcia on 9/23/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import "SPPayment.h"


@interface SPPayment ()

@property (nonatomic) NSString * encryption_ksn;
@property (nonatomic) NSString * track2;
@property (nonatomic) NSString * cc_expiry_month;
@property (nonatomic) NSString * cc_expiry_year;
@property (nonatomic) NSString * cc_name_on_card;
@property (nonatomic) NSString * cc_track2data;
@property (nonatomic) NSString * cc_type;
@property (nonatomic) NSString * encryption_device_serial;
@property (nonatomic) NSString * cc_redacted_number;
@property (nonatomic) NSString * encryption_vendor;
@property (nonatomic) NSString * cc_number;
@property (nonatomic) NSString * cc_present;
@property (nonatomic) NSString * cc_billing_zip;
@property (nonatomic) NSString * cc_cvv2;
@property (nonatomic) NSString * company_id;
@property (nonatomic) NSString * location_id;
@property (nonatomic) NSString * method;
@property (nonatomic) NSString * order_master_id;
@property (nonatomic) NSString * user_master_id;
@property (nonatomic) NSString * created;
@property (nonatomic) NSString * last_update;
@property (nonatomic) NSString * is_refund;

@end

@implementation SPPayment

@synthesize resource = _resource;

#pragma mark creating a payment
-(id) initWithPaymentID:(NSInteger)paymentID{
    if(self = [super init]){
        _paymentID = [NSNumber numberWithInteger:paymentID];
        [self.objectManager addResponseDescriptor:[self getPaymentResponseDescriptor]];
    }
    return self;
}

-(id) initWithPaymentDictionary:(NSDictionary*)dictionary{
    if(self = [super init]){
        NSString * ksn = [dictionary valueForKey:@"ksn"];
        NSString * vendor = [dictionary valueForKey:@"vendor"];
        NSString * serial = [dictionary valueForKey:@"serial"];
        NSString * trackdata = [dictionary valueForKey:@"trackdata"];
        NSArray * additionalKeys = @[];
        if(serial){
            additionalKeys = @[@"encryption_device_serial"];
            self.encryption_device_serial = serial;
        }
        self.encryption_ksn = ksn;
        self.encryption_vendor = vendor;
        self.cc_track2data = trackdata;
        self.method = @"CreditCard";
        RKRequestDescriptor *descriptor = [self requestDescriptorWithKeys:[additionalKeys arrayByAddingObjectsFromArray:[self swipedRequestKeys]]];
        [self.objectManager addRequestDescriptor:descriptor];
        [self.objectManager addResponseDescriptor:[self makePaymentResponseDescriptor]];
    }
    return self;
}

-(id) initWithCardNumber:(NSString *)cardNumber zipCode:(NSString *)zipCode cvv:(NSString *)cvv expMonth:(NSString *)month expYear:(NSString *)year{
    if(self = [super init]){
        self.cc_number       = cardNumber;
        self.cc_billing_zip  = zipCode;
        self.cc_cvv2         = cvv;
        self.cc_expiry_month = month;
        self.cc_expiry_year  = year;
        self.method = @"CreditCard";
        [self.objectManager addRequestDescriptor:[self keyedPaymentRequestDescriptor]];
        [self.objectManager addResponseDescriptor:[self makePaymentResponseDescriptor]];
    }
    return self;
}

#pragma mark Restkit crap
-(RKResponseDescriptor*)getPaymentResponseDescriptor{
    RKObjectMapping *paymentMapping = [RKObjectMapping mappingForClass:[SPPayment class]];
    [paymentMapping addAttributeMappingsFromArray:@[
                                                    @"amount",
                                                    @"cc_expiry_month",
                                                    @"cc_expiry_year",
                                                    @"cc_number",
                                                    @"cc_present",
                                                    @"cc_track2data",
                                                    @"cc_type",
                                                    @"cc_billing_zip",
                                                    @"cc_cvv2",
                                                    @"company_id",
                                                    @"location_id",
                                                    @"method",
                                                    @"order_master_id",
                                                    @"user_master_id",
                                                    @"encryption_device_serial",
                                                    @"encryption_ksn",
                                                    @"cc_name_on_card",
                                                    @"encryption_vendor",
                                                    @"created",
                                                    @"last_update",
                                                    @"payment_id",
                                                    @"is_refund",
                                                    @"cc_redacted_number",
                                                    @"notes"
                                                    ]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:paymentMapping method:RKRequestMethodGET pathPattern:@"payment" keyPath:@"data" statusCodes:[SPPayment successCodes]];
    return responseDescriptor;
}
-(RKResponseDescriptor*)makePaymentResponseDescriptor{
    RKObjectMapping *paymentMapping = [RKObjectMapping mappingForClass:[SPPayment class]];
    [paymentMapping addAttributeMappingsFromDictionary:@{
                                                         @"payment_id":@"paymentID",
                                                         @"order_master_id":@"order_master_id"
                                                         }];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:paymentMapping method:RKRequestMethodPOST pathPattern:@"payment/simple" keyPath:@"data" statusCodes:[SPPayment successCodes]];
    return responseDescriptor;
}
-(NSArray*) commonRequestKeys{
    return @[@"amount",
             @"notes",
             @"method",
             @"latitude",
             @"longitude"
             ];
}

-(NSArray*) swipedRequestKeys{
    return [[self commonRequestKeys] arrayByAddingObjectsFromArray:@[@"encryption_vendor",
                                                                     @"encryption_ksn",
                                                                     @"cc_track2data"
                                                                     ]];
}

-(NSArray*) keyedRequestKeys{
    return [[self commonRequestKeys] arrayByAddingObjectsFromArray:@[@"cc_type",
                                                                     @"cc_number",
                                                                     @"cc_expiry_month",
                                                                     @"cc_expiry_year",
                                                                     @"cc_billing_zip",
                                                                     @"cc_cvv2"
                                                                     ]];
}

-(RKRequestDescriptor*)requestDescriptorWithKeys:(NSArray*)keys{
    
    RKObjectMapping *paymentMapping = [RKObjectMapping mappingForClass:[SPPayment class]];
    [paymentMapping addAttributeMappingsFromArray:keys];
    
    RKRequestDescriptor * requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:paymentMapping.inverseMapping objectClass:[SPPayment class] rootKeyPath:nil method:RKRequestMethodPOST];
    
    return requestDescriptor;
}
-(RKRequestDescriptor*)swipedPaymentRequestDescriptor{
    return [self requestDescriptorWithKeys:[self swipedRequestKeys]];
}
-(RKRequestDescriptor*)keyedPaymentRequestDescriptor{
    return [self requestDescriptorWithKeys:[self keyedRequestKeys] ];
}

#pragma mark making a payment
-(void) payWithSuccessHandler:(PaymentSuccessBlock)success failure:(ResourceFailureBlock)failure{
    [self.objectManager postObject:self
                              path:@"payment/simple"
                        parameters:nil
                           success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                               NSLog(@"success");
                               NSData *responseData = operation.HTTPRequestOperation.responseData;
                               success(self.paymentID.integerValue,self.order_master_id.integerValue,responseData);
                           }
                           failure:^(RKObjectRequestOperation *operation, NSError *error) {
                               NSNumber *errorCode;
                               NSString *errorMessage;
                               NSData * bodyData = operation.HTTPRequestOperation.request.HTTPBody;
                               NSString * bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
                               NSLog(@"body string: %@",bodyString);
                               [SPRemoteResource responseSanityCheck:[SPRemoteResource responseFromOperation:operation.HTTPRequestOperation] errorCode:&errorCode errorMessage:&errorMessage];
                               failure(errorCode ? errorCode.integerValue : 0,errorMessage,error);
                           }];
}

#pragma mark refunding a payment

-(void) refundWithSuccess:(RefundSuccess)success failure:(ResourceFailureBlock)failure{
    NSString * path = [NSString stringWithFormat:@"payment/refund/%@",self.paymentID ? self.paymentID : @""];
    AFHTTPClient * client = self.objectManager.HTTPClient;
    [SPPayment refundWithClient:client succes:success failure:failure path:path];
}
+(void) refundPaymentWithID:(NSInteger)paymentID success:(RefundSuccess)success failure:(ResourceFailureBlock)failure{
    AFHTTPClient * client = [[SPRemoteResource sharedManager] HTTPClient];
    NSString * path = [NSString stringWithFormat:@"payment/refund/%@", @(paymentID) ? @(paymentID) : @""];
    [SPPayment refundWithClient:client succes:success failure:failure path:path];
}

+(void) refundWithClient:(AFHTTPClient *)client succes:(RefundSuccess)success failure:(ResourceFailureBlock)failure path:(NSString*)path{

    [client postPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL goodToGo = [SPRemoteResource checkResponseObjectForSuccessFlag:responseObject failure:failure];
        if(goodToGo){
            [SPRemoteResource configureWithResponse:responseObject];
            NSDictionary * data = [responseObject valueForKey:@"data"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end