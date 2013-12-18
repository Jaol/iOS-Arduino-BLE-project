//
//  speedoMeter.m
//  RC CAR
//
//  Created by Jakob Højgård Olsen on 18/12/13.
//  Copyright (c) 2013 Scott Cheezem. All rights reserved.
//

#import "speedoMeter.h"
#import <QuartzCore/QuartzCore.h>

@interface speedoMeter (){

}

@end

@implementation speedoMeter;
@synthesize needleImageView;
@synthesize speedometerCurrentValue;
@synthesize prevAngleFactor;
@synthesize angle;
@synthesize speedometer_Timer;
@synthesize speedometerReading;
@synthesize maxVal;



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addMeterViewContents];
	
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Public Methods

-(void) addMeterViewContents
{
	
	
	
	
	
	UIImageView *meterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, -5, 120 ,125)];
	meterImageView.image = [UIImage imageNamed:@"meter.png"];
	[self.view addSubview:meterImageView];
	
	
	
	//  Needle //
	UIImageView *imgNeedle = [[UIImageView alloc]initWithFrame:CGRectMake(57,46, 4, 30)];
	self.needleImageView = imgNeedle;

	self.needleImageView.layer.anchorPoint = CGPointMake(self.needleImageView.layer.anchorPoint.x, self.needleImageView.layer.anchorPoint.y*2);
	self.needleImageView.backgroundColor = [UIColor clearColor];
	self.needleImageView.image = [UIImage imageNamed:@"arrow.png"];
	[self.view addSubview:self.needleImageView];
	
	// Needle Dot //
	UIImageView *meterImageViewDot = [[UIImageView alloc]initWithFrame:CGRectMake(55, 58, 8,7)];
	meterImageViewDot.image = [UIImage imageNamed:@"center_wheel.png"];
	[self.view addSubview:meterImageViewDot];

	
	// Speedometer Reading //
	UILabel *tempReading = [[UILabel alloc] initWithFrame:CGRectMake(49, 78, 20, 15)];
	self.speedometerReading = tempReading;

	self.speedometerReading.textAlignment = NSTextAlignmentCenter;
	//self.speedometerReading.backgroundColor = [UIColor blackColor];
    self.speedometerReading.font=[UIFont fontWithName:@"Helvetica" size:9];
	self.speedometerReading.text= @"0";
	self.speedometerReading.textColor = [UIColor colorWithRed:10/255.f green:10/255.f blue:10/255.f alpha:1.0];
	[self.view addSubview:self.speedometerReading ];
	
	// Set Max Value //
	self.maxVal = @"100";
	
	/// Set Needle pointer initialy at zero //
	[self rotateIt:-130];
	
	// Set previous angle //
	self.prevAngleFactor = -130;
	
	// Set Speedometer Value //
	[self setSpeedometerCurrentValue];
}

#pragma mark -
#pragma mark calculateDeviationAngle Method

-(void) calculateDeviationAngle
{
	
	if([self.maxVal floatValue]>0)
	{
		self.angle = ((self.speedometerCurrentValue *237.4)/[self.maxVal floatValue])-118.4;  // 237.4 - Total angle between 0 - 100 //
	}
	else
	{
		self.angle = 0;
	}
	
	if(self.angle<=-118.4)
	{
		self.angle = -118.4;
	}
	if(self.angle>=119)
	{
		self.angle = 119;
	}
	
	
	// If Calculated angle is greater than 180 deg, to avoid the needle to rotate in reverse direction first rotate the needle 1/3 of the calculated angle and then 2/3. //
	if(abs(self.angle-self.prevAngleFactor) >180)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5f];
		[self rotateIt:self.angle/3];
		[UIView commitAnimations];
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5f];
		[self rotateIt:(self.angle*2)/3];
		[UIView commitAnimations];
		
	}
	
	self.prevAngleFactor = self.angle;
	
	
	// Rotate Needle //
	[self rotateNeedle];
	
	
}


#pragma mark -
#pragma mark rotateNeedle Method
-(void) rotateNeedle
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5f];
	[self.needleImageView setTransform: CGAffineTransformMakeRotation((M_PI / 180) * self.angle)];
	[UIView commitAnimations];
	
}

#pragma mark -
#pragma mark setSpeedometerCurrentValue

-(void) setSpeedometerCurrentValue
{
	if(self.speedometer_Timer)
	{
		[self.speedometer_Timer invalidate];
		self.speedometer_Timer = nil;
	}
	//self.speedometerCurrentValue =  arc4random() % 100; // Generate Random value between 0 to 100. //
	
	self.speedometer_Timer = [NSTimer  scheduledTimerWithTimeInterval:2 target:self selector:@selector(setSpeedometerCurrentValue) userInfo:nil repeats:YES];
	
   	self.speedometerReading.text = [NSString stringWithFormat:@"%.0f",self.speedometerCurrentValue];
	
	// Calculate the Angle by which the needle should rotate //
	[self calculateDeviationAngle];
}
#pragma mark -
#pragma mark Speedometer needle Rotation View Methods

-(void) rotateIt:(float)angl
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.01f];
	
	[self.needleImageView setTransform: CGAffineTransformMakeRotation((M_PI / 180) *angl)];
	
	[UIView commitAnimations];
}


@end
