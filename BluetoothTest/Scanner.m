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
@property BOOL wantsToScan;
@property NSTimer* resetTimer;

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
    CBUUID* uuid1 = [CBUUID UUIDWithString:SERVICE_UUID];
    CBUUID* uuid2 = [CBUUID UUIDWithString:OTHER_SERVICE_UUID];
    [self.centralManager scanForPeripheralsWithServices:@[uuid1]
                                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
    _wantsToScan = YES;
    self.resetTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                              target:self
                                            selector:@selector(clearPeripherals)
                                            userInfo:Nil
                                             repeats:YES];
}

- (void)stopScanning
{
    NSLog(@"Stopped scanning");
    [self.centralManager stopScan];
    _wantsToScan = NO;
    [self.resetTimer invalidate];
    self.resetTimer = nil;
}

-(BOOL)isScanning
{
    return self.centralManager.isScanning;
}

- (void)clearPeripherals
{
    [self.peripherals removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FOUNDPERIPHERAL" object:nil];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn && !central.isScanning && _wantsToScan) {
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
