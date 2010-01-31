//
//  iPdTestMilestone1AppDelegate.m
//  iPdTestMilestone1
//
//  Created by Niv on 10-01-22.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "iPdTestMilestone1AppDelegate.h"

int pd_main();			//cool

@implementation iPdTestMilestone1AppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	//first let's generate the command line message
	const char *path = [[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/"] UTF8String];
	const char *file = [[[[NSBundle mainBundle] bundlePath] 
						 stringByAppendingString:@"/metrobang.pd"] UTF8String];
	printf("Attempting to open %s\n", file);
    const char *argv[] = {path, "-nogui", "-nomidi", "-noaudio", file};
	pd_main(5, argv);			//start up pd lol
    // Override point for customization after application launch
    [window makeKeyAndVisible];
	
	//and again
	
	//adding a comment to test xcode scm settings again...
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
