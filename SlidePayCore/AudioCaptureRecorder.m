//
//  AudioCaptureRecorder.m
//  AudioLibrary
//
//  Created by Anderthan Hsieh on 12/13/12.
//  Copyright (c) 2012 Anderthan Hsieh. All rights reserved.
//

#import "AudioCaptureRecorder.h"

static AudioCaptureRecorder *_shared_model;



@implementation AudioCaptureRecorder

@synthesize myLocationManager, isRamblerActive, myReaderController;

+ (AudioCaptureRecorder *) sharedInstance {
    if (!_shared_model) {
        _shared_model = [[AudioCaptureRecorder alloc] init];
        _shared_model.myLocationManager = [[CLLocationManager alloc] init];
        _shared_model.myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _shared_model.myLocationManager.distanceFilter = 100;
        [CLLocationManager locationServicesEnabled];
        [_shared_model.myLocationManager startUpdatingLocation];
        [_shared_model setupRamblerDevice];
        _shared_model.isRamblerActive = YES;
    }
    return  _shared_model;
}

- (void) startupLocationManager {
    _shared_model.myLocationManager = [[CLLocationManager alloc] init];
    _shared_model.myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _shared_model.myLocationManager.distanceFilter = 100;
    [CLLocationManager locationServicesEnabled];
    [_shared_model.myLocationManager startUpdatingLocation];
}

/*
 Rambler Delegate methods and appropriate methods
 */
- (void) setupRamblerDevice {
    _shared_model.myReaderController = [[ReaderController alloc] init];
    _shared_model.myReaderController.delegate = self;
    _shared_model.myReaderController.detectDeviceChange = YES;
    [_shared_model.myReaderController startReader];
    
}


- (void)onGetKsnCompleted:(NSString *)ksn {

}

- (void) onDevicePlugged {

    [[NSNotificationCenter defaultCenter] postNotificationName:@"rambler_on" object:nil];
    if (_shared_model.isRamblerActive)
        [_shared_model.myReaderController startReader];
}

- (void) onDeviceUnplugged {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"rambler_off" object:nil];
}

- (void)onDecodeCompleted:(NSString *)formatID
                      ksn:(NSString *)ksn
	   encTrack1AndTrack2:(NSString *)encTrack1AndTrack2
             track1Length:(int)track1Length
             track2Length:(int)track2Length
                maskedPAN:(NSString *)maskedPAN
               expiryDate:(NSString *)expiryDate
           cardHolderName:(NSString *)cardHolderName {
    
    
    NSString *my_redacted_string = @"";
    
    if (maskedPAN.length >= 4)
        my_redacted_string = [maskedPAN substringFromIndex:[maskedPAN length] - 4];

    
    
    //Need to create a Cube_simple_payment from this
  
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"No location services enabled.  Payment will fail");
        [self startupLocationManager];
        
    }
    else if (!myLocationManager.location.coordinate.latitude || !myLocationManager.location.coordinate.longitude) {
        [self startupLocationManager];
    }
    else {
        
        NSString *expiryMonth = @"";
        NSString *expiryYear = @"";
        
        if (expiryDate.length == 4) {
            expiryMonth = [expiryDate substringFromIndex:2];
            expiryYear = [expiryDate substringToIndex:2];
        }
        
        
        
        
        NSMutableDictionary *temporaryPaymentDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         encTrack1AndTrack2, @"cc_track2data",
                                                         @"rambler", @"encryption_vendor",
                                                         ksn, @"encryption_ksn",
                                                         [NSNumber numberWithDouble:_shared_model.myLocationManager.location.coordinate.longitude], @"longitude",
                                                         [NSNumber numberWithDouble:_shared_model.myLocationManager.location.coordinate.latitude], @"latitude",
                                                         expiryMonth, @"cc_expiry_month",
                                                         expiryYear, @"cc_expiry_year",
                                                         my_redacted_string, @"cc_redacted_number"

                                                         , nil];
        
        if (my_redacted_string.length > 0)
            [temporaryPaymentDictionary setObject:my_redacted_string forKey:@"cc_redacted_number"];
        
        //If no audio detection, don't do anything
        if (_shared_model.isRamblerActive)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"rambler_swipe" object:nil userInfo: temporaryPaymentDictionary];
    }
    
//    NSDictionary *my_temporary_payment = [NSDictionary dictionarywithObject
    
    [_shared_model.myReaderController startReader];
    
    
}

- (void)onDecodeError:(ReaderControllerDecodeResult)decodeState {
    
    if (_shared_model.isRamblerActive)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"swipe_fail" object:nil];
    
    
    [_shared_model.myReaderController startReader];
}

- (void)onError:(NSString *)errorMessage {
    if (_shared_model.isRamblerActive)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"swipe_fail" object:nil];
    [_shared_model.myReaderController startReader];
}

- (void)onInterrupted {
    if (_shared_model.isRamblerActive)
        [_shared_model.myReaderController startReader];
}

- (void)onNoDeviceDetected {
}

- (void)onTimeout {
    if (_shared_model.isRamblerActive)
        [_shared_model.myReaderController startReader];
}

- (void)onWaitingForCardSwipe {
}

- (void)onWaitingForDevice {
}

- (void)onDecodingStart {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"audio_decoding_start" object:nil];
}

- (void)onCardSwipeDetected {

}

/*
End of Rambler
*/


@end
