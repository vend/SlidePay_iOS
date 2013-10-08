//
//  SlidePayCoreTests.m
//  SlidePayCoreTests
//
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import "SlidePayCoreTests.h"
#import "SPAuthenticate.h"
#import "SPPayment.h"
#import "TestingEnv.h"
#import "SwipeListener.h"

@interface SlidePayCoreTests ()
@property (nonatomic,copy) NSString *username;
@property (nonatomic,copy) NSString *password;
@property (nonatomic,copy) NSString *encryptedSwipeData;

@end

@implementation SlidePayCoreTests

- (void)setUp
{
    [super setUp];
    // Set-up code here.
    NSLog(@"done?");
    done = false;
    self.username = SPTESTING_uname;
    self.password = SPTESTING_password;
    self.encryptedSwipeData = SPTESTING_magensa;
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

-(void) spinYourDamnWheels;{
    NSDate * twoSecondsFromwNow = [NSDate dateWithTimeIntervalSinceNow:2.0];
    while(!done) {
        [[NSRunLoop currentRunLoop] runUntilDate:twoSecondsFromwNow];
    }
}

-(void) test1UnknownUserLogin{

    SPAuthenticate *auth = [SPAuthenticate new];
    auth.username = @"hurf@gmail.com";
    auth.password = self.password;
    [auth login:^{
        NSLog(@"auth successs");
        done = true;
        STFail(@"User shouldn't be able to log in with unknown username");
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        done = true;
        STAssertTrue(serverCode == 4, @"Server code = %d. It should be 4: Could not find an endpoint for your account.",serverCode);
    }];
    [self spinYourDamnWheels];
}

-(void) test2BadPasswordLogin{
    SPAuthenticate *auth = [SPAuthenticate new];
    auth.username = self.username;
    auth.password = @"aaaaaaa";
    [auth login:^{
        done = true;
        STFail(@"this shouldn't be logging in!");
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        done = true;
        STAssertTrue(serverCode == 5, @"Server code = %d. It should be 5: Authorization Failed.",serverCode);
    }];
    
    [self spinYourDamnWheels];
}

-(void) test3SuccessfulLogin{

    SPAuthenticate *auth = [SPAuthenticate new];
    auth.username = self.username;
    auth.password = self.password;
//    __weak typeof(self) weakSelf = self;
    [auth login:^{
        NSLog(@"auth successs");
        done = true;
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        done = true;
    }];
    
    [self spinYourDamnWheels];
    STAssertTrue(auth.authToken != nil, @"Auth Token should not be nil after a successful login.");
    STAssertTrue([auth.endpoint isEqualToString:@"https://dev.getcube.com:65532/rest.svc/API/"], @"Endpoint should be https://dev.getcube.com:65532/rest.svc/API/");
}


-(void) test4FailedMagtekPayment{
    //
    SPPayment *payment = [[SPPayment alloc] initWithPaymentDictionary:@{
                                                                        @"vendor":@"magtek",
                                                                        @"ksn":@"0",
                                                                        @"trackdata":@"0",
                                                                        @"serial":@"0"
                                                                        }];
    payment.amount = @1;
    [payment payWithSuccessHandler:^(NSInteger paymentID, NSInteger orderID, NSData *responseData) {
        NSError * error;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        if(error){NSLog(@"error parsing paymenet response: %@",error); STFail(@"unable to parse payment response");}
        else{
            NSLog(@"response: %@",response);
            STFail(@"Invalid credit card should fail to process");
            done = true;
        }
        
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        STAssertTrue(serverCode == 91, @"Server code = %d. It should be 91: cc_track2data could not be decrypted",serverCode);
        done = true;
    }];
    [self spinYourDamnWheels];
}

-(void) test4FailedTypedInPayment{
    SPPayment *payment = [[SPPayment alloc] initWithCardNumber:@"4123456789001234" zipCode:@"11111" cvv:@"111" expMonth:@"01" expYear:@"16"];
    payment.amount = @1;
    [payment payWithSuccessHandler:^(NSInteger paymentID, NSInteger orderID, NSData *responseData) {
        
        NSError * error;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        if(error){NSLog(@"error parsing paymenet response: %@",error); STFail(@"unable to parse payment response");}
        else{
            NSLog(@"response: %@",response);
            STFail(@"Invalid credit card should fail to process");
            done = true;
        }
        
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        STAssertTrue(serverCode == 14, @"Server code = %d. It should be 14: Invalid Account Number",serverCode);
        done = true;
    }];
    [self spinYourDamnWheels];
}

-(void) test4TypedInVisa{
    //use real card data
    SPPayment *payment = [[SPPayment alloc] initWithCardNumber:@"4111111111111111" zipCode:@"11111" cvv:@"111" expMonth:@"04" expYear:@"15"];
    payment.amount = @1;
    [payment payWithSuccessHandler:^(NSInteger paymentID, NSInteger orderID, NSData *responseData) {
        
        NSError * error;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        if(error){NSLog(@"error parsing paymenet response: %@",error); STFail(@"unable to parse payment response"); done = true;}
        else{
            NSLog(@"response: %@",response);
            STAssertTrue(paymentID > 0, @"payment <= 0 (%d)",paymentID);
            STAssertTrue(orderID > 0, @"orderID <= 0 (%d)",orderID);
            lastPaymentID = paymentID;
            [self refund:paymentID];
        }
        
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        STFail(@"Failed to process payment. Error code = %d \n Message = %@",serverCode,serverMessage);
        done = true;
    }];
    [self spinYourDamnWheels];
}

-(void) refund:(NSInteger)paymentID{
    STAssertTrue(paymentID > 0, @"Refund test failing because paymentID is 0");
    [SPPayment refundPaymentWithID:paymentID success:^(NSInteger paymentID) {
        done = true;
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        done = true;
        STFail(@"Refund failed with code %d, and message %@",serverCode,serverMessage);
    }];
}
-(void) test6MagtekMagensaSwipe{
    //will fail w/ out real card data
    SPPayment *payment = [[SPPayment alloc] initWithPaymentDictionary:@{
                                                                        @"vendor":@"magensa",
                                                                        @"ksn":@"9010010B1D0592000048",
                                                                        @"trackdata":@"",
                                                                        @"serial":@"B1D0592091013AA"
                                                                        }];
    payment.amount = @1;
    [payment payWithSuccessHandler:^(NSInteger paymentID, NSInteger orderID, NSData *responseData) {
        NSError * error;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        if(error){NSLog(@"error parsing paymenet response: %@",error); STFail(@"unable to parse payment response: %@",response);}
        else{
            NSLog(@"magensa response: %@",response);
            STAssertTrue(paymentID > 0, @"payment <= 0 (%d)",paymentID);
            STAssertTrue(orderID > 0, @"orderID <= 0 (%d)",orderID);
            [self refund:paymentID];
        }
        
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        STFail(@"magtek swipe failed");
        done = true;
    }];
    [self spinYourDamnWheels];
}

-(void) test8PayAndRefund{
    //use real card data
    SPPayment *payment = [[SPPayment alloc] initWithCardNumber:@"4111111111111111" zipCode:@"11111" cvv:@"111" expMonth:@"04" expYear:@"15"];
    payment.amount = @1;
    [payment payWithSuccessHandler:^(NSInteger paymentID, NSInteger orderID, NSData *responseData) {
        
        NSError * error;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        if(error){NSLog(@"error parsing paymenet response: %@",error); STFail(@"unable to parse payment response");}
        else{
            NSLog(@"response: %@",response);
            STAssertTrue(paymentID > 0, @"payment <= 0 (%d)",paymentID);
            STAssertTrue(orderID > 0, @"orderID <= 0 (%d)",orderID);
            [payment refundWithSuccess:^(NSInteger paymentID){
//                STAssertTrue(paymentID > 0, @"paymentID was 0 after refund request");
//                NSError * error;
//                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
//                if(error){NSLog(@"error parsing paymenet response: %@",error); STFail(@"unable to parse payment response");}
//                STAssertTrue(response != nil, @"Refund response was nil");
//                NSLog(@"refund response: %@",response);
                done = true;
            } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
                STFail(@"Failed to process payment. Error code = %d \n Message = %@",serverCode,serverMessage);
                done = true;
            }];
        }
        
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        STFail(@"Failed to process payment. Error code = %d \n Message = %@",serverCode,serverMessage);
        done = true;
    }];
    [self spinYourDamnWheels];
}


-(void) test90GetPayment{
    SPPayment *emptyPayment = [SPPayment new];
    [emptyPayment getPaymentWithID:10727 success:^(SPPayment *payment) {
        STAssertTrue([emptyPayment.paymentID isEqualToNumber:@10727], @"Payment was not retrieved correctly");
        done = true;
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        STFail(@"Failed to get payment.");
        done = true;
    }];
    [self spinYourDamnWheels];
}
//doesn't work! a failed search returns everything
-(void) test91GetPaymentFail{
    SPPayment *emptyPayment = [SPPayment new];
    [emptyPayment getPaymentWithID:999999999 success:^(SPPayment *payment) {
        STFail(@"Payment with id of 0 should not succeed.");
        done = true;
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        STAssertTrue(serverCode == 0, @"Server code = %d. It should be __: ",serverCode);
        done = true;
    }];
    [self spinYourDamnWheels];
}

-(void) testSwipeSetup{
    SwipeListener *listener = [SwipeListener new];
    listener.swipeCompleteBlock = ^(NSDictionary *swipe,int errorCode, NSString *errorMessage){
        NSLog(@"Swipe obtained? %@",swipe);
        if(errorCode > 0){
            NSLog(@"Error code: %d",errorCode);
        }
        if(errorMessage){
            NSLog(@"Error message: %@",errorMessage);
        }
        done = true;
    };
    listener.stateChangedBlock = ^(RamblerState status){
        NSLog(@"state changed block: %d",status);
    };
    
    [listener start];
    [listener testSwipe];
    
    [self spinYourDamnWheels];
    
}




@end
