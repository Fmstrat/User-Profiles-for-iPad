    //
//  AddUserController.m
//  UserProfiles
//
//  Created by Fmstrat on 3/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AddUserController.h"
#import "UserProfilesAppDelegate.h"

@implementation AddUserController

@synthesize userName;
@synthesize addUser;
@synthesize pickButton;


UIAlertView *alert1;
UIActivityIndicatorView *activityIndicator;
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
	addUser.enabled = FALSE;
	addUser.alpha = 0.5f;
	[UIApplication sharedApplication].idleTimerDisabled = NO;
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	alert1 = [[UIAlertView alloc] initWithTitle:@"Please Wait"
													message:@"Please wait while the user copy takes place. Depending on the number of applications installed, this can take a few minutes. Please do NOT exit the application during this process."
													delegate:self
													cancelButtonTitle:nil
													otherButtonTitles:nil];
	[alert1 show];
	[alert1 release];
	[userName resignFirstResponder];
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-18, self.view.frame.size.height/2+150, 36.0f, 36.0f)];
	[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[self.view addSubview:activityIndicator];
	[self.view bringSubviewToFront:activityIndicator];
	[activityIndicator startAnimating];
	
	[self performSelectorInBackground:@selector(copyUser) withObject:nil];
}

-(void) copyUser {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	//char *path = [[[NSBundle mainBundle] bundlePath] UTF8String];
	char *path = "/private/var/mobile/UserProfiles/";
	const char *newUser = [userName.text UTF8String];
	//const char *newUser = "F";
	
	char exec[9000];
	strcpy(exec,"");
	sprintf(exec, "%sfunction dirname2() { local dir=\"${1%%${1##*/}}\"; echo \"$dir\"; };", exec);
	sprintf(exec, "%scd %s;", exec, path);
	sprintf(exec, "%smkdir -p \"Profiles/%s\";", exec, newUser);
	sprintf(exec, "%sif [[ -a ../tmpProfileImage.jpg ]]; then mv ../tmpProfileImage.jpg \"Profiles/%s/icon.jpg\"; fi;", exec, newUser);
	sprintf(exec, "%scp -a ../Library \"Profiles/%s/Library\";", exec, newUser);
	sprintf(exec, "%smkdir Applications.temp;", exec);
	sprintf(exec, "%scd ../Applications;", exec);
	// Move apps
	sprintf(exec, "%sfind . -type d -name \"*.app\" > ../UserProfiles/Profiles/%s/AppList.txt;", exec, newUser);
	sprintf(exec, "%swhile read LINE1; do ", exec);
	sprintf(exec, "%s	DNAME=`dirname2 \"${LINE1}\"`;", exec);
	sprintf(exec, "%s	mkdir -p \"../UserProfiles/Applications.temp/${DNAME}\";", exec);
	sprintf(exec, "%s	mv \"${LINE1}/\" \"../UserProfiles/Applications.temp/${DNAME}\";", exec);
	sprintf(exec, "%sdone < ../UserProfiles/Profiles/%s/AppList.txt;", exec, newUser);	
	// Copy
	sprintf(exec, "%scd ..;", exec);
	sprintf(exec, "%scp -a Applications \"UserProfiles/Profiles/%s/Applications\";", exec, newUser);
	sprintf(exec, "%scd Applications;", exec);
	// Move apps back
	sprintf(exec, "%swhile read LINE1; do ", exec);
	sprintf(exec, "%s	DNAME=`dirname2 \"${LINE1}\"`;", exec);
	sprintf(exec, "%s	mv \"../UserProfiles/Applications.temp/${LINE1}\" \"${DNAME}\";", exec);
	sprintf(exec, "%sdone < ../UserProfiles/Profiles/%s/AppList.txt;", exec, newUser);	
	// Cleanup
	sprintf(exec, "%scd ../UserProfiles;", exec);
	sprintf(exec, "%srm -rf Applications.temp;", exec);
	
//	strcpy(exec,"");
//	sprintf(exec, "%scd %s;", exec, path);
//	sprintf(exec, "%smkdir -p \"Profiles/%s\";", exec, newUser);
//	sprintf(exec, "%sif [[ -a ../tmpProfileImage.jpg ]]; then mv ../tmpProfileImage.jpg \"Profiles/%s/icon.jpg\"; fi;", exec, newUser);
//	sprintf(exec, "%scp -a ../Library \"Profiles/%s/Library\";", exec, newUser);
//	sprintf(exec, "%scp -a ../Applications \"Profiles/%s/Applications\";", exec, newUser);
	
	system(exec);
	
	
	//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello!"
	//													message:[NSString stringWithFormat:@"%s",exec]
	//												   delegate:self
	//										  cancelButtonTitle:@"OK"
	//										  otherButtonTitles:nil];
	//	[alert show];
	//	[alert release];
		
	// No idea why this needs to be here, but it crashes without it.
	//NSArray *viewControllerArray = [self.navigationController viewControllers];
	//	int parentViewControllerIndex = [viewControllerArray count] - 2;
	//	[[viewControllerArray objectAtIndex:parentViewControllerIndex] refreshView];
	
	[self performSelectorOnMainThread:@selector(doneCopyingUser) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

-(void) doneCopyingUser {
	[activityIndicator release];
	[UIApplication sharedApplication].idleTimerDisabled = NO;
	[alert1 dismissWithClickedButtonIndex:0 animated:TRUE];
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
