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

+ (void)startScanning
{
    [[self sharedScanner] scan];
}

+ (void)stopScanning
{
    [[self sharedScanner].centralManager stopScan];
}

+ (NSArray *)foundPeripherals
{
    return [self sharedScanner].peripherals;
}

- (void)scan
{
    [self clearPeripherals];
    NSLog(@"Started scanning");
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @NO }];
}

- (void)clearPeripherals
{
    [self.peripherals removeAllObjects];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn && !central.isScanning) {
        [self scan];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Did discover peripheral: %@", peripheral.identifier);
    //    [central connectPeripheral:peripheral options:nil];
    [central connectPeripheral:peripheral options:nil];
    
    if(![self.peripherals containsObject:peripheral]) {
        [self.peripherals addObject:peripheral];
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[
                                   [CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                   ]];
}

#pragma mark - CBPeripheralDelegate

-(void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    NSLog(@"Read RSSI: %@ - %@", peripheral, RSSI);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]
                                 forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        //[self cleanup];
        return;
    }
    
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        // And check if it's the right one
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            [peripheral writeValue:[@"WRITE_DATA_HERE" dataUsingEncoding:NSUTF8StringEncoding]
                 forCharacteristic:characteristic
                              type:CBCharacteristicWriteWithResponse];
//            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSString* string = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSLog(@"Did update value for characteristic: %@", string);
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Wrote value for characteristic: %@", error);
}


@end
