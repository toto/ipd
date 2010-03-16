//
//  mainViewController.m
//  iPdTestMilestone1
//
//  Created by Niv on 10-02-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "mainViewController.h"
#import "iPdAdapter.h"
#include <stdlib.h>

@implementation mainViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / 60.0];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	filter = [[HighpassFilter alloc] initWithSampleRate:60.0 cutoffFrequency:5.0];
	trackAxis = NO;
	bangcount = 0;
	countLabel = [[UILabel alloc] initWithFrame:[self.view bounds]];
	[countLabel setText:[NSString stringWithFormat:@"Bang count: %d", bangcount]];
	[self.view addSubview:countLabel];
	
	//sounds :D
	NSBundle *mainBundle = [NSBundle mainBundle];	
	bassSound = [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"bass" ofType:@"wav"]];
	hatSound =  [[SoundEffect alloc] initWithContentsOfFile:[mainBundle pathForResource:@"hat" ofType:@"wav"]];
	
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[filter release];
	[countLabel release];
	[bassSound release];
	[hatSound release];
    [super dealloc];
}

//02/14/2010 I need to test the inter-process communication somehow...
#pragma mark Touch Handling				

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView:self.view];
	
	trackAxis = !trackAxis;
	

	[[iPdAdapter sharediPdAdapter] sendBangToInlet:0];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView:self.view];
	
	[[iPdAdapter sharediPdAdapter] sendFloat:location.y toInlet:1];
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	//NSLog(@"Test");
	//    UITouch *touch = [[event allTouches] anyObject];
	//    CGPoint location = [touch locationInView:self];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

#pragma mark Accelerometer Handling

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (motion == UIEventSubtypeMotionShake) {
		trackAxis = !trackAxis;
		NSLog(@"Got here");
		[[iPdAdapter sharediPdAdapter] sendBangToInlet:0];
	}
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	// Update the accelerometer graph view
	if(trackAxis)
	{
		[filter addAcceleration:acceleration];
//		[[iPdAdapter sharediPdAdapter] sendFloat:filter.x toInlet:1];
	}
}

-(void)bang {
	NSLog(@"Sent a bang. Random: %f", (float) rand() / RAND_MAX);
	bangcount++;
	[countLabel setText:[NSString stringWithFormat:@"Bang count: %d", bangcount]];
	[countLabel setBackgroundColor:[UIColor colorWithRed:((float)rand()/ RAND_MAX) 
												  green:((float)rand() / RAND_MAX) 
												   blue:((float)rand() / RAND_MAX)
												  alpha:1.0]];
	if ((float)rand() / RAND_MAX < 0.5)
	{
		[hatSound play];
	}
	else
	{
		[bassSound play];
	}

}

@end
