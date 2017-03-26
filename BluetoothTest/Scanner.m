//
//  Scanner.m
//  BluetoothTest
//
//  Created by Felix Dumit on 7/4/15.
//  Copyright (c) 2015 BlueTest. All rights reserved.
//

#import "Scanner.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Constants.h"

@interface Scanner ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableArray *peripherals;

@end

@implementation Scanner


+ (Scanner *)sharedScanner
{
    static Scanner *sharedInstance = nil;
    
    if (!sharedInstance) {
        sharedInstance = [Scanner new];
        sharedInstance.centralManager = [[CBCentralManager alloc] initWithDelegate:sharedInstance queue:nil options:@{ CBCentralManagerOptionShowPowerAlertKey: @YES }];
    }
    
    return sharedInstance;
}

- (NSMutableArray *)peripherals
{
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

- (NSArray *)foundPeripherals
{
    return self.peripherals.copy;
}

- (void)startScanning
{
    [self clearPeripherals];
    NSLog(@"Started scanning");
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @NO }];
}

- (void)stopScanning
{
    [self.centralManager stopScan];
}

- (void)clearPeripherals
{
    [self.peripherals removeAllObjects];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn && !central.isScanning) {
        [self startScanning];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Did discover peripheral: %@", peripheral.identifier);
    // [central connectPeripheral:peripheral options:nil];
    
    if(![self.peripherals containsObject:peripheral]) {
        [self.peripherals addObject:peripheral];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FOUNDPERIPHERAL" object:peripheral];
    }
}

@end
