//
//  AddUserController.h
//  UserProfiles
//
//  Created by Fmstrat on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface AddUserController : UIViewController  <UIPopoverControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	IBOutlet UITextField *userName;
	IBOutlet UIButton *addUser;
	IBOutlet UIButton *pickButton;
	IBOutlet UILabel *pickLabel;
}

@property(nonatomic,retain) IBOutlet UITextField *userName;
@property(nonatomic,retain) IBOutlet UIButton *addUser;
@property(nonatomic,retain) IBOutlet UIButton *pickButton;
@property(nonatomic,retain) IBOutlet UILabel *pickLabel;

-(IBAction) saveChanges:(id) sender;
-(IBAction) pickImage:(id) sender;
- (IBAction)dismissKeyboard: (id)sender;
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo;
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end

