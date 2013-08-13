//
//  SlidePayCore.m
//  SlidePayCore
//
//  Created by Anderthan Hsieh on 8/7/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import "SlidePayCore.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AudioCaptureRecorder.h"
#import "MTSCRA.h"
#import <ExternalAccessory/ExternalAccessory.h>


static SlidePayCore *_shared_model = nil;
static MTSCRA *mtSCRALib;
static AudioCaptureRecorder *myRecorder;




@implementation SlidePayCore {
    NSString *myEndpointString;
    NSString *myPassword;
    NSString *myEmailAddress;
    NSString *myUserToken;
    NSMutableURLRequest *request;
    SlidePayLoginObject *loginObject;
}

@synthesize slidePayCoreDelegate, amountToCharge, userMaster;

+ (SlidePayCore *) sharedInstance {
    if (!_shared_model) {
        _shared_model = [[SlidePayCore alloc] init];
        [_shared_model setUpRambler];
        [_shared_model setUpMagTekSwiper];
        [mtSCRALib openDevice];
    }
    
    return _shared_model;
}

/*
 The logic behind logging in is the following.
 
 1.  User supplies e-mail address and password
 2.  We then first make a call to supervisor to check to see if the e-mail and password is legit. (REST call #1)
 3.  After obtaining the endpoint, I then make a call to /api/login addressing the correct endpoint (REST call #2)
 4.  After a successful login, I then make a call to /token/detail.  (REST call #3)
 
 After receiving all of this information, I will then construct an object to pass back which contains constructed information coming from /api/login and /token/detail
 */

- (void) loginWithEmail: (NSString *) emailAddress withPassword: (NSString *) password {
    NSError *loginError = nil;
    
    //We first need to make sure that the e-mail address provided and password passes basic validation (can't be nil or empty).
    if (![self validateLoginFieldsWithEmail:emailAddress withPassword:password]) {
        loginError = [NSError errorWithDomain:@"Attempting to login with invalid credentials" code:LOGIN_FAILURE_INVALID_CREDENTIALS userInfo:nil];
        return [self.slidePayCoreDelegate loginRequestCompletedWithData:nil withError:loginError];
    }
    
    //Next we make to supervisor to see which endpoint we need to specify
    NSURL *supervisorURL = [NSURL URLWithString:@"https://supervisor.getcube.com:65532/rest.svc/API/endpoint"];
    request = [[NSMutableURLRequest alloc] initWithURL:supervisorURL];
    request.HTTPMethod = @"GET";
    [request setValue:emailAddress forHTTPHeaderField:@"x-cube-email"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSError *supervisorError = [NSError errorWithDomain:@"Unable to obtain endpoint from e-mail address" code:LOGIN_FAILURE_INVALID_ACCOUNT userInfo:nil];
            [self.slidePayCoreDelegate loginRequestCompletedWithData:nil withError:supervisorError];
        }
        else {
            myPassword = password;
            myEmailAddress = emailAddress;
            [self processSupervisorData:data];
        }
            }];
    
}



#pragma mark - Private Helpers
/*
 processSupervisorData - this will take 
 */
- (void) processSupervisorData: (NSData *) data {
    NSError *error = nil;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    //need to do something if success = 0
    NSNumber *mySuccessNumber = (NSNumber *)[responseDictionary objectForKey:@"success"];
    if (mySuccessNumber.boolValue) {
        myEndpointString = (NSString *)[responseDictionary objectForKey:@"data"];
        [self loginToBackend];
    }
    else {
        NSError *supervisorError = [NSError errorWithDomain:@"Unable to obtain endpoint from e-mail address" code:LOGIN_FAILURE_INVALID_ACCOUNT userInfo:nil];
        [self.slidePayCoreDelegate loginRequestCompletedWithData:nil withError:supervisorError];
    }
        
}

//This method is called after a successful call to the backend for the endpoint
- (void) loginToBackend {
    NSURL *myLoginURL = [[SlidePayCore sharedInstance] urlByAppendingPath:@"login"];
    request = [[NSMutableURLRequest alloc] initWithURL:myLoginURL];
    request.HTTPMethod = @"GET";
    [request setValue:myEmailAddress forHTTPHeaderField:@"x-cube-email"];
    [request setValue:myPassword forHTTPHeaderField:@"x-cube-password"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSError * loginError = [NSError errorWithDomain:@"Attempting to login with invalid credentials" code:LOGIN_FAILURE_INVALID_CREDENTIALS userInfo:nil];
            [self.slidePayCoreDelegate loginRequestCompletedWithData:nil withError:loginError];
        }
       else {
           [self processLoginData:data];
       }
    }];
}

- (void) processLoginData: (NSData *) data {
    NSError *error = nil;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    NSNumber *mySuccessNumber = (NSNumber *)[responseDictionary objectForKey:@"success"];
    if (mySuccessNumber.boolValue) {
        NSString *tokenString = [responseDictionary objectForKey:@"data"];
        [request setValue:tokenString forHTTPHeaderField:@"x-cube-token"];
        
        myUserToken = tokenString;
        
        [self obtainTokenDetailFromBackend];
        
    }
    else {
        NSError * loginError = [NSError errorWithDomain:@"Attempting to login with invalid credentials" code:LOGIN_FAILURE_INVALID_CREDENTIALS userInfo:nil];
        [self.slidePayCoreDelegate loginRequestCompletedWithData:nil withError:loginError];
    }

}

//This method is called after a successful login call to the backend
- (void) obtainTokenDetailFromBackend {
    NSURL *myTokenDetailURL = [[SlidePayCore sharedInstance] urlByAppendingPath:@"token/detail"];
    [request setURL:myTokenDetailURL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSError * tokenDetailError = [NSError errorWithDomain:@"Unable to retrieve information from token detail" code:LOGIN_FAILURE_CONNECTIVITY userInfo:nil];
            [self.slidePayCoreDelegate loginRequestCompletedWithData:nil withError:tokenDetailError];
        }
        else {
            [self processTokenDetailData:data];
        }
    }];
}

- (void) processTokenDetailData: (NSData *) data {
    NSError *error = nil;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    NSNumber *mySuccessNumber = (NSNumber *)[responseDictionary objectForKey:@"success"];
    if (mySuccessNumber.boolValue) {
        NSDictionary *dataDictionary = (NSDictionary *)[responseDictionary objectForKey:@"data"];
        loginObject = [[SlidePayLoginObject alloc] init];
        
        loginObject.slidePayEndpoint = myEndpointString;
        loginObject.companyName = [dataDictionary objectForKey:@"company_name"];
        loginObject.locationName = [dataDictionary objectForKey:@"location_name"];
        loginObject.slidePayToken = myUserToken;
        
        if (((NSNumber *)[dataDictionary objectForKey:@"is_comgr"]).intValue > 0)
            loginObject.userPermissionLevel = IS_COMGR;
        else if (((NSNumber *)[dataDictionary objectForKey:@"is_locmgr"]).intValue > 0)
            loginObject.userPermissionLevel = IS_LOCMGR;
        else
            loginObject.userPermissionLevel = IS_CLERK;
        
        //Need to setup the user detail
        self.userMaster = [[SlidePayUserMaster alloc] init];
        self.userMaster.firstName = [dataDictionary objectForKey:@"first_name"];
        self.userMaster.lastName = [dataDictionary objectForKey:@"last_name"];
        self.userMaster.userMasterID = [NSNumber numberWithInt:[[dataDictionary objectForKey:@"user_master_id"] intValue]];
        self.userMaster.companyID = [NSNumber numberWithInt:[[dataDictionary objectForKey:@"company_id"] intValue]];
        self.userMaster.locationID = [NSNumber numberWithInt:[[dataDictionary objectForKey:@"location_id"] intValue]];
        loginObject.slidePayUser = self.userMaster;
        
        [self.slidePayCoreDelegate loginRequestCompletedWithData:loginObject withError:nil];
    }
    else {
        NSError * tokenDetailError = [NSError errorWithDomain:@"Unable to retrieve information from token detail" code:LOGIN_FAILURE_CONNECTIVITY userInfo:nil];
        [self.slidePayCoreDelegate loginRequestCompletedWithData:nil withError:tokenDetailError];
    }
}


- (BOOL) validateLoginFieldsWithEmail: (NSString *) emailAddress withPassword: (NSString *) password {
    if (!emailAddress || !password || emailAddress.length <= 0 || password.length <= 0)
        return false;
    else
        return true;
}


- (NSURL *) urlByAppendingPath: (NSString *) path {
    return [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:myEndpointString]];
}

#pragma mark - Payment Section
/*
 Payment Section
 */
- (void) setUpRambler {
    myRecorder = [AudioCaptureRecorder sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(obtainedRamblerSwipe:) name:@"rambler_swipe" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ramblerSwipeFailed) name:@"swipe_fail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenRamblerIsConnected) name:@"rambler_on" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenRamblerIsDisconnected) name:@"rambler_off" object:nil];
}

- (void) whenRamblerIsConnected {
    [self.slidePayCoreDelegate readerConnected:YES withType:DEVICE_ENCRYPTED_AUDIO];
}

- (void) whenRamblerIsDisconnected {
    [self.slidePayCoreDelegate readerConnected:NO withType:DEVICE_ENCRYPTED_AUDIO];
}

- (void) obtainedRamblerSwipe: (NSNotification *) notification {
    NSDictionary *ramblerDictionary = [notification userInfo];
    
    NSMutableDictionary *my_simple_payment = [NSMutableDictionary dictionaryWithDictionary:ramblerDictionary];
    [self createPaymentDictionaryFromEncryptedSwipe:my_simple_payment];
    
}

- (void) ramblerSwipeFailed {
    [self.slidePayCoreDelegate swipeFailed];
}

- (void) createPaymentDictionaryFromEncryptedSwipe: (NSMutableDictionary *) my_encrypted_dictionary {
    NSDictionary *my_add_on_dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithDouble:amountToCharge], @"amount",
                                          userMaster.companyID, @"company_id",
                                          userMaster.locationID, @"location_id",
                                          @"CreditCard", @"method",
                                          userMaster.firstName, @"first_name",
                                          userMaster.lastName, @"last_name"
                                          , nil];
    
    [my_encrypted_dictionary addEntriesFromDictionary:my_add_on_dictionary];
    
    [self sendPaymentDictionaryToBackend:my_encrypted_dictionary];
}

- (void) sendPaymentDictionaryToBackend: (NSDictionary *) paymentDictionary {
    NSLog(@"%@", paymentDictionary);
    
    
    if (![paymentDictionary objectForKey:@"latitude"] || ![paymentDictionary objectForKey:@"longitude"]) {
        NSError *error = [NSError errorWithDomain:@"No location data.  Please turn on location services" code:PAYMENT_FAILURE_NO_LOCATION userInfo:nil];
        [self.slidePayCoreDelegate paymentFinishedWithResponse:nil withError:error];
    }
    else {
        request.HTTPMethod = @"POST";
        request.URL = [[SlidePayCore sharedInstance] urlByAppendingPath:@"payment/simple"];
        
        NSLog(@"%@", request.URL);
        
        NSError *writeError = nil;
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:paymentDictionary options:NSJSONWritingPrettyPrinted error:&writeError];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (error) {
                NSError *paymentError = [NSError errorWithDomain:@"Unable to process payment" code:LOGIN_FAILURE_OTHER userInfo:nil];
                [self.slidePayCoreDelegate paymentFinishedWithResponse:nil withError:paymentError];
            }
            else {
                NSError *error = nil;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                [self.slidePayCoreDelegate paymentFinishedWithResponse:responseDictionary withError:nil];
            }
        }];

    }
}





- (void) setUpMagTekSwiper {
    mtSCRALib = [[MTSCRA alloc] init];
    [mtSCRALib listenForEvents:(TRANS_EVENT_OK|TRANS_EVENT_START|TRANS_EVENT_ERROR)];
    [mtSCRALib setDeviceType:(MAGTEKIDYNAMO)];
    [mtSCRALib setDeviceProtocolString:@"com.magtek.idynamo"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(devConnStatusChange) name:@"devConnectionNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackDataReady:) name:@"trackDataReadyNotification" object:nil];
    
    
}

- (void) turnOnAudioSwipeDetection: (BOOL) on {
    if (on) {
        [[AudioCaptureRecorder sharedInstance].myReaderController startReader];
    }
    [AudioCaptureRecorder sharedInstance].isRamblerActive = on;
}

- (void)devConnStatusChange {
    BOOL isDeviceConnected = [mtSCRALib isDeviceConnected];
    if (isDeviceConnected)
        [self.slidePayCoreDelegate readerConnected:YES withType:DEVICE_MAGTEK_IDYNAMO];
    else
        [self.slidePayCoreDelegate readerConnected:NO withType:DEVICE_MAGTEK_IDYNAMO];
}

- (void)trackDataReady:(NSNotification *)notification
{
    NSNumber *status = [[notification userInfo]
                        valueForKey:@"status"];
    [self performSelectorOnMainThread:@selector(onDataEvent:) withObject:status waitUntilDone:YES];
}

- (void)onDataEvent:(id)status
{
	switch ([status intValue]) {
        case TRANS_STATUS_OK: {
            BOOL bTrackError;
            NSString * pstrTrackDecodeStatus = [mtSCRALib getTrackDecodeStatus];
            @try
            {
                if(pstrTrackDecodeStatus)
                {
                    if(pstrTrackDecodeStatus.length >= 6)
                    {
                        //need to call method finishWithSuccess because we got the valid data, we also need to fill out the checkoutModel
                        //Time to form the necessary information
                        
                        [self processMTSCRATrack2Read];
                        
                        [mtSCRALib clearBuffers];
                        
                    }
                    else {
                        [self.slidePayCoreDelegate swipeFailed];
                    }
                }
                
            }
            @catch(NSException * e)
            {
            }
            
            if(bTrackError==NO)
            {
                [mtSCRALib clearBuffers];
            }
            
            
            break;
        }
        case TRANS_STATUS_START: {
            [self.slidePayCoreDelegate magtekProcessingStarted];
            break;
        }
        case TRANS_STATUS_ERROR:
            [self.slidePayCoreDelegate swipeFailed];
            break;
            
        default:
            break;
    }
    
    
}



/*
 When we get a MagTek swipe, we will need to create a payment dictionary out of it.
 */
- (void) processMTSCRATrack2Read {
    
    [self checkIfLocationManagerIsOn];
    
    NSString *expiration_string = [mtSCRALib getCardExpDate];
    
    //need to return something bad
    if (expiration_string.length < 4)
        return ;
    
    
    
    NSString *cc_expiration_year = [expiration_string substringToIndex:2];
    NSString *cc_expiration_month = [expiration_string substringFromIndex:2];
    
    NSMutableDictionary *my_encrypted_swipe_args = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    cc_expiration_month, @"cc_expiry_month",
                                                    cc_expiration_year, @"cc_expiry_year",
                                                    [mtSCRALib getCardName], @"cc_name_on_card",
                                                    [mtSCRALib getTrack2], @"cc_track2data",
                                                    [SlidePayCore obtainCardTypeFromRedacted: [mtSCRALib getCardIIN]], @"cc_type",
                                                    [mtSCRALib getDeviceSerial], @"encryption_device_serial",
                                                    [mtSCRALib getKSN], @"encryption_ksn",
                                                    [mtSCRALib getCardLast4], @"cc_redacted_number",
                                                    @"magtek", @"encryption_vendor",
                                                    [NSNumber numberWithDouble:myRecorder.myLocationManager.location.coordinate.latitude], @"latitude",
                                                    [NSNumber numberWithDouble:myRecorder.myLocationManager.location.coordinate.longitude], @"longitude"
                                                    , nil];
    
    
    
    
    [self createPaymentDictionaryFromEncryptedSwipe:my_encrypted_swipe_args];
    
}

- (void) checkIfLocationManagerIsOn {
    if (myRecorder.myLocationManager.location.coordinate.latitude == 0 || myRecorder.myLocationManager.location.coordinate.longitude == 0) {
        [myRecorder startupLocationManager];
    }
}

- (void) createCNPWithZip: (NSString *) zipCode withCVV: (NSString *) cvv withExpiryMonth: (NSString *) expiryMonth withExpiryYear: (NSString *) expiryYear withCardNumber: (NSString *) cardNumber
{
    
    [self checkIfLocationManagerIsOn];
    
    
    NSString *ccType = [SlidePayCore obtainCardStringFromCardType: [SlidePayCore obtainCardTypeFromCardNumber: cardNumber]];
    NSMutableDictionary *typedInArgs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             zipCode, @"cc_billing_zip",
                                             cvv, @"cc_cvv2",
                                             expiryMonth, @"cc_expiry_month",
                                             expiryYear, @"cc_expiry_year",
                                             cardNumber, @"cc_number",
                                             [NSNumber numberWithInt:0], @"cc_present",
                                             ccType, @"cc_type", nil];
    
    NSDictionary *addOnDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithDouble:self.amountToCharge], @"amount",
                                          userMaster.companyID, @"company_id",
                                          userMaster.locationID, @"location_id",
                                          @"CreditCard", @"method",
                                          userMaster.firstName, @"first_name",
                                          userMaster.lastName, @"last_name",
                                          [NSNumber numberWithDouble:myRecorder.myLocationManager.location.coordinate.latitude], @"latitude",
                                          [NSNumber numberWithDouble:myRecorder.myLocationManager.location.coordinate.longitude], @"longitude"
                                          , nil];
    
    [typedInArgs addEntriesFromDictionary:addOnDictionary];
    
    [self sendPaymentDictionaryToBackend:typedInArgs];
}

//refundPayment
- (void) refundPayment: (int) paymentID {
    request.URL = [[SlidePayCore sharedInstance] urlByAppendingPath:[NSString stringWithFormat:@"payment/refund/%d", paymentID]];
    request.HTTPMethod = @"POST";
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            [self.slidePayCoreDelegate refundFinishedWithResponse:nil withError:error];
        }
        else {
            NSError *error = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            [self.slidePayCoreDelegate refundFinishedWithResponse:responseDictionary withError:nil];
        }
    }];
    
}


+ (NSString *) obtainCardTypeFromRedacted: (NSString *) cardIIN {
    
    //The cardIIN will look like ####***.  Therefore, we need to just make sure that the length is greater than  or equal to 4.
    if (cardIIN.length < 4) {
        return @"Unable to determine cardtype";
    }
    else if ([cardIIN characterAtIndex:0] == '4') {
        return @"Visa";
    }
    NSString *myFirstTwoDigits = [cardIIN substringToIndex:2];
    if ([myFirstTwoDigits intValue] >= 51 && [myFirstTwoDigits intValue] <= 55)
        return @"MasterCard";
    else if ([myFirstTwoDigits intValue] == 34 || [myFirstTwoDigits intValue] == 37)
        return @"AmericanExpress";
    else if ([myFirstTwoDigits intValue] == 36 || [myFirstTwoDigits intValue] == 38)
        return @"MasterCard";
    NSString *myFirstThreeDigits = [cardIIN substringToIndex:3];
    if ([myFirstThreeDigits intValue] >= 300 && [myFirstThreeDigits intValue] <= 305)
        return @"MasterCard";
    NSString *myFirstFourDigits = [cardIIN substringToIndex:4];
    if ([myFirstTwoDigits intValue] == 65 || [myFirstFourDigits intValue] == 6011)
        return @"Discover";
    return @"Unable to determine cardtype";
}


+ (NSString *) obtainCardStringFromCardType : (CC_CARD_TYPE) cardType {
    switch (cardType) {
        case CC_AMEX:
            return @"AmericanExpress";
            break;
        case CC_DISCOVER:
            return @"Discover";
            break;
        case CC_MASTERCARD:
            return @"MasterCard";
            break;
        case CC_VISA:
            return @"Visa";
            break;
        default:
            return @"";
            break;
    }
}

/*
 obtainCardTypeFromCardNumber: We take in a string which contains the card number.  We then use our regex to determine what type of card this is and return it back.  If it there is an error, we will return CC_ERROR.
 */

+ (CC_CARD_TYPE) obtainCardTypeFromCardNumber: (NSString*) card_number_string {
    
    NSString * visaPattern = @"^4[0-9]{12}(?:[0-9]{3})?$";
    NSString * amexPattern = @"^3[47][0-9]{13}$";
    NSString * discPattern = @"^6(?:011|5[0-9]{2})[0-9]{12}$";
    NSString * masterPattern = @"^5[1-5][0-9]{14}$";
    NSError * error;
    NSRegularExpression * visaRegex = [NSRegularExpression regularExpressionWithPattern:visaPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression * amexRegex = [NSRegularExpression regularExpressionWithPattern:amexPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression * masterRegex = [NSRegularExpression regularExpressionWithPattern:masterPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSRegularExpression * discRegex = [NSRegularExpression regularExpressionWithPattern:discPattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray * visaMatches = [NSArray arrayWithArray:[visaRegex matchesInString:card_number_string
                                                                       options:NSMatchingReportCompletion
                                                                         range:NSMakeRange(0, [card_number_string length])]];
    NSArray * matchesAmex = [NSArray arrayWithArray:
                             [amexRegex matchesInString:card_number_string
                                                options:NSMatchingReportCompletion
                                                  range:NSMakeRange(0, [card_number_string length])]];
    NSArray * matchesMaster = [NSArray arrayWithArray:
                               [masterRegex matchesInString:card_number_string
                                                    options:NSMatchingReportCompletion
                                                      range:NSMakeRange(0, [card_number_string length])]];
    NSArray * matchesDiscover = [NSArray arrayWithArray:
                                 [discRegex matchesInString:card_number_string
                                                    options:NSMatchingReportCompletion
                                                      range:NSMakeRange(0, [card_number_string length])]];
    
    if(visaMatches.count > 0)
        return CC_VISA;
    else if(matchesAmex.count > 0)
        return CC_AMEX;
    else if(matchesDiscover.count > 0)
        return CC_DISCOVER;
    else if(matchesMaster.count > 0)
        return CC_MASTERCARD;
    else
        return CC_ERROR;
}


/*
 This is just a helper method which help you convert an NSArray or a NSDictionary to its equivalent JSON
 */
+ (NSString *) convertIDToJSONString: (id) object {
    NSError *error = nil;
    NSData *json_data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
    
    return jsonString;
}



@end


