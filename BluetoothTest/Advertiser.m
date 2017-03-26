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

@property (strong, nonatomic) CBMutableCharacteristic* transferCharacteristic;
@property (strong, nonatomic) CBMutableService* transferService;
@property (strong, nonatomic) CBPeripheralManager* peripheralManager;
@property (strong, nonatomic) NSDateFormatter* dateFormatter;
@property BOOL addedService;
@property BOOL wantsToAdvertise;

@end

@implementation Advertiser

+(void)load {
    if([CBPeripheralManager authorizationStatus] >= CBPeripheralManagerAuthorizationStatusAuthorized) {
#warning WITHOUT THIS IT WONT WORK IN THE BACKGROUND ?!?!!
        [[self sharedAdvertiser] setup];
    }
}

+(Advertiser *)sharedAdvertiser {
    static Advertiser *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [Advertiser new];
    }
    return sharedInstance;
}

-(instancetype)init {
    if(self = [super init]) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.timeStyle = NSDateFormatterLongStyle;
    }
    return self;
}

-(void)setup {
    [self peripheralManager];
    [self transferService];
}

-(CBPeripheralManager *)peripheralManager {
    if(!_peripheralManager) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:nil queue:nil];
    }
    return _peripheralManager;
}

-(CBMutableService *)transferService {
    if(!_transferService) {
        // Start with the CBMutableCharacteristic
        self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                         properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyWrite
                                                                              value:nil
                                                                        permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
        
        // Then the service
        self.transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                              primary:YES];
        
        // Add the characteristic to the service
        _transferService.characteristics = @[self.transferCharacteristic];
    }
    return _transferService;
}

-(void)stopAdvertising {
    self.wantsToAdvertise = NO;
    [self.peripheralManager stopAdvertising];
}

-(void)startAdvertising {
    _wantsToAdvertise = YES;
    if(self.peripheralManager.state >= CBPeripheralManagerStatePoweredOn) {
        if(!self.addedService) {
            [self.peripheralManager addService:self.transferService];
        } else {
            [self.peripheralManager startAdvertising:@{
                                                       CBAdvertisementDataServiceUUIDsKey :
                                                           @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                       }];
        }
    }
}

#pragma mark - Peripheral Methods
-(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error {
    NSLog(@"Peripheral didStartAdvertising: %@", error);
}


- (void)peripheralManagerDidUpdateState:(CBPeripheralManager*)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    if(_wantsToAdvertise && !self.peripheralManager.isAdvertising) {
        [self startAdvertising];
    }
}



-(void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error {
    if(error) {
        NSLog(@"Error adding service: %@", error);
    } else {
        self.addedService = YES;
        if(_wantsToAdvertise && !self.peripheralManager.isAdvertising) {
            [self startAdvertising];
        }
    }
}

@end
