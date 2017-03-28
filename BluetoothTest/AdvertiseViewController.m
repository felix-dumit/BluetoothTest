//
//  AdvertiseViewController.m
//  BluetoothTest
//
//  Created by Felix Dumit on 7/4/15.
//  Copyright (c) 2015 BlueTest. All rights reserved.
//

#import "AdvertiseViewController.h"
#import "Advertiser.h"

@interface AdvertiseViewController ()
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

@implementation AdvertiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.button.selected = [Advertiser sharedAdvertiser].isAdvertising;
}

- (IBAction)startSelected:(UIButton*)sender {
    sender.selected = !sender.selected;
    if(sender.selected){
        [[Advertiser sharedAdvertiser] startAdvertising];
    } else {
        [[Advertiser sharedAdvertiser] stopAdvertising];
    }
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
