//
//  ScanViewController.m
//  BluetoothTest
//
//  Created by Felix Dumit on 7/4/15.
//  Copyright (c) 2015 BlueTest. All rights reserved.
//

#import "ScanViewController.h"
#import "Scanner.h"
#import <CoreLocation/CoreLocation.h>

@interface ScanViewController ()

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;

@end

@implementation ScanViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLabel) name:@"FOUNDPERIPHERAL" object:nil];
}

- (IBAction)buttonSelected:(UIButton*)sender {
    
    sender.selected = !sender.selected;
    if(sender.selected){
        [self startScan];
    } else {
        [self stopScan];
    }
}

-(void)startScan {
    [Scanner startScanning];
    [self updateLabel];
}

-(void)stopScan {
    [Scanner stopScanning];
    [self updateLabel];
}

-(void)updateLabel {
    self.resultLabel.text = [Scanner foundPeripherals].description;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
