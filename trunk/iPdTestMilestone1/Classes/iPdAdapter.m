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

@synthesize appDelegate;

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


/*03/12/2010
 so far this method causes this to be output:
 print: 135consistency check failed: atom_string
 135consistency check failed: atom_string
 135
 
 
 */
- (void)sendList:(NSString *)pdList toInlet:(int)inlet {
	NSArray *list = [pdList componentsSeparatedByString:@" "];
	char *argv[[list count]];


	//03/04/2010 parse atom list.. most likely move to helper function later
	NSString *atom = [[NSString alloc] init];
	
	for (int i = 0; i < [list count]; i++)
	{
		atom = [list objectAtIndex:i];
			//03/05/2010 could make this more efficient...
		//is there a for-in method with NSScanner?
		//03/12/2010, only floats and symbols available so far
		t_atom *theatom = getbytes(sizeof(t_atom));
		if (isalpha([atom UTF8String][0]) || 
			ispunct([atom UTF8String][0])) //if first char in string is alpha 
		{
			printf("OPTION 1 *********** symbol: %s\n", [atom UTF8String]);
			theatom->a_type = A_SYMBOL;
			theatom->a_w.w_symbol = gensym([atom UTF8String]);
		}
		else
		{
			printf("OPTION 2 )))))))))))) float: %f\n", [atom floatValue]);
			theatom->a_type = A_FLOAT;
			theatom->a_w.w_float = [atom floatValue];
		}
		atom_buffer[i] = theatom;
	}
	
	pd_list(inlet_list[inlet], 
			gensym("list"), 
			[list count], 
			*atom_buffer);
	
	//[atom release];
}

- (void)sendSymbol:(NSString *)sym toInlet:(int)inlet {
	NSLog(@"Sending message: %@", sym);
	const char *symbol = [sym UTF8String];
	pd_symbol(inlet_list[inlet], gensym(symbol));
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

- (void)bangOut{
	[appDelegate.viewController performSelectorOnMainThread:@selector(bang)
												 withObject:nil waitUntilDone:NO];
}

@end
