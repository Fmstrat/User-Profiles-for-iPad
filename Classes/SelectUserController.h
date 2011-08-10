//
//  SelectUserController.h
//  UserProfiles
//
//  Created by Fmstrat on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelectUserController : UIViewController {
	NSMutableArray *listData;
	NSString *loggedInUser;
	IBOutlet UIButton *BETAbackupButton;
	IBOutlet UIButton *fixIconButton;
	IBOutlet UIButton *deleteAllButton;
	IBOutlet UIButton *settingsButton;
	IBOutlet UIButton *addButton;
	IBOutlet UIButton *hideSettingsButton;
}

@property(nonatomic, retain) NSMutableArray *listData;
@property(nonatomic, retain) NSString *loggedInUser;
@property(nonatomic,retain) IBOutlet UIButton *BETAbackupButton;
@property(nonatomic,retain) IBOutlet UIButton *deleteAllButton;
@property(nonatomic,retain) IBOutlet UIButton *fixIconButton;
@property(nonatomic,retain) IBOutlet UIButton *settingsButton;
@property(nonatomic,retain) IBOutlet UIButton *addButton;
@property(nonatomic,retain) IBOutlet UIButton *hideSettingsButton;

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (IBAction)BETAbackup:(id)selector;
- (IBAction)showSettings:(id)selector;
- (IBAction)fixIcons:(id)selector;
- (IBAction)deleteAllUsers:(id)selector;
- (IBAction)hideSettings:(id)selector;
- (void)confirmDeleteUser;
-(void) runDeleteAllUsers;
- (IBAction)addUser:(id)selector;

@end

