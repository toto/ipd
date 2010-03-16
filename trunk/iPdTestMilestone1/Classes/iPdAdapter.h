//
//  iPdAdapter.h
//  iPdTestMilestone1
//
//  Created by Niv on 10-01-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#include "m_pd.h"
#include "m_imp.h"
#include "g_canvas.h"
#import "iPdTestMilestone1AppDelegate.h"
#import <Foundation/Foundation.h>

#define MAX_INLETS 10		//02/25/2010 temporary...
#define MAX_OUTLETS 10		//just to get everything working first
#define MAX_ATOMS 20

@interface iPdAdapter : NSObject {
	//we should have an array of atoms that fills when the patch is read
	//paramaters that can be modified by main thread
	
	
	//these should be filled by the same inlet/outlet data modified by pd process
	
	//also, sys_exit should be accessible by this interface
	
	//to test this, we'll just use a float for now
	
	t_canvas *root_canvas;
	t_atom *atom_buffer[MAX_ATOMS];
	void *inlet_list[MAX_INLETS];
	void *outlet_list[MAX_OUTLETS];
	int ninlets;
	int noutlets;
	float param;
	NSThread *pdThread;
	iPdTestMilestone1AppDelegate *appDelegate;
}

@property (nonatomic, assign) iPdTestMilestone1AppDelegate *appDelegate;

+ (iPdAdapter *)sharediPdAdapter;

- (void)registerRootCanvasWithPtr:(void *)ptr;
- (void)registerInlet:(void *)ptr;
- (void)registerOutlet:(void *)ptr;

- (void)sendFloat:(Float32)number toInlet:(int)inlet;
- (void)sendBangToInlet:(int)inlet;
- (void)sendList:(NSString *)pdList toInlet:(int)inlet;
- (void)sendSymbol:(NSString *)sym toInlet:(int)inlet;

@end
