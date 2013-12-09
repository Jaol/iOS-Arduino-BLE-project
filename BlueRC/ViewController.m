//
//  ViewController.m
//  BlueRC
//
//  Created by user on 7/20/13.
//  Copyright (c) 2013 Scott Cheezem. All rights reserved.
//

#import "ViewController.h"




@interface ViewController ()

@end



@implementation ViewController{
    
}

@synthesize ble;
@synthesize gyro_x;
@synthesize gyro_y;
@synthesize gyro_z;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    motionManager = [[CMMotionManager alloc] init];
    
    ble = [[BLE alloc]init];
    [ble controlSetup:1];
    ble.delegate = self;
    self.analogStick.delegate = self;
    [self.connectButton addTarget:self action:@selector(scanForPeripherals:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateAnalogueLabel];
    
   }

-(IBAction)toggleUpdates:(id)sender {
	if ([sender isOn]) {
 [self doGyroUpdate];
        /*
		[motionManager startGyroUpdates];
		timer = [NSTimer scheduledTimerWithTimeInterval:1/30.0
												 target:self
											   selector:@selector(doGyroUpdate)
											   userInfo:nil
												repeats:YES];
         */
	} else {
		[motionManager stopGyroUpdates];
	}

}

-(void)doGyroUpdate {
	if([motionManager isGyroAvailable])
    {
        /* Start the gyroscope if it is not active already */
        if([motionManager isGyroActive] == NO)
        {
            /* Update us 2 times a second */
            [motionManager setGyroUpdateInterval:1.0f / 30.0f];
            
            /* Add on a handler block object */
            
            /* Receive the gyroscope data on this block */
            [motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
                                            withHandler:^(CMGyroData *gyroData, NSError *error)
             {
                 gyro_x = [[NSString alloc] initWithFormat:@"%.02f",gyroData.rotationRate.x];
                 self.x_txt.text = gyro_x;
                
                 x_val = gyroData.rotationRate.x;
                 
                 gyro_y = [[NSString alloc] initWithFormat:@"%.02f",gyroData.rotationRate.y];
                 self.y_txt.text = gyro_y;
                 
                  y_val = gyroData.rotationRate.y;
                 
                gyro_z = [[NSString alloc] initWithFormat:@"%.02f",gyroData.rotationRate.z];
                 self.z_txt.text = gyro_z;
                 
                  z_val = gyroData.rotationRate.z;
                 
                 
                 // CAST
                 
                 [self processGyroControls];
             }];
            
        }
    }
    else
    {
        NSLog(@"Gyroscope not Available!");
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateAnalogueLabel
{
	[self.x_txt setText:[NSString stringWithFormat:@"Gyro data readout"]];
}

#pragma mark - JSAnalogueStickDelegate

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick
{
    
    [self.x_txt setText:[NSString stringWithFormat:@"x: %f",self.analogStick.xValue]];
    [self.y_txt setText:[NSString stringWithFormat:@"y: %f",self.analogStick.yValue]];
    [self.z_txt setText:[NSString stringWithFormat:@"z: !"]];
    
    
	    [self processAnalogControls];
   
    
}


-(void)processAnalogControls{
    if([ble isConnected]){
        
        
        int scaledXval = self.analogStick.xValue;//*255;
    
        int scaledYval = self.analogStick.yValue*255;
        
        NSLog(@"X: %i - ,Y: %i",scaledXval,scaledYval);
        
        UInt8 buf[5] = {0x00, 0x00, 0x00, 0x00, 0x00};
        
        
        
        buf[1] = scaledXval;
        buf[3] = scaledYval;
        
        
        
        NSData *d = [[NSData alloc]initWithBytes:buf length:5];

        [ble write:d];
        
    }
}

-(void)processGyroControls{
     if([ble isConnected]){

        
        int scaledZval = abs(floorf((float)z_val*255));
        
        int scaledYval = abs(floorf((float)x_val*255));
        
        UInt8 buf[5] = {0x00, 0x00, 0x00, 0x00, 0x00};
        
        
        
        buf[1] = scaledZval;
        buf[3] = scaledYval;
        

        
        NSData *d = [[NSData alloc]initWithBytes:buf length:5];
        
        [ble write:d];
        
    }
}





#pragma mark - BLEDelegate
-(void)bleDidConnect{
    [self.connectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
    [self.connectButton removeTarget:self action:@selector(scanForPeripherals:) forControlEvents:UIControlEventTouchUpInside];
    [self.connectButton addTarget:self action:@selector(disconnectFromPeripheral) forControlEvents:UIControlEventTouchUpInside];
    //self.connectButton.enabled = YES;
    [self.connectButton setEnabled:YES];
}

-(void)bleDidDisconnect{
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.connectButton removeTarget:self action:@selector(disconnectFromPeripheral) forControlEvents:UIControlEventTouchUpInside];
    [self.connectButton addTarget:self action:@selector(scanForPeripherals:) forControlEvents:UIControlEventTouchUpInside];
    self.rssiLabel.text = @"RSSI";
    //self.connectButton.enabled = YES;
    [self.connectButton setEnabled:YES];
}

-(void)bleDidReceiveData:(unsigned char *)data length:(int)length{
    
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc]initWithData:d encoding:NSUTF8StringEncoding];
    
    if([s isEqualToString:@"1"]){
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    
    

}

-(void)bleDidUpdateRSSI:(NSNumber *)rssi{
    self.rssiLabel.text = [NSString stringWithFormat:@"RSSI:%@",rssi];
}

#pragma mark - BLE Actions
-(void)scanForPeripherals:(id)sender{
    
    if(ble.peripherals){
        ble.peripherals = nil;
    }
    
    //self.connectButton.enabled = NO;
    [self.connectButton setEnabled:NO];
    [ble findBLEPeripherals:2];
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
}

-(void)disconnectFromPeripheral{
    //self.connectButton.enabled = NO;
    [self.connectButton setEnabled:NO];
     //this seems like its for disconnecting...
     if(ble.activePeripheral){
         if (ble.activePeripheral.isConnected) {
             [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
         
         }
     }
}

-(void)connectionTimer:(NSTimer*)timer{
    //self.connectButton.enabled = YES;
    
    if(ble.peripherals.count > 0){
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }else{
        self.connectButton.enabled = YES;
    }
    
}


@end
