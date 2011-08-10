//
//  UserProfilesViewController.m
//  UserProfiles
//
//  Created by Fmstrat on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserProfilesViewController.h"
#import "CreateFirstUserController.h"
#import "SelectUserController.h"
#import "AddUserController.h"

@implementation UserProfilesViewController


UIViewController  *currentView;
UIViewController  *nextView;

- (void) displayView:(int)intNewView {
	NSLog(@"%i", intNewView);
	[currentView.view removeFromSuperview];
	[currentView release];
	switch (intNewView) {
		case 1:
			currentView = [[SelectUserController alloc] init];
			break;
		case 2:
			currentView = [[CreateFirstUserController alloc] init];
			break;
		case 3:
			currentView = [[AddUserController alloc] init];
			break;
	}
	
	[self.view addSubview:currentView.view];
}

- (void)viewDidLoad {
	// display Welcome screen
	//system("rm -rf /private/var/mobile/UserProfiles");
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/mobile/UserProfiles"];
	if (fileExists) {
		currentView = [[SelectUserController alloc] init];
	} else {
		currentView = [[CreateFirstUserController alloc] init];
	}
	[self.view addSubview:currentView.view];
	
	[super viewDidLoad];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it	doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc {
	[currentView release];
	[super dealloc];
}

@end
