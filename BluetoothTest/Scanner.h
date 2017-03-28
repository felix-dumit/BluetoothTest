//
//  Scanner.h
//  BluetoothTest
//
//  Created by Felix Dumit on 7/4/15.
//  Copyright (c) 2015 BlueTest. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Scanner : NSObject

+ (Scanner *)sharedScanner;

-(void)startScanning;
-(void)stopScanning;

-(NSArray*)foundPeripherals;
-(BOOL)isScanning;

@end
