//
//  SwipeListener.m
//  SlidePayCore
//
//  Created by Alex Garcia on 10/4/13.
//  Copyright (c) 2013 SlidePay. All rights reserved.
//

#import "SwipeListener.h"

@interface SwipeListener(RamblerDelegate)<ReaderControllerDelegate>
@end
@interface SwipeListener()
@end

static NSArray * keys = nil;

@implementation SwipeListener

-(id) init {
    if(self = [super init]){
        //keys = @[KEY_EXP,KEY_KSN,KEY_MASKED,KEY_NAME,KEY_TRACK];
    }
    return self;
}
-(void) start{
    if(!self.readerController){
        self.readerController = [ReaderController new];
    }
    
    self.readerController.delegate = self;
    self.readerController.detectDeviceChange = YES;
    
    if([self.readerController getReaderState] == ReaderControllerStateIdle){
        [self.readerController startReader];
    }
}
-(void) stop{
    if([self.readerController getReaderState] != ReaderControllerStateIdle){
        [self.readerController stopReader];
    }
}

-(void) dealloc{
    [self.readerController stopReader];
}

-(RamblerState) state{
    if(![self.readerController isDevicePresent]){
        return DEVICE_UNPLUGGED;
    }
    ReaderControllerState state = [self.readerController getReaderState];
    RamblerState myState = state == ReaderControllerStateIdle ? DEVICE_IDLE :
    state == ReaderControllerStateDecoding  ? DEVICE_DECODING  :
    state == ReaderControllerStateRecording ? DEVICE_RECORDING :
    DEVICE_WAITING;
    return myState;
}

-(void) testSwipe{
    NSDictionary * swipe = @{KEY_KSN : @"ksn!!",
                             KEY_TRACK : @"trackdata"
                             };
    
    [self onDecodeCompleted:swipe];
}

@end

@implementation SwipeListener (RamblerDelegate)

- (void)onDecodeCompleted:(NSDictionary *)data;{
  
    NSLog(@"decode complete, swipe dict: %@",data);
    NSDictionary * simplePaymentDict = @{SPKEY_KSN : data[KEY_KSN],
                                         SPKEY_METHOD : @"CreditCard",
                                         SPKEY_TRACK1 : data[KEY_TRACK],
                                         SPKEY_VENDOR : @"rambler",
                                         SPKEY_NOTES  : @""
                                         };
    
    NSLog(@"decode complete: %@",simplePaymentDict);
    if(self.swipeCompleteBlock){
        self.swipeCompleteBlock(simplePaymentDict,0,nil);
    }
    
    
    //        if (expiryDate.length == 4) {
    //            expiryMonth = [expiryDate substringFromIndex:2];
    //            expiryYear = [expiryDate substringToIndex:2];
    //        }
    
    
    
    
    //        NSMutableDictionary *temporaryPaymentDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    //                                                           encTrack1AndTrack2, @"cc_track2data",
    //                                                           @"rambler", @"encryption_vendor",
    //                                                           ksn, @"encryption_ksn",
    //                                                           [NSNumber numberWithDouble:_shared_model.myLocationManager.location.coordinate.longitude], @"longitude",
    //                                                           [NSNumber numberWithDouble:_shared_model.myLocationManager.location.coordinate.latitude], @"latitude",
    //                                                           expiryMonth, @"cc_expiry_month",
    //                                                           expiryYear, @"cc_expiry_year",
    //                                                           my_redacted_string, @"cc_redacted_number"
    //
    //                                                           , nil];
    
    //        if (my_redacted_string.length > 0)
    //            [temporaryPaymentDictionary setObject:my_redacted_string forKey:@"cc_redacted_number"];
    
}
- (void)onGetKsnCompleted:(NSString *)ksn;{
    
}
- (void)onDecodeError:(ReaderControllerDecodeResult)decodeState;{
    
    NSString * message = decodeState == ReaderControllerDecodeResultSwipeFail ? @"We were unable to processing your credit card swipe. Please swipe again." :
    decodeState == ReaderControllerDecodeResultCRCError     ? @"There was an error while processing your credit card swipe." :
	decodeState == ReaderControllerDecodeResultCommError    ? @"There was a device communication error while processing your credit card swipe. Please wait a moment and swipe again." :
    @"There was an unkown error while processing your credit card swipe.";
    
    NSLog(@"Decode error: %@",message);
    
    if(self.swipeCompleteBlock){
        self.swipeCompleteBlock(nil,decodeState,message);
    }
    
}
- (void)onDecodingStart;{
    NSLog(@"decoding");
    if(self.stateChangedBlock){
        self.stateChangedBlock(DEVICE_DECODING);
    }
}
- (void)onError:(NSString *)errorMessage;{
    NSLog(@"error: %@",errorMessage);
    if(self.swipeCompleteBlock){
        self.swipeCompleteBlock(nil,0,errorMessage);
    }
}
- (void)onInterrupted;{
    NSLog(@"interrupted");
}
- (void)onNoDeviceDetected;{
    NSLog(@"waiting for device");
}
- (void)onTimeout;{
    NSLog(@"timeout");
    if([self.readerController getReaderState] == ReaderControllerStateIdle){
        NSLog(@"  restarting");
        [self.readerController startReader];
    }
}
- (void)onWaitingForCardSwipe;{
    NSLog(@"waiting for card swipe");
}
- (void)onWaitingForDevice;{
    NSLog(@"waiting for device");
    if(self.stateChangedBlock){
        self.stateChangedBlock(DEVICE_WAITING);
    }
}
- (void)onCardSwipeDetected;{
    NSLog(@"swipe detected");
    if(self.stateChangedBlock){
        self.stateChangedBlock(DEVICE_RECORDING);
    }
}
- (void)onDevicePlugged;{
    NSLog(@"device plugged in");
    if(self.stateChangedBlock){
        self.stateChangedBlock(DEVICE_PLUGGED_IN);
    }
}
- (void)onDeviceUnplugged;{
    NSLog(@"device unplugged");
    if(self.stateChangedBlock){
        self.stateChangedBlock(DEVICE_UNPLUGGED);
    }
}

@end
