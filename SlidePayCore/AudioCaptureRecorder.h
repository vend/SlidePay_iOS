//
//  AudioCaptureRecorder.h
//  AudioLibrary
//
//  Created by Anderthan Hsieh on 12/13/12.
//  Copyright (c) 2012 Anderthan Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReaderController.h"
#import <CoreLocation/CoreLocation.h>

@interface AudioCaptureRecorder : NSObject <ReaderControllerDelegate, CLLocationManagerDelegate>

+ (AudioCaptureRecorder *) sharedInstance;

@property (strong) CLLocationManager *myLocationManager;
@property (strong) ReaderController *myReaderController;
@property BOOL isRamblerActive;

- (void) setupRamblerDevice;
- (void) startupLocationManager;

@end
