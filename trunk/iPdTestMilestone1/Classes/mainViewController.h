//
//  mainViewController.h
//  iPdTestMilestone1
//
//  Created by Niv on 10-02-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccelerometerFilter.h"

@interface mainViewController : UIViewController <UIAccelerometerDelegate> {
	BOOL trackAxis;
	AccelerometerFilter *filter;
}

@end
