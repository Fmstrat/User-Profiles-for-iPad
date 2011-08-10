    //
//  CreateFirstUserController.m
//  UserProfiles
//
//  Created by Fmstrat on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CreateFirstUserController.h"
#import "UserProfilesViewController.h"
#import "UserProfilesAppDelegate.h"
//#import "CocoaHelper.h"

//UserProfilesViewController *userProfilesViewController;


@implementation CreateFirstUserController

@synthesize userName;
@synthesize pickButton;

UIPopoverController *pop;

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	UIImage *tmpImage = [image imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
	[pickButton setImage:tmpImage forState:UIControlStateNormal];
	[pickButton setTitle:@"" forState:UIControlStateNormal];
	pickButton.alpha = 1.0;
	pickLabel.alpha = 0;
	[picker dismissModalViewControllerAnimated:NO];
	[pop dismissPopoverAnimated:NO];
	[pop release];
	char *path = "/private/var/mobile/tmpProfileImage.jpg";
	//NSString *newFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"UserImages/user1.jpg"];
	NSString *newFilePath = [NSString stringWithUTF8String:path];
	NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
	if (imageData != nil) {
		[imageData writeToFile:newFilePath atomically:YES];
	}
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Selected"
//													message:[NSString stringWithFormat:@"%s","Your profile icon has been selected."]
//												   delegate:self
//										  cancelButtonTitle:@"OK"
//										  otherButtonTitles:nil];
//	[alert show];
//	[alert release];
}

-(IBAction)pickImage: (id)sender {
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	[imagePicker setDelegate:self];
	pop = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
	[pop setDelegate:self];
	CGRect r = CGRectMake(self.view.frame.size.width/2,self.view.frame.size.height/2+60,3,3);
	//[pop presentPopoverFromRect:self.view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
	[pop presentPopoverFromRect:r inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
	[pop setPopoverContentSize:CGSizeMake(320,400)];
	[imagePicker release];
}


-(IBAction)dismissKeyboard: (id)sender {
	[sender resignFirstResponder];
}

-(IBAction) saveChanges:(id) sender {
	//char *path = [[[NSBundle mainBundle] bundlePath] UTF8String];
	char *path = "/private/var/mobile/UserProfiles/";
	const char *newUser = [userName.text UTF8String];
	//const char *newUser = "F";
	
	char exec[9000];
	strcpy(exec,"");
	sprintf(exec, "%sif [[ ! -a %s ]]; then mkdir -p %s; fi;", exec, path, path);
	sprintf(exec, "%scd %s;", exec, path);
	sprintf(exec, "%smkdir -p \"Profiles/%s\";", exec, newUser);
	sprintf(exec, "%sif [[ ! -a Resources ]]; then mkdir Resources; fi;", exec);
	sprintf(exec, "%secho \"%s\" > Resources/CurrentUser.conf;", exec, newUser);
	sprintf(exec, "%sif [[ -a ../tmpProfileImage.jpg ]]; then mv ../tmpProfileImage.jpg \"Profiles/%s/icon.jpg\"; fi;", exec, newUser);
	sprintf(exec, "%scd ../Applications;", exec);
	sprintf(exec, "%sfind . -type d -name \"*.app\" > ../UserProfiles/Profiles/%s/AppList.txt;", exec, newUser);

//	strcpy(exec,"");
//	sprintf(exec, "%sif [[ ! -a %s ]]; then mkdir -p %s; fi;", exec, path, path);
//	sprintf(exec, "%scd %s;", exec, path);
//	sprintf(exec, "%smkdir -p \"Profiles/%s\";", exec, newUser);
//	sprintf(exec, "%sif [[ ! -a Resources ]]; then mkdir Resources; fi;", exec);
//	sprintf(exec, "%secho \"%s\" > Resources/CurrentUser.conf;", exec, newUser);
//	sprintf(exec, "%sif [[ -a ../tmpProfileImage.jpg ]]; then mv ../tmpProfileImage.jpg \"Profiles/%s/icon.jpg\"; fi;", exec, newUser);
		
	system(exec);

	
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello!"
//													message:[NSString stringWithFormat:@"%s",exec]
//												   delegate:self
//										  cancelButtonTitle:@"OK"
//										  otherButtonTitles:nil];
//	[alert show];
//	[alert release];
	
	[userName resignFirstResponder];
	
	// No idea why this needs to be here, but it crashes without it.
	NSArray *viewControllerArray = [self.navigationController viewControllers];
//	int parentViewControllerIndex = [viewControllerArray count] - 2;
//	[[viewControllerArray objectAtIndex:parentViewControllerIndex] refreshView];
	UserProfilesAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate displayView:1];
	

}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

@implementation UIImage (Extras)

#pragma mark -
#pragma mark Scale and crop image

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
	UIImage *sourceImage = self;
	UIImage *newImage = nil;        
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
	{
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor) 
			scaleFactor = widthFactor; // scale to fit height
        else
			scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if (widthFactor > heightFactor)
		{
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
		}
        else 
			if (widthFactor < heightFactor)
			{
				thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
			}
	}       
	
	UIGraphicsBeginImageContext(targetSize); // this will crop
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	if(newImage == nil) 
        NSLog(@"could not scale image");
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	return newImage;
}

@end
