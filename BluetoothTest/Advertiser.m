//
//  Advertiser.m
//  BluetoothTest
//
//  Created by Felix Dumit on 7/4/15.
//  Copyright (c) 2015 BlueTest. All rights reserved.
//

#import "Advertiser.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "Constants.h"

@interface Advertiser ()<CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager* peripheralManager;
@property (strong, nonatomic) NSDateFormatter* dateFormatter;

@end

@implementation Advertiser


+ (Advertiser *)sharedAdvertiser {
    static Advertiser *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [Advertiser new];
        sharedInstance.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:sharedInstance queue:nil options:@{CBPeripheralManagerOptionShowPowerAlertKey : @YES}];
        sharedInstance.dateFormatter = [[NSDateFormatter alloc] init];
        sharedInstance.dateFormatter.timeStyle = NSDateFormatterLongStyle;
    }
    return sharedInstance;
}


+(void)startAdvertising {
    [[self sharedAdvertiser] advertise];
}

+(void)stopAdvertising {
    [[self sharedAdvertiser].peripheralManager stopAdvertising];
}

-(void)advertise {
    [self.peripheralManager startAdvertising:@{
                                               CBAdvertisementDataServiceUUIDsKey :
                                                   @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                               }];
    
}

#pragma mark - Peripheral Methods

/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
//    NSData* data = [@"CHARDATA" dataUsingEncoding:NSUTF8StringEncoding];
    
    // Start with the CBMutableCharacteristic
    CBMutableCharacteristic* transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                                         properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite
                                                                                              value:nil
                                                                                        permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
    
//    CBMutableCharacteristic* chars2 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"D7FE2CF9-8CCD-4B4B-8CB1-39FB15190DE8"]
//                                                                                         properties:CBCharacteristicPropertyRead
//                                                                                              value:nil
//                                                                                        permissions:CBAttributePermissionsReadable];
//    
//    CBMutableCharacteristic* chars3 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"41F8162C-0941-4C36-894E-ECFB4C2C0CA8"]
//                                                                         properties:CBCharacteristicPropertyWrite
//                                                                              value:nil
//                                                                        permissions: CBAttributePermissionsWriteable];
//    
//    CBMutableCharacteristic* chars4 = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:@"7C9EF2CC-3A2D-4724-8C61-69B282895C58"]
//                                                                         properties:CBCharacteristicPropertyRead
//                                                                              value:nil
//                                                                        permissions:CBAttributePermissionsWriteable];
    
    // Then the service
    CBMutableService* transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    transferService.characteristics = @[
                                        transferCharacteristic//, chars2, chars3, chars4
                                        ];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    [self advertise];
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager*)peripheral central:(CBCentral*)central didUnsubscribeFromCharacteristic:(CBCharacteristic*)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    
    [peripheral setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow forCentral:request.central];
    
    NSLog(@"Did receive read request: %@", request);
    
    NSData* data = nil;
    
    if ([request.characteristic.UUID.UUIDString isEqualToString:TRANSFER_CHARACTERISTIC_UUID]) {
        NSString* string =  [self.dateFormatter stringFromDate:[NSDate date]];
        data = [string dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if(!data){
        return [peripheral respondToRequest:request withResult:CBATTErrorInvalidHandle];
    }
    
    if(request.offset > data.length) {
        [peripheral respondToRequest:request withResult:CBATTErrorInvalidOffset];
    } else {
        NSRange range = NSMakeRange(request.offset, data.length - request.offset);
        request.value = [data subdataWithRange:range];
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    for (CBATTRequest *req in requests) {
        NSString* string = [[NSString alloc] initWithData:req.value encoding:NSUTF8StringEncoding];
        NSLog(@"Did receibe write request: %@ - %@", req, string);
        
        [peripheral setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow forCentral:req.central];
        
        //TODO: see if needs to handle offsets
        
        // if it is a new contact request
        if ([req.characteristic.UUID.UUIDString isEqualToString:TRANSFER_CHARACTERISTIC_UUID]) {
            [peripheral respondToRequest:req withResult:CBATTErrorSuccess];
        } else {
            [peripheral respondToRequest:req withResult:CBATTErrorWriteNotPermitted];
        }
    }
}


@end
