//
//  speedoMeter.h
//  RC CAR
//
//  Created by Jakob Højgård Olsen on 18/12/13.
//  Copyright (c) 2013 Scott Cheezem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface speedoMeter : UIViewController{
    UIImageView *needleImageView;
	float speedometerCurrentValue;
	float prevAngleFactor;
	float angle;
	NSTimer *speedometer_Timer;
	UILabel *speedometerReading;
	NSString *maxVal;

}

@property(nonatomic,retain) UIImageView *needleImageView;
@property(nonatomic,assign) float speedometerCurrentValue;
@property(nonatomic,assign) float prevAngleFactor;
@property(nonatomic,assign) float angle;
@property(nonatomic,retain) NSTimer *speedometer_Timer;
@property(nonatomic,retain) UILabel *speedometerReading;
@property(nonatomic,retain) NSString *maxVal;

-(void) addMeterViewContents;
-(void) rotateIt:(float)angl;
-(void) rotateNeedle;
-(void) setSpeedometerCurrentValue;

@end
