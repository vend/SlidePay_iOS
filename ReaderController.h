//
//  ReaderController.h
//  ReaderAPI-1.3.1
//
//  Created by TeresaWong on 3/5/11.
//  Copyright 2011 BBPOS LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ReaderControllerStateIdle,
    ReaderControllerStateWaitingForDevice,
    ReaderControllerStateRecording,
	ReaderControllerStateDecoding
} ReaderControllerState;

typedef enum {
	ReaderControllerDecodeResultSwipeFail,
	ReaderControllerDecodeResultCRCError,
	ReaderControllerDecodeResultCommError,
	ReaderControllerDecodeResultUnknownError
} ReaderControllerDecodeResult;

@protocol ReaderControllerDelegate;

@interface ReaderController : NSObject {
	NSObject <ReaderControllerDelegate>* delegate;
	BOOL detectDeviceChange;
    ReaderControllerState readerState;
}

@property (nonatomic, assign) NSObject <ReaderControllerDelegate>* delegate;
@property (nonatomic, assign) BOOL detectDeviceChange;

- (BOOL)isDevicePresent;
- (void)startReader;
- (void)stopReader;
- (void)getReaderKsn;
- (ReaderControllerState)getReaderState;

@end

@protocol ReaderControllerDelegate <NSObject>

- (void)onDecodeCompleted:(NSString *)formatID
                      ksn:(NSString *)ksn
	   encTrack1AndTrack2:(NSString *)encTrack1AndTrack2
             track1Length:(int)track1Length
             track2Length:(int)track2Length
                maskedPAN:(NSString *)maskedPAN
               expiryDate:(NSString *)expiryDate
           cardHolderName:(NSString *)cardHolderName;
- (void)onGetKsnCompleted:(NSString *)ksn;
- (void)onDecodeError:(ReaderControllerDecodeResult)decodeState;
- (void)onDecodingStart;
- (void)onError:(NSString *)errorMessage;
- (void)onInterrupted;
- (void)onNoDeviceDetected;
- (void)onTimeout;
- (void)onWaitingForCardSwipe;
- (void)onWaitingForDevice;
- (void)onCardSwipeDetected;

@optional
- (void)onDevicePlugged;
- (void)onDeviceUnplugged;

@end
