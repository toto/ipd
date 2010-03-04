//
//  mainViewController.m
//  iPdTestMilestone1
//
//  Created by Niv on 10-02-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "mainViewController.h"
#import "iPdAdapter.h"

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
    [super dealloc];
}

//02/14/2010 I need to test the inter-process communication somehow...
#pragma mark Touch Handling				

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView:self.view];
	
	trackAxis = !trackAxis;
	
//	if (location.y > 240)
//	[[iPdAdapter sharediPdAdapter] sendSymbol:@"symbol foo" toInlet:2];
//	else [[iPdAdapter sharediPdAdapter] sendSymbol:@"symbol bar" toInlet:2];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView:self.view];
	
	[[iPdAdapter sharediPdAdapter] sendFloat:location.y toInlet:0];
	
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
		[[iPdAdapter sharediPdAdapter] sendBangToInlet:0];
	}
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	// Update the accelerometer graph view
	if(trackAxis)
	{
		[filter addAcceleration:acceleration];
		[[iPdAdapter sharediPdAdapter] sendFloat:filter.x toInlet:1];
	}
}

@end
