mobile-slidepay-core
=====================

## About
The SlidePay iOS SDK allows you to incorporate swiped and keyed credit card transactions into your iOS application.


## Code Snippets
Before using any other parts of the API, you must authenticate:

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
                                                                        @"vendor":@"magensa",
                                                                        @"ksn":@"the device ksn",
                                                                        @"trackdata":<getResponseData from your magtek library>,
                                                                        @"serial":@"device serial"
                                                                        }];
    payment.amount = @1;
    [payment payWithSuccessHandler:^(NSInteger paymentID, NSInteger orderID, NSData *responseData) {
       
        NSLog(@"magensa response: %@",response);
        [self refund:paymentID];
        
    } failure:^(NSInteger serverCode, NSString *serverMessage, NSError *error) {
    
    }];
```

## License

The MIT License (MIT)

Copyright (c) 2013 SlidePay


##Contact

Please contact api@slidepay.com for any questions.

