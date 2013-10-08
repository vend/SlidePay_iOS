//
//  ReaderController.h
//  ReaderAPI-2.0.0.-beta1
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

- (void)onDecodeCompleted:(NSDictionary *)data;
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
