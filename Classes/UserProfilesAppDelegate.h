//
//  UserProfilesAppDelegate.h
//  UserProfiles
//
//  Created by Fmstrat on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class UserProfilesViewController;

@interface UserProfilesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UserProfilesViewController *viewController;
}

- (void) displayView:(int)intNewView;


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UserProfilesViewController *viewController;


@end

