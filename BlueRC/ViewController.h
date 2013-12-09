//
//  ViewController.h
//  BlueRC
//
//  Created by user on 7/20/13.
//  Copyright (c) 2013 Scott Cheezem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMotion/CoreMotion.h>
#import "JSAnalogueStick.h"
#import "BLE.h"
@interface ViewController : UIViewController<JSAnalogueStickDelegate, BLEDelegate>
{
    
	CMMotionManager *motionManager;
	NSTimer *timer;
	float z_rotation;
	float x_rotation;
    
    float x_val;
	float y_val;
    float z_val;

}
@property (weak, nonatomic) IBOutlet JSAnalogueStick *analogStick;
@property (strong, nonatomic) IBOutlet UILabel *x_txt;
@property (strong, nonatomic) IBOutlet UILabel *y_txt;
@property (strong, nonatomic) IBOutlet UILabel *z_txt;

@property (strong, nonatomic) IBOutlet NSString *gyro_x;
@property (strong, nonatomic) IBOutlet NSString *gyro_y;
@property (strong, nonatomic) IBOutlet NSString *gyro_z;


@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (nonatomic, strong) BLE *ble;
- (IBAction)toggleUpdates:(id)sender;



@end
