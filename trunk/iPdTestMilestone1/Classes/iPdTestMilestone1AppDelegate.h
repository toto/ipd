//
//  iPdTestMilestone1AppDelegate.h
//  iPdTestMilestone1
//
//  Created by Niv on 10-01-22.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class mainViewController;

@interface iPdTestMilestone1AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	NSMutableSet *inlet_list;
	mainViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet mainViewController *viewController;

@end

