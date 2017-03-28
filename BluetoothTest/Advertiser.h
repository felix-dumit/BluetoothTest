//
//  Advertiser.h
//  BluetoothTest
//
//  Created by Felix Dumit on 7/4/15.
//  Copyright (c) 2015 BlueTest. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Advertiser : NSObject

+(Advertiser *)sharedAdvertiser;
-(void)startAdvertising;
-(void)stopAdvertising;
-(BOOL)isAdvertising;
@end
