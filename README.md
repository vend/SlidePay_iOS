SlidePay iOS
=====================

The SlidePay iOS SDK allows you to incorporate swiped and keyed credit card transactions into your iOS application.

# Installation
You'll need [cocoapods](http://cocoapods.org/). Once that's been installed, open the terminal and create a podfile:

```
$ cd /path/to/MyProject
$ edit Podfile
platform :ios, '5.0'
pod 'SlidePay_iOS', :git => 'https://github.com/SlidePay/SlidePay_iOS.git'
```

The SlidePay iOS SDK isn't in the main podspec repo [yet], so specifying the repo via :git will have to do in the interim. If you already have a podfile, then add our repo to your list of pods. 

Finally, do:
```
$ pod install
```
Make sure, as per the instructions that were spit out during the install, to only use the MyProject.xcworkspace when building your project.

#Subspecs

The subspecs can, broadly, be divided into two categories: hardware, and everything else. If you're using your own solution for swiping (or don't care about it), then you only need the 'Payments' subspec. Your podfile would look like: 

```
platform :ios, '5.0'
pod 'SlidePay_iOS/Payments', :git => 'https://github.com/SlidePay/SlidePay_iOS.git'
```

If you wanted to swipe with the rambler and then process the payment elsewhere (on your backend using the Ruby SDK, for example), then your podfile would have:

```
platform :ios, '5.0'
pod 'SlidePay_iOS/Rambler', :git => 'https://github.com/SlidePay/SlidePay_iOS.git'
```

#SDK Use
This section covers the use, along with example code, for the various API components.

##Rambler
```objc
#import <SlidePay_iOS/SwipeListener.h>
```

```objc

    self.listener = [SwipeListener new];
    __weak typeof(self) weakself = self;
    self.listener.swipeCompleteBlock = ^(NSDictionary *swipe, int errorCode, NSString *errorMessage){
        typeof(self) strongSelf = weakself;
        if(errorCode > 0 || errorMessage){
            //notify the user
        }else{
            //make the payment
        }
        [strongSelf.listener start]; //restart the listener
    };
    
    self.listener.stateChangedBlock  = ^(RamblerState state){
        typeof(self) strongSelf = weakself;
        if(state == DEVICE_PLUGGED_IN){
            [strongSelf.listener start];
        }else if (state == DEVICE_UNPLUGGED){
            //
        }else{
            if(state == DEVICE_IDLE){
                
            }else if (state == DEVICE_WAITING_SWIPE){
                
            }else if (state == DEVICE_RECORDING){
                
            }else if (state == DEVICE_DECODING){
                
            }
        }
    };
```

##Payments
```objc
#import <SlidePay_iOS/SPPayment.h>
#import <SlidePay_iOS/SPAuthenticate.h>
```

Before using any other parts of the Payments API, you must authenticate:

```objc
    SPAuthenticate *auth = [SPAuthenticate new];
    auth.username = @"username@whatever.com";
    auth.password = @"password";
    [auth login:^{
        NSLog(@"auth successs");
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        NSLog(@"auth fail");
    }];
```

Once you've successfully authenticated, you can start to make, get, and refund payments.

A keyed in transaction:
```objc
    SPPayment *payment = [[SPPayment alloc] initWithCardNumber:@"4111111111111111" zipCode:@"11111" cvv:@"111" expMonth:@"04" expYear:@"15"];
    payment.amount = @1;
    [payment payWithSuccessHandler:^(NSInteger paymentID, NSInteger orderID, NSData *responseData) {
        
        NSLog(@"response: %@",response);
        [self refund:paymentID];
        
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {

    }];
```

A swiped Magensa transaction:
```objc
SPPayment *payment = [[SPPayment alloc] initWithPaymentDictionary:@{
                                                                        @"encryption_vendor":@"magensa",
                                                                        @"encryption_ksn":<device ksn>
                                                                        @"cc_track2data":<getResponseData from your magtek library>,
                                                                        @"encryption_device_serial":<device serial>
                                                                        }];
    payment.amount = @1;
    [payment payWithSuccessHandler:^(NSInteger paymentID, NSInteger orderID, NSData *responseData) {
       
        NSLog(@"magensa response: %@",response);
        [self refund:paymentID];
        
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
    
    }];
```

#Swipe and Pay

```objc
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.listener = [SwipeListener new];
    __weak typeof(self) weakself = self;
    self.listener.swipeCompleteBlock = ^(NSDictionary *swipe, int errorCode, NSString *errorMessage){
        typeof(self) strongSelf = weakself;
        if(errorCode > 0 || errorMessage){
            //notify the user
        }else{
            //make the payment
            [self performPayment:swipe];
        }
        [strongSelf.listener start]; //restart the listener
    };
    
    self.listener.stateChangedBlock  = ^(RamblerState state){
        typeof(self) strongSelf = weakself;
        if(state == DEVICE_PLUGGED_IN){
            [strongSelf.listener start];
        }else if (state == DEVICE_UNPLUGGED){
            
        }else{
            if(state == DEVICE_IDLE){
                
            }else if (state == DEVICE_WAITING_SWIPE){
                
            }else if (state == DEVICE_RECORDING){
                
            }else if (state == DEVICE_DECODING){
                
            }
        }
    };
}

-(void) performPayment:(NSDictionary*)_swipe{
    NSMutableDictionary * swipe = [_swipe mutableCopy];
    double amount = [self amountToCharge]; //a method you wrote to get the amount to charge
    SPPayment *payment = [[SPPayment alloc] initWithPaymentDictionary:swipe];
    payment.amount = @(amount);
    [payment payWithSuccessHandler:^(NSInteger paymentID, NSInteger orderID, NSData *responseData) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Payment successful!" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self performRefund:paymentID]; //when testing, it's nice to refund every transaction after completing it.
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        NSString * message = @"";
        NSString * title = @"Payment failed.";
        if(serverCode > 0){
            title  = [NSString stringWithFormat:@"Payment failed with error %d",serverCode];
        }
        if(serverMessage){
            message = serverMessage;
        }else if (error){
            NSLog(@"error submitting payment: %@",error);
            message = error.localizedDescription;
        }
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
}

-(void) performRefund:(NSInteger)paymentID{
    [SPPayment refundPaymentWithID:paymentID success:^(NSInteger paymentID) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Refund successful!" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
        NSString * title = @"Error";
        NSString * message = @"Refund failed.";
        if(serverCode > 0){
            title  = [NSString stringWithFormat:@"Error %d",serverCode];
        }
        if(serverMessage){
            message = serverMessage;
        }else if (error){
            NSLog(@"error submitting refund: %@",error);
        }
        [self presentAlertViewWithMessage:message errorCode:serverCode title:@"Error Making Payment"];
    }];
}
```

For a more detailed example, please see our iPhone test app.

# License

The MIT License (MIT)

Copyright (c) 2013 SlidePay


#Contact

Please contact api@slidepay.com with any questions.

