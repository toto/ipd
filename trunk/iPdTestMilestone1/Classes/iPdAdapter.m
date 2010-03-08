//
//  iPdAdapter.m
//  iPdTestMilestone1
//
//  Created by Niv on 10-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


/*
 02/12/2010
 
 iPd "internals" are no longer necessary. It would be easier just to find the pointer
 to the main canvas object's t_inlet and t_outlet lists.
 
 02/14/2010
 
 try this: load objC/runtime.h in m_pd.h
 
 define a single pointer to the iPdAdapter class
 
 send specialized messages to iPdAdapter class from Pd code
 
 */


#import "iPdAdapter.h"


@interface iPdAdapter(private)
//pd thread controlled by this class only
- (void)callPdMain; //selector method
/*
		more functionality will be added here... ability to load/reload patches etc.
*/
@end

int pd_main();

@implementation iPdAdapter

static iPdAdapter *sharediPdAdapterInstance = nil;

+ (iPdAdapter *)sharediPdAdapter
{
    if (sharediPdAdapterInstance == nil) {
        [[self alloc] init];
    }
    return sharediPdAdapterInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		if (sharediPdAdapterInstance == nil) {
			sharediPdAdapterInstance = [super allocWithZone:zone];
			return sharediPdAdapterInstance;
		}
	}
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
	//not sure if thread needs to be released here
}

- (id)autorelease
{
    return self;
}

#pragma mark Threading

- (void)start_pdthread {
	if (pdThread != nil)
	{
		[pdThread cancel];
		//[self waitForPdThreadToFinish];
	}
	//set_ipd_pointer(self);
	pdThread = [[NSThread alloc] initWithTarget:self selector:@selector(callPdMain) object:nil];
	[pdThread start];
}

- (void)testMsg {
	NSLog(@"ADMIRAL ACKBAR!!!");
}

- (void)callPdMain {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[NSThread setThreadPriority:1.0];		//temporary
	BOOL continue_running = YES;
	
	while (continue_running) { //loop until cancelled		//02/13/2010 why is this in a loop?
		//for now we'll just hardcode the patch path
		const char *path = 
		[[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/"] UTF8String];
		const char *file = [[[[NSBundle mainBundle] bundlePath] 
							 stringByAppendingString:@"/inouttest.pd"] UTF8String];
		printf("Attempting to open file: %s\n", file);
		const char *argv[] = {path, "-nogui", "-nomidi", "-noaudio", "-noprefs", file};
		pd_main(6, argv, self);
	}
	
	[pool drain];
}

- (void)stop_pdthread {
		//LOL NOPE
}

#pragma mark Communication
//02/14/2010 this is not working.... going to try a hack today by passing ptr from "cmd line"
- (void)registerRootCanvasWithPtr:(void *)ptr {
	root_canvas = (t_canvas *)ptr;
	NSLog(@"Registered canvas pointer for ipd");
}


#pragma mark Message Passing
/*02/26/2010 TODO: each one of these methods should raise an exception if the requested
 inlet/outlet is out of bounds, OR if Pd is not ready to receive messages yet. (!root_canvas)
 
*/

- (void)sendFloat:(Float32)number toInlet:(int)inlet {
	pd_float(inlet_list[inlet], number);
}

- (void)sendBangToInlet:(int)inlet {
	pd_bang(inlet_list[inlet]);
}

- (void)sendList:(NSString *)pdList toInlet:(int)inlet {
	NSArray *list = [pdList componentsSeparatedByString:@" "];
	int count = [list count];
	char *argv[count -1];


	//03/04/2010 parse atom list.. most likely move to helper function later
	Float32 aFloatAtom;
	const char *aSymbolAtom;
	
	NSScanner *scanner = [NSScanner scannerWithString:pdList];
	for (NSString *item in list)
	{
			//03/05/2010 could make this more efficient...
		//is there a for-in method with NSScanner?
		if (isalpha([item UTF8String][0]) || ispunct([item UTF8String][0])) //if first char in string is alpha 
		{
			//printf("symbol: %s\n", [item UTF8String]);
		}
		else
		{
			//printf("float: %f\n", [item floatValue]);
		}
		
	     
		
	}
	
	
	for (int i = 0; i < count -1; i++)
		argv[i] = [list objectAtIndex:i+1];
	//pd_list(inlet_list[inlet], [list objectAtIndex:0], count-1, argv);
	
}

- (void)sendSymbol:(NSString *)sym toInlet:(int)inlet {
	NSLog(@"Sending message: %@", sym);
	const char *symbol = [sym UTF8String];
	pd_symbol(inlet_list[inlet], symbol);
}

/* 02/24/2010 -been stuck for a while on accessing the "next" pointer of dthe inlet linked 
 list. New plan: collect the inlets and outlets pointer as they are added by Pd.
 The obj_ninlets and obj_noutlets function will help with this problem.  */
//02/14/2010 send a test message --- not msg param for now

/* collect inlet pointers in a list accessible by iPd */

- (void)registerInlet:(void *)ptr {
	inlet_list[ninlets] = ptr;
	ninlets++;
}

- (void)registerOutlet:(void *)ptr {
	outlet_list[noutlets] = ptr;
	noutlets++;
}

@end
