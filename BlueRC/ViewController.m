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

@implementation ViewController

@synthesize ble;
@synthesize gyro_x;
@synthesize gyro_y;
@synthesize gyro_z;
@synthesize speedCtl;
@synthesize mainView;
@synthesize speedoView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    speedoMeterClass = [[speedoMeter alloc] init];
    
    [speedoView addSubview:[speedoMeterClass view]];

    [speedoMeterClass addMeterViewContents];
    
    movingValueFB = -1;
    movingValueFB = -1;
    motionManager = [[CMMotionManager alloc] init];
    ble = [[BLE alloc]init];
    [ble controlSetup:1];
    ble.delegate = self;
    [self.connectButton addTarget:self action:@selector(scanForPeripherals:) forControlEvents:UIControlEventTouchUpInside];
    [self updateAnalogueLabel];
    scaleFactor = 0;

    
   }




-(IBAction)toggleUpdates:(id)sender {
	if ([sender isOn]) {
        [self doGyroUpdate];
	} else {
		[motionManager stopAccelerometerUpdates];
	}
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)updateAnalogueLabel
{
	[self.x_txt setText:[NSString stringWithFormat:@"Ready!"]];
}


- (void)speedUP:(NSTimer *)timer
{
    if(scaleFactor != 0){
    speedoMeterClass.speedometerCurrentValue = speedCounter/scaleFactor;
    }else{
        speedoMeterClass.speedometerCurrentValue = speedCounter;
    }
    [speedoMeterClass setSpeedometerCurrentValue];
    //NSLog(@"UP : %i",speedCounter);
    
    if(speedCounter >= 100)
    {
        
        [speedTimerUP invalidate];
        speedTimerUP = nil;
        //speedCounter = 0;
        
    }else{
    speedCounter++;
    }
}

- (void)speedDOWN:(NSTimer *)timer
{
    speedoMeterClass.speedometerCurrentValue = speedCounter/scaleFactor;
    [speedoMeterClass setSpeedometerCurrentValue];
    
     //NSLog(@"DOWN : %f",self.speedbar.progress);
    if(speedCounter == 0)
    {
        [speedTimerDOWN invalidate];
        speedTimerDOWN = nil;
        speedCounter = 0;
        
    }else{
        speedCounter--;
    }
}


-(void)startSpeedometer{
    [speedTimerDOWN invalidate];
    speedTimerDOWN = nil;
    speedTimerUP = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(speedUP:) userInfo:nil repeats:YES];
}


-(void)stopSpeedometer{
    [speedTimerUP invalidate];
    speedTimerUP = nil;
    speedTimerDOWN = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(speedDOWN:) userInfo:nil repeats:YES];

}

-(IBAction)forward{
    movingValueFB = 5;[self processAnalogControls];
    [self startSpeedometer];
     /*
    timerForward = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(goForward) userInfo:nil repeats:YES];
    if(timerForward == nil)
        timerForward = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(goForward) userInfo:nil repeats:YES];
     */
};
-(IBAction)forwardStop{
    [self stopSpeedometer];
    
    movingValueFB = 99;[self processAnalogControls];
};

-(IBAction)backward{
    movingValueFB = 1;[self processAnalogControls];
    
    /*
    timerBackward = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(goBackward) userInfo:nil repeats:YES];
    if(timerBackward == nil)
        timerBackward = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(goBackward) userInfo:nil repeats:YES];
     */
    
};
-(IBAction)backwardStop{
    //[timerBackward invalidate];
    //timerBackward = nil;
    movingValueFB = 99;[self processAnalogControls];
};

-(IBAction)left{
    movingValueLR = 6;[self processAnalogControls];
    /*
    timerLeft = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(goLeft) userInfo:nil repeats:YES];
    if(timerLeft == nil)
        timerLeft = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(goLeft) userInfo:nil repeats:YES];
     */
};
-(IBAction)leftStop{
    //[timerLeft invalidate];
    //timerLeft = nil;
    movingValueLR = 99;[self processAnalogControls];
};

-(IBAction)right{
    movingValueLR = 2;[self processAnalogControls];
    /*
    timerRight = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(goRight) userInfo:nil repeats:YES];
    if(timerRight == nil)
        timerRight = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(goRight) userInfo:nil repeats:YES];
    */
};
-(IBAction)rightStop{
    //[timerRight invalidate];
    //timerRight = nil;
    movingValueLR = 99;[self processAnalogControls];
};


-(void)goForward{};
-(void)goBackward{};
-(void)goLeft{};
-(void)goRight{};

-(void)processAnalogControls{

    if(movingValueFB == 0)
    movingValueFB =99;
    
    if(movingValueLR == 0)
    movingValueLR =99;
    
    if([ble isConnected]){
        
        //buf[]={scaledValForMotor1, dirForMotor1(HIGH|LOW),scalevValForMotor2, dirForMotor2(HIGH|LOW) NULL}
        UInt8 buf[5] = {0x00, 0x00, 0x00, 0x00, 0x00};
        
        
        buf[0] = movingValueFB;
        buf[2] = speedValue;//movingValueLR;
        buf[1] = 99;
        buf[3] = speedValue;//99;
        buf[4] = speedValue;
        
        
        if(movingValueFB == 5){
        buf[1] = 255;
        }
        
        else if(movingValueFB == 1){
        buf[1] = 0;
        }
        else if(movingValueFB == -1){
            buf[1] = 99;
            buf[0] = 99;
        }
        
        if(movingValueLR == 6){
            buf[3] = 255;
        
        }else if(movingValueLR == 2) {
            buf[3] = 0;
        }else if(movingValueLR == -1){
            buf[3] = 99;
            buf[2] = 99;
        }
        
        NSData *d = [[NSData alloc]initWithBytes:buf length:5];
        NSLog(@"%@",d);
        [ble write:d];
    }
}


-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    
    
    
    self.x_txt.text = [NSString stringWithFormat:@" %.2fg",acceleration.x];
    if(fabs(acceleration.x) > fabs(currentMaxAccelX))
    {
        currentMaxAccelX = acceleration.x;
    }
    self.y_txt.text = [NSString stringWithFormat:@" %.2fg",acceleration.y];
    if(fabs(acceleration.y) > fabs(currentMaxAccelY))
    {
        currentMaxAccelY = acceleration.y;
    }
    self.z_txt.text = [NSString stringWithFormat:@" %.2fg",acceleration.z];
    if(fabs(acceleration.z) > fabs(currentMaxAccelZ))
    {
        currentMaxAccelZ = acceleration.z;
    }
    
    
    // Forward / backward

        
        if(acceleration.x < -0.25){
            
            movingValueFB = 5;
            //NSLog(@"Forward command");
        }if(acceleration.x > 0.25){
            movingValueFB = 1;
            //NSLog(@"Backward command");
           
        }else if(acceleration.x < 0.2 && acceleration.x > -0.2){
            //NSLog(@"stop F/B command");
                       movingValueFB = 99;
        }
    if (fabs(acceleration.x) > .2) {
        [self processGyroControls];
       
       // NSLog(@"FB signal sent...");
    }
     // Left / Right
    
        
        if(acceleration.y < -0.25){
            movingValueLR = 6;
            //NSLog(@"Left command");
        }if(acceleration.y > 0.25){
            movingValueLR = 2;
            //NSLog(@"Right command");
        }else if(acceleration.y < 0.2 && acceleration.y > -0.2){
            //NSLog(@"stop L/R command");
            movingValueLR = 99;
        }
      if (fabs(acceleration.y) > .2) {
        [self processGyroControls];
     //NSLog(@"LR signal sent...");

      }
    
}
-(void)outputRotationData:(CMRotationRate)rotation
{
    
    //self.rotX.text = [NSString stringWithFormat:@" %.2fr/s",rotation.x];
    if(fabs(rotation.x) > fabs(currentMaxRotX))
    {
        currentMaxRotX = rotation.x;
    }
    //self.rotY.text = [NSString stringWithFormat:@" %.2fr/s",rotation.y];
    if(fabs(rotation.y) > fabs(currentMaxRotY))
    {
        currentMaxRotY = rotation.y;
    }
    //self.rotZ.text = [NSString stringWithFormat:@" %.2fr/s",rotation.z];
    if(fabs(rotation.z) > fabs(currentMaxRotZ))
    {
        currentMaxRotZ = rotation.z;
    }
    
  }

-(void)doGyroUpdate {
    
    
    motionManager.accelerometerUpdateInterval = .2;
    
    [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
    withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
    [self outputAccelertionData:accelerometerData.acceleration];
    if(error){NSLog(@"%@", error);} }];
    
}

-(void)processGyroControls{
    if(movingValueFB == 0)
        movingValueFB =99;
    
    if(movingValueLR == 0)
        movingValueLR =99;
    
    if([ble isConnected]){
        
        //buf[]={scaledValForMotor1, dirForMotor1(HIGH|LOW),scalevValForMotor2, dirForMotor2(HIGH|LOW) NULL}
        UInt8 buf[5] = {0x00, 0x00, 0x00, 0x00, 0x00};
        
        
        buf[0] = movingValueFB;
        buf[2] = movingValueLR;
        buf[1] = 99;
        buf[3] = speedValue;
        //buf[4] = speedValue;
        
        if(movingValueFB == 5){
            buf[1] = 255;
        }
        
        else if(movingValueFB == 1){
            buf[1] = 0;
        }
        else if(movingValueFB == -1){
            buf[1] = 99;
            buf[0] = 99;
        }
        
        if(movingValueLR == 6){
            buf[3] = 255;
            
        }else if(movingValueLR == 2) {
            buf[3] = 0;
        }else if(movingValueLR == -1){
            buf[3] = 99;
            buf[2] = 99;
        }
        
        NSData *d = [[NSData alloc]initWithBytes:buf length:5];
        
        [ble write:d];
        
    }
}






#pragma mark - BLEDelegate
-(void)bleDidConnect{
    [self.connectButton setTitle:@"ON" forState:UIControlStateNormal];
[self.connectButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.connectButton removeTarget:self action:@selector(scanForPeripherals:) forControlEvents:UIControlEventTouchUpInside];
    [self.connectButton addTarget:self action:@selector(disconnectFromPeripheral) forControlEvents:UIControlEventTouchUpInside];
    //self.connectButton.enabled = YES;
    [self.connectButton setEnabled:YES];
}

-(void)bleDidDisconnect{
    [self.connectButton setTitle:@"OFF" forState:UIControlStateNormal];
    [self.connectButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.connectButton removeTarget:self action:@selector(disconnectFromPeripheral) forControlEvents:UIControlEventTouchUpInside];
    [self.connectButton addTarget:self action:@selector(scanForPeripherals:) forControlEvents:UIControlEventTouchUpInside];
    self.rssiLabel.text = @"RSSI";
    //self.connectButton.enabled = YES;
    [self.connectButton setEnabled:YES];
}

-(void)bleDidReceiveData:(unsigned char *)data length:(int)length{
    
    self.returnLabel.text = @"";
    
    NSData *d = [NSData dataWithBytes:data length:length];
    NSString *s = [[NSString alloc]initWithData:d encoding:NSUTF8StringEncoding];
    
    if([s isEqualToString:@"1"]){
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
    
    self.returnLabel.text = s;
    
    NSLog(@"%@",s);

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


- (IBAction)speedCtlAction:(id)sender {
    
 
    switch (speedCtl.selectedSegmentIndex) {
        case 0:
            NSLog(@"0");
            speedValue = 771;
            scaleFactor = 0;

            break;
        case 1:
            NSLog(@"1");
            speedValue = 772;
            scaleFactor = 2;

            break;
        case 2:
            NSLog(@"2");
            speedValue = 773;
            scaleFactor = 2.5;

            break;
        default:
            break;
    }
    
}
@end
