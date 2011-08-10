//
//  SelectUserController.m
//  UserProfiles
//
//  Created by Fmstrat on 2/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectUserController.h"
#import "CreateFirstUserController.h"
#import "UserProfilesAppDelegate.h"
#import "AddUserController.h"

#define RB_HALT		0x08	/* don't reboot, just halt */

@implementation SelectUserController

@synthesize listData;
@synthesize loggedInUser;
@synthesize deleteAllButton;
@synthesize fixIconButton;
@synthesize settingsButton;
@synthesize addButton;

char newUser[256];
char curUser[256];
UIButton *user0;
UIButton *user1;
UIButton *user2;
UIButton *user3;
UIButton *user4;
UIButton *user5;
UIImage *user0Icon;
UIImage *user1Icon;
UIImage *user2Icon;
UIImage *user3Icon;
UIImage *user4Icon;
UIImage *user5Icon;
NSMutableArray *array;
BOOL inSettings;
char tmpDeleteUser[256];
int userCount;
UIAlertView *constAlert;
UIActivityIndicatorView *constActivityIndicator;
UIButton *constDeleteButton;


CreateFirstUserController *createFirstUserController;

- (void) createFirstUser {
	UserProfilesAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate displayView:2];
}



-(IBAction) selectUser:(id) sender {
	
	UIButton *button = (UIButton *)sender;
    int row = button.tag;
	NSString *title = button.currentTitle;

	title = [title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	title = [title stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	const char *newUserTmp = [title UTF8String];
	self.loggedInUser = [loggedInUser stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	self.loggedInUser = [loggedInUser stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	const char *curUserTmp = [loggedInUser UTF8String];
	strcpy(curUser, curUserTmp);
	strcpy(newUser, newUserTmp);
	
	if (inSettings) {
		if ([loggedInUser compare:title] == 0) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry"
															message:@"We're sorry, but you cannot delete the curently logged in user."
														   delegate:self
												  cancelButtonTitle:@"Go Back"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		} else {
			// Delete the user
			strcpy(tmpDeleteUser, newUserTmp);
			constDeleteButton = button;
			[self confirmDeleteUser];
		}
	} else {
		if ([loggedInUser compare:title] == 0) {
			[[NSThread mainThread] exit];
		} else {			
			// Switch to the user
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Switching User"
															message:@"Please wait while we switch users.\n\nIf you have installed, updated or removed Apps, this may take a few minutes."
														   delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-18, self.view.frame.size.height/2+150, 36.0f, 36.0f)];
			[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
			[self.view addSubview:activityIndicator];
			[self.view bringSubviewToFront:activityIndicator];
			[activityIndicator startAnimating];
			[self performSelectorInBackground:@selector(swapUser) withObject:nil];
		}
	}
}

-(void) deleteUser {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	[UIApplication sharedApplication].idleTimerDisabled = NO;
	[UIApplication sharedApplication].idleTimerDisabled = YES;

	//char *path = [[[NSBundle mainBundle] bundlePath] UTF8String];
	char *path = "/private/var/mobile/UserProfiles/";
	
	char exec[9000];
	strcpy(exec,"");
	sprintf(exec, "%srm -rf %sProfiles/%s;", exec, path, tmpDeleteUser);
	system(exec);
	
	[self performSelectorOnMainThread:@selector(doneDeleteUser) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

-(void) doneDeleteUser {
	[constActivityIndicator release];
	[constAlert dismissWithClickedButtonIndex:0 animated:TRUE];
	[UIApplication sharedApplication].idleTimerDisabled = NO;
	[[NSThread mainThread] exit];
}


-(void) swapUser {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	char *path = "/private/var/mobile/UserProfiles/";
	
	char exec[9000];
	strcpy(exec,"");
	// Check for updated apps and newly installed apps
	sprintf(exec, "%sfunction basename2() { local name=\"${1##*/}\"; echo \"${name%%$2}\"; };", exec);
	//sprintf(exec, "%sfunction dirname2() { local dir=\"${1%%${1##*/}}\"; \"${dir:=./}\" != \"/\" && dir=\"${dir%%?}\"; echo \"$dir\"; };", exec);
	sprintf(exec, "%sfunction dirname2() { local dir=\"${1%%${1##*/}}\"; echo \"$dir\"; };", exec);
	sprintf(exec, "%scd %s;", exec, path);
	sprintf(exec, "%scd ../Applications;", exec);
	sprintf(exec, "%sfind . -type d -name \"*.app\" > \"../UserProfiles/Profiles/%s/AppList.txt\";", exec, curUser);
	sprintf(exec, "%scd %s/Resources;", exec, path);
	sprintf(exec, "%sREFRESHLIST=\"\";", exec);
	sprintf(exec, "%sCLEARCACHE=\"\";", exec);
	// Start looping
	//sprintf(exec, "%sif [[ -n `diff \"../Profiles/%s/AppList.txt\" \"../Profiles/%s/AppList.txt\"` ]]; then ", exec, curUser, newUser);
	sprintf(exec, "%swhile read LINE1; do ", exec);
	sprintf(exec, "%s	FND=\"\";", exec);
	sprintf(exec, "%s	B1=`basename2 \"$LINE1\"`;", exec);
	sprintf(exec, "%s	while read LINE2; do ", exec);
	sprintf(exec, "%s		B2=`basename2 \"$LINE2\"`;", exec);
	sprintf(exec, "%s		if [ \"${B1}\" = \"${B2}\" ]; then ", exec);
	sprintf(exec, "%s			FND=\"Found\";", exec);
	sprintf(exec, "%s			DNAME=`dirname2 \"${LINE2}\"`;", exec);
	sprintf(exec, "%s			mv \"../../Applications/${LINE1}\" \"../Profiles/%s/Applications/${DNAME}\";", exec, newUser);		
	sprintf(exec, "%s		fi;", exec);
	sprintf(exec, "%s	done < \"../Profiles/%s/AppList.txt\";", exec, newUser);
	sprintf(exec, "%s	if [ -z \"${FND}\" ]; then ", exec);
	sprintf(exec, "%s		REFRESHLIST=\"1\";", exec);
	sprintf(exec, "%s		CLEARCACHE=\"1\";", exec);
	sprintf(exec, "%s		D1=`dirname2 \"$LINE1\"`;", exec);
	sprintf(exec, "%s		mkdir -p \"../Applications.temp/${D1}\";", exec);
	sprintf(exec, "%s		mv \"../../Applications/${LINE1}\" \"../Applications.temp/${D1}\";", exec);
	sprintf(exec, "%s		cp -a \"../../Applications/${D1}\" \"../Profiles/%s/Applications/${D1}\";", exec, newUser);
	//sprintf(exec, "%s		mv \"../Applications.temp/{$LINE1}\" \"../../Applications/${D1}\";", exec);
	sprintf(exec, "%s		mv \"../Applications.temp/${LINE1}\" \"../Profiles/%s/Applications/${D1}\";", exec);
	sprintf(exec, "%s		rm -rf ../Applications.temp;", exec);
	sprintf(exec, "%s	fi;", exec);
	sprintf(exec, "%sdone < \"../Profiles/%s/AppList.txt\";", exec, curUser);
	// Check to see if an app has been removed
	sprintf(exec, "%swhile read LINE1; do ", exec);
	sprintf(exec, "%s	FND=\"\";", exec);
	sprintf(exec, "%s	B1=`basename2 \"$LINE1\"`;", exec);
	sprintf(exec, "%s	while read LINE2; do ", exec);
	sprintf(exec, "%s		B2=`basename2 \"$LINE2\"`;", exec);
	sprintf(exec, "%s		if [ \"${B1}\" = \"${B2}\" ]; then ", exec);
	sprintf(exec, "%s			FND=\"Found\";", exec);
	sprintf(exec, "%s		fi;", exec);
	sprintf(exec, "%s	done < \"../Profiles/%s/AppList.txt\";", exec, curUser);
	sprintf(exec, "%s	if [ -z \"${FND}\" ]; then ", exec);
	sprintf(exec, "%s		REFRESHLIST=\"1\";", exec);
	sprintf(exec, "%s		D1=`dirname2 \"$LINE1\"`;", exec);
	sprintf(exec, "%s		echo rm -rf \"../Profiles/%s/Applications/${D1}\" >> tmp.txt;", exec, newUser);
	sprintf(exec, "%s		rm -rf \"../Profiles/%s/Applications/${D1}\";", exec, newUser);
	sprintf(exec, "%s	fi;", exec);
	sprintf(exec, "%sdone < \"../Profiles/%s/AppList.txt\";", exec, newUser);
	//sprintf(exec, "%sfi;", exec);
//	// Move the apps to the new user
//	sprintf(exec, "%scd %s;", exec, path);
//	sprintf(exec, "%scd ../Applications;", exec);
//	sprintf(exec, "%swhile read LINE1; do ", exec);
//	sprintf(exec, "%s	B1=`basename2 \"$LINE1\"`;", exec);
//	sprintf(exec, "%s	while read LINE2; do ", exec);
//	sprintf(exec, "%s		B2=`basename2 \"$LINE2\"`;", exec);
//	sprintf(exec, "%s		if [ \"${B1}\" = \"${B2}\" ]; then ", exec);
//	sprintf(exec, "%s			DNAME=`dirname2 \"${LINE2}\"`;", exec);
//	sprintf(exec, "%s			mv \"${LINE1}\" \"../UserProfiles/Profiles/%s/Applications/${DNAME}\";", exec, newUser);		
//	sprintf(exec, "%s		fi;", exec);
//	sprintf(exec, "%s	done < \"../UserProfiles/Profiles/%s/AppList.txt\";", exec, newUser);
//	sprintf(exec, "%sdone < \"../UserProfiles/Profiles/%s/AppList.txt\";", exec, curUser);
	// Move current user apps
	sprintf(exec, "%scd %s;", exec, path);
	sprintf(exec, "%scd ..;", exec);
	sprintf(exec, "%smv Applications \"UserProfiles/Profiles/%s/Applications\";", exec, curUser);
	sprintf(exec, "%smv Library \"UserProfiles/Profiles/%s/Library\";", exec, curUser);
	// Move new users data
	sprintf(exec, "%smv \"UserProfiles/Profiles/%s/Applications\" Applications;", exec, newUser);
	sprintf(exec, "%smv \"UserProfiles/Profiles/%s/Library\" Library;", exec, newUser);	
	//sprintf(exec, "%srm -rf \"Library/Caches/com.apple.IconsCache/\";", exec);		
	// Update new users app list
	sprintf(exec, "%scd Applications;", exec);
	sprintf(exec, "%sif [ -n \"${REFRESHLIST}\" ]; then ", exec);
	sprintf(exec, "%s	find . -type d -name \"*.app\" > \"../UserProfiles/Profiles/%s/AppList.txt\";", exec, newUser);
	sprintf(exec, "%sfi;", exec);
	sprintf(exec, "%sif [ -n \"${CLEARCACHE}\" ]; then ", exec);
	sprintf(exec, "%s	rm -rf \"../Library/Caches/\";", exec);			
	sprintf(exec, "%sfi;", exec);
	sprintf(exec, "%secho \"%s\" > ../UserProfiles/Resources/CurrentUser.conf;", exec, newUser);
	// Respring
	//sprintf(exec, "%skillall SpringBoard;", exec);



//	strcpy(exec,"");
//	sprintf(exec, "%scd %s;", exec, path);
//	sprintf(exec, "%scd ..;", exec);
//	sprintf(exec, "%smv Applications \"UserProfiles/Profiles/%s/\";", exec, curUser);
//	sprintf(exec, "%smv Library \"UserProfiles/Profiles/%s/\";", exec, curUser);
//	// Move new users data
//	sprintf(exec, "%smv \"UserProfiles/Profiles/%s/Applications\" Applications;", exec, newUser);
//	sprintf(exec, "%smv \"UserProfiles/Profiles/%s/Library\" Library;", exec, newUser);	
//	sprintf(exec, "%srm -rf \"Library/Caches/com.apple.IconsCache/\";", exec);		
//	sprintf(exec, "%secho \"%s\" > UserProfiles/Resources/CurrentUser.conf;", exec, newUser);
//	sprintf(exec, "%ssleep 1;", exec);
	
	
	
	system(exec);	
	[self performSelectorOnMainThread:@selector(doneSwitchingUser) withObject:nil waitUntilDone:NO];
	
	[pool release];

}

-(void) doneSwitchingUser {
//	reboot(0);
	char exec[9000];
	strcpy(exec,"killall SpringBoard;");
	system(exec);
}

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	inSettings = FALSE;
	array = [NSMutableArray arrayWithCapacity:6];
	//char *path = [[[NSBundle mainBundle] bundlePath] UTF8String];
	char *path = "/private/var/mobile/UserProfiles/";
	
	char exec[9000];
	strcpy(exec,"");
	//sprintf(exec, "%sif [[ -a %s ]]; then rm -rf %s; fi;", exec, path, path);
	sprintf(exec, "%sif [[ ! -a %s ]]; then mkdir -p %s; fi;", exec, path, path);
	sprintf(exec, "%scd %s;", exec, path);
	sprintf(exec, "%sif [[ ! -a Profiles ]]; then mkdir Profiles; else cd Profiles; ls; fi;", exec);
//	UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"Hello!"
//													 message:[NSString stringWithFormat:@"D: %s",exec]
//													delegate:self
//											   cancelButtonTitle:@"OK"
//												   otherButtonTitles:nil];
//	[alert1 show];
//	[alert1 release];
	char line[256];
	FILE *ptr, *popen();
	if((ptr = popen(exec, "r")) == NULL)
		perror("Couldn't open pipe");
	while (1)
	{
		if(fgets(line, 256, ptr) == NULL)
			break;
		//		UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"Hello!"
		//														 message:[NSString stringWithFormat:@"D: %s",line]
		//														delegate:self
		//											   cancelButtonTitle:@"OK"
		//											   otherButtonTitles:nil];
		//		[alert1 show];
		//		[alert1 release];
		[array addObject:[NSString stringWithFormat:@"%s", line]];
	}
	//if ([array count] == 0)
	//	[array addObject:[NSString stringWithFormat:@"%s", "[NOUSER]"]];
	//	fclose(ptr);
	
	char currentUserChar[256];	
	strcpy(exec,"");
	sprintf(exec, "%scd %s;", exec, path);
	sprintf(exec, "%sif [[ ! -a Resources ]]; then mkdir Resources; fi;", exec);
	sprintf(exec, "%scd Resources;", exec);
	sprintf(exec, "%sif [[ ! -a CurrentUser.conf ]]; then echo '[NOUSER]' > CurrentUser.conf; echo '[NOUSER]'; else cat CurrentUser.conf; fi;", exec);
	strcpy(currentUserChar, "");
	if((ptr = popen(exec, "r")) == NULL)
		perror("Couldn't open pipe");
	while (1)
	{
		if(fgets(currentUserChar, 256, ptr) == NULL)
			break;
	}
	fclose(ptr);
	
	NSString *currentUser = [NSString stringWithUTF8String:currentUserChar];
	//[array addObject:[NSString stringWithFormat:@"%s", "Fmstrat"]];
	//[array addObject:[NSString stringWithFormat:@"%s", "CiNoRi"]];
	//	[array addObject:[NSString stringWithFormat:@"%s", "Fmstrat2"]];
	//	[array addObject:[NSString stringWithFormat:@"%s", "CiNoRi2"]];
	//	[array addObject:[NSString stringWithFormat:@"%s", "Fmstrat3"]];
	//	[array addObject:[NSString stringWithFormat:@"%s", "CiNoRi3"]];
	
	self.listData = array;
	self.loggedInUser = currentUser;
	userCount = [array count];
    [super viewDidLoad];
	
	
	if ([array count] > 0) {
		
		float hmiddle = 0;
		float vmiddle = 0;
		if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			hmiddle = 384;
			vmiddle = 512;
		} else {
			hmiddle = 512;
			vmiddle = 384;
		}
		
		int i = 0;
		for (NSString *label in array) {
			
			UIButton *userButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
			
			//NSString *label = [array objectAtIndex:0];
			[userButton setTitle:label forState:UIControlStateNormal];
			//[userButton setTitle:@"" forState:UIControlStateHighlighted];
			//[userButton setTitle:@"" forState:UIControlStateSelected];
			userButton.titleLabel.font = [UIFont fontWithName:@"Arial" size:24.0];
			//userButton.backgroundColor = [UIColor clearColor];	
			//[userButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
			
			if ([array count] == 1) {
				userButton.frame = CGRectMake(hmiddle-90, vmiddle-200, 179.0, 180.0);
			}
			if ([array count] == 2) {
				if (i == 0)
					userButton.frame = CGRectMake(hmiddle-50-179, vmiddle-200, 179.0, 180.0);
				if (i == 1)
					userButton.frame = CGRectMake(hmiddle+50, vmiddle-200, 179.0, 180.0);
			}
			if ([array count] == 3 || [array count] == 4) {
				if (i == 0)
					userButton.frame = CGRectMake(hmiddle-50-179, vmiddle-300, 179.0, 180.0);
				if (i == 1)
					userButton.frame = CGRectMake(hmiddle+50, vmiddle-300, 179.0, 180.0);
				if (i == 2)
					userButton.frame = CGRectMake(hmiddle-50-179, vmiddle, 179.0, 180.0);
				if (i == 3)
					userButton.frame = CGRectMake(hmiddle+50, vmiddle, 179.0, 180.0);
			}
			if ([array count] == 5 || [array count] == 6) {
				if (i == 0)
					userButton.frame = CGRectMake(hmiddle-50-179, vmiddle-500, 179.0, 180.0);
				if (i == 1)
					userButton.frame = CGRectMake(hmiddle+50, vmiddle-500, 179.0, 180.0);
				if (i == 2)
					userButton.frame = CGRectMake(hmiddle-50-179, vmiddle-200, 179.0, 180.0);
				if (i == 3)
					userButton.frame = CGRectMake(hmiddle+50, vmiddle-200, 179.0, 180.0);
				if (i == 4)
					userButton.frame = CGRectMake(hmiddle-50-179, vmiddle+100, 179.0, 180.0);
				if (i == 5)
					userButton.frame = CGRectMake(hmiddle+50, vmiddle+100, 179.0, 180.0);
			}
			
			
			NSString *image = [NSString stringWithFormat:@"%s", "buttonNotSelected.png"];;
			if ([label compare:currentUser] == 0) {
				image = [NSString stringWithFormat:@"%s", "buttonSelected.png"];
			}
			
			UIImage *buttonImageNormal = [UIImage imageNamed:image];
			UIImage *strechableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
			[userButton setBackgroundImage:strechableButtonImageNormal forState:UIControlStateNormal];
			
			UIImage *buttonImagePressed = [UIImage imageNamed:@"buttonSelected.png"];
			UIImage *strechableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
			[userButton setBackgroundImage:strechableButtonImagePressed forState:UIControlStateHighlighted];
			
			label = [label stringByReplacingOccurrencesOfString:@"\n" withString:@""];
			label = [label stringByReplacingOccurrencesOfString:@"\r" withString:@""];
			const char *user = [label UTF8String];
			
			[userButton setTitleEdgeInsets:UIEdgeInsetsMake(175, -strechableButtonImageNormal.size.width-10, 0, -strechableButtonImageNormal.size.width/2)];
			[userButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -userButton.titleLabel.bounds.size.width)];
			
			[userButton setTag:i];
			[userButton addTarget:self action:@selector(selectUser:) forControlEvents:UIControlEventTouchUpInside];
			//[userButton setTitleShadowColor:[UIColor blueColor] forState:UIControlStateNormal];
			//[userButton.titleLabel setShadowOffset:CGSizeMake(0.0f, 0.0f)];
			//userButton.titleLabel.center = CGPointMake(89, 180);
			
			char path[1000];
			sprintf(path,"/private/var/mobile/UserProfiles/Profiles/%s/icon.jpg",user);
			NSString *iconFilePath = [NSString stringWithUTF8String:path];
			BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:iconFilePath];
			
			
			
			switch (i) {
				case 0:
					if (fileExists) {
						UIImage *customImage = [UIImage imageWithContentsOfFile:iconFilePath];
						user0Icon = [customImage imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
					} else {
						user0Icon = [UIImage imageNamed:@"icon.jpg"];
					}
					[userButton setImage:user0Icon forState:UIControlStateNormal];		
					user0 = userButton;
					[self.view addSubview:user0];  
					break;
				case 1:
					if (fileExists) {
						UIImage *customImage = [UIImage imageWithContentsOfFile:iconFilePath];
						user1Icon = [customImage imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
					} else {
						user1Icon = [UIImage imageNamed:@"icon.jpg"];
					}
					[userButton setImage:user1Icon forState:UIControlStateNormal];		
					user1 = userButton;
					[self.view addSubview:user1];  
					break;
				case 2:
					if (fileExists) {
						UIImage *customImage = [UIImage imageWithContentsOfFile:iconFilePath];
						user2Icon = [customImage imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
					} else {
						user2Icon = [UIImage imageNamed:@"icon.jpg"];
					}
					[userButton setImage:user2Icon forState:UIControlStateNormal];		
					user2 = userButton;
					[self.view addSubview:user2];  
					break;
				case 3:
					if (fileExists) {
						UIImage *customImage = [UIImage imageWithContentsOfFile:iconFilePath];
						user3Icon = [customImage imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
					} else {
						user3Icon = [UIImage imageNamed:@"icon.jpg"];
					}
					[userButton setImage:user3Icon forState:UIControlStateNormal];		
					user3 = userButton;
					[self.view addSubview:user3];  
					break;
				case 4:
					if (fileExists) {
						UIImage *customImage = [UIImage imageWithContentsOfFile:iconFilePath];
						user4Icon = [customImage imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
					} else {
						user4Icon = [UIImage imageNamed:@"icon.jpg"];
					}
					[userButton setImage:user4Icon forState:UIControlStateNormal];		
					user4 = userButton;
					[self.view addSubview:user4];  
					break;
				case 5:
					if (fileExists) {
						UIImage *customImage = [UIImage imageWithContentsOfFile:iconFilePath];
						user5Icon = [customImage imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
					} else {
						user5Icon = [UIImage imageNamed:@"icon.jpg"];
					}
					[userButton setImage:user5Icon forState:UIControlStateNormal];		
					user5 = userButton;
					[self.view addSubview:user5];  
					break;
			}
			i++;
		}
	}
	
	[array release];
	
//	UserProfilesAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//	[appDelegate displayView:2];
	

}

- (IBAction)addUser:(id)selector {
	UserProfilesAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate displayView:3];
}

- (IBAction)showSettings:(id)selector {
	fixIconButton.alpha = 1;
	fixIconButton.enabled = TRUE;
	deleteAllButton.alpha = 1;
	deleteAllButton.enabled = TRUE;
	
	if (userCount < 6) {
		addButton.alpha = 1;
		addButton.enabled = TRUE;
	} else {
		addButton.alpha = 0.5;
	}
	
	
	inSettings = TRUE;
	hideSettingsButton.alpha = 1;
	hideSettingsButton.enabled = TRUE;
	settingsButton.alpha = 0;
	settingsButton.enabled = FALSE;
	UIImage *defaultImage = [UIImage imageNamed:@"deleteUser.png"];
	[user0 setImage:defaultImage forState:UIControlStateNormal];
	[user1 setImage:defaultImage forState:UIControlStateNormal];
	[user2 setImage:defaultImage forState:UIControlStateNormal];
	[user3 setImage:defaultImage forState:UIControlStateNormal];
	[user4 setImage:defaultImage forState:UIControlStateNormal];
	[user5 setImage:defaultImage forState:UIControlStateNormal];
}

- (IBAction)hideSettings:(id)selector {
	inSettings = FALSE;
	fixIconButton.alpha = 0;
	fixIconButton.enabled = FALSE;
	deleteAllButton.alpha = 0;
	deleteAllButton.enabled = FALSE;
	addButton.alpha = 0;
	addButton.enabled = FALSE;
	inSettings = FALSE;
	hideSettingsButton.alpha = 0;
	hideSettingsButton.enabled = FALSE;
	settingsButton.alpha = 0.3f;
	settingsButton.enabled = TRUE;
	
	NSString *label;
	UIImage *tmpImage;
	const char *user;
	char path[1000];
	NSString *iconFilePath;
	BOOL fileExists = FALSE;
	
	label = user0.titleLabel.text;
	label = [label stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	label = [label stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	user = [label UTF8String];
	sprintf(path,"/private/var/mobile/UserProfiles/Profiles/%s/icon.jpg",user);
	iconFilePath = [NSString stringWithUTF8String:path];
	fileExists = [[NSFileManager defaultManager] fileExistsAtPath:iconFilePath];
	if (fileExists) {
		tmpImage = [UIImage imageWithContentsOfFile:iconFilePath];
		tmpImage = [tmpImage imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
	} else {
		tmpImage = [UIImage imageNamed:@"icon.jpg"];
	}
	[user0 setImage:tmpImage forState:UIControlStateNormal];
	
	label = user1.titleLabel.text;
	label = [label stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	label = [label stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	user = [label UTF8String];
	sprintf(path,"/private/var/mobile/UserProfiles/Profiles/%s/icon.jpg",user);
	iconFilePath = [NSString stringWithUTF8String:path];
	fileExists = [[NSFileManager defaultManager] fileExistsAtPath:iconFilePath];
	if (fileExists) {
		tmpImage = [UIImage imageWithContentsOfFile:iconFilePath];
		tmpImage = [tmpImage imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
	} else {
		tmpImage = [UIImage imageNamed:@"icon.jpg"];
	}
	[user1 setImage:tmpImage forState:UIControlStateNormal];
	
	label = user2.titleLabel.text;
	label = [label stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	label = [label stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	user = [label UTF8String];
	sprintf(path,"/private/var/mobile/UserProfiles/Profiles/%s/icon.jpg",user);
	iconFilePath = [NSString stringWithUTF8String:path];
	fileExists = [[NSFileManager defaultManager] fileExistsAtPath:iconFilePath];
	if (fileExists) {
		tmpImage = [UIImage imageWithContentsOfFile:iconFilePath];
		tmpImage = [tmpImage imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
	} else {
		tmpImage = [UIImage imageNamed:@"icon.jpg"];
	}
	[user2 setImage:tmpImage forState:UIControlStateNormal];
	
	label = user3.titleLabel.text;
	label = [label stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	label = [label stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	user = [label UTF8String];
	sprintf(path,"/private/var/mobile/UserProfiles/Profiles/%s/icon.jpg",user);
	iconFilePath = [NSString stringWithUTF8String:path];
	fileExists = [[NSFileManager defaultManager] fileExistsAtPath:iconFilePath];
	if (fileExists) {
		tmpImage = [UIImage imageWithContentsOfFile:iconFilePath];
		tmpImage = [tmpImage imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
	} else {
		tmpImage = [UIImage imageNamed:@"icon.jpg"];
	}
	[user3 setImage:tmpImage forState:UIControlStateNormal];
	
	label = user4.titleLabel.text;
	label = [label stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	label = [label stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	user = [label UTF8String];
	sprintf(path,"/private/var/mobile/UserProfiles/Profiles/%s/icon.jpg",user);
	iconFilePath = [NSString stringWithUTF8String:path];
	fileExists = [[NSFileManager defaultManager] fileExistsAtPath:iconFilePath];
	if (fileExists) {
		tmpImage = [UIImage imageWithContentsOfFile:iconFilePath];
		tmpImage = [tmpImage imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
	} else {
		tmpImage = [UIImage imageNamed:@"icon.jpg"];
	}
	[user4 setImage:tmpImage forState:UIControlStateNormal];
	
	label = user5.titleLabel.text;
	label = [label stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	label = [label stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	user = [label UTF8String];
	sprintf(path,"/private/var/mobile/UserProfiles/Profiles/%s/icon.jpg",user);
	iconFilePath = [NSString stringWithUTF8String:path];
	fileExists = [[NSFileManager defaultManager] fileExistsAtPath:iconFilePath];
	if (fileExists) {
		tmpImage = [UIImage imageWithContentsOfFile:iconFilePath];
		tmpImage = [tmpImage imageByScalingAndCroppingForSize:CGSizeMake(103,103)];
	} else {
		tmpImage = [UIImage imageNamed:@"icon.jpg"];
	}
	[user5 setImage:tmpImage forState:UIControlStateNormal];

}



- (void)confirmDeleteUser {
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Confirm Delete"];
	[alert setMessage:@"This will delete the selected user, and then exit the application."];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
	[alert release];
}

- (IBAction)deleteAllUsers:(id)selector {
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Confirm Deletion"];
	[alert setMessage:@"This will delete all users except the one logged in, and then exit the application."];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
	[alert release];
}

- (IBAction)BETAbackup:(id)selector {
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"BACKUP ALL"];
	[alert setMessage:@"This will back up all applications and settings in case something goes wrong."];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
	[alert release];
}


- (IBAction)fixIcons:(id)selector {
	UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:@"Fix Icons"];
	[alert setMessage:@"If you ran into an issue of white or missing icons after installing, updating, or removing an application, press Yes below. This will refresh the Cache and shutdown the iPad. You will need to restart it afterwards.\n\n [=- IMPORTANT -=]: The iPad is fickle in updating Cache. Often you must do this multiple times before the icons are restored, and on rare occasions you will lose icon placement, and have to re-organize them."];
	[alert setDelegate:self];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSString *tmpTitle  = [NSString stringWithUTF8String:"Confirm Deletion"];
	if ([alertView.title compare:tmpTitle] == 0) {
		if (buttonIndex == 0)
		{
			// Yes, do something
			[self runDeleteAllUsers];
		}
		else if (buttonIndex == 1)
		{
			// No
			//[alertView dismissWithClickedButtonIndex:2 animated:TRUE];
		}
	}
	
	tmpTitle  = [NSString stringWithUTF8String:"Confirm Delete"];
	if ([alertView.title compare:tmpTitle] == 0) {
		if (buttonIndex == 0)
		{
			// Yes, do something
			[self runDeleteSingleUser];
		}
		else if (buttonIndex == 1)
		{
			// No
			//[alertView dismissWithClickedButtonIndex:2 animated:TRUE];
		}
	}	
	
	tmpTitle  = [NSString stringWithUTF8String:"Fix Icons"];
	if ([alertView.title compare:tmpTitle] == 0) {
		if (buttonIndex == 0)
		{
			// Yes, do something
			[self runFixIcons];
		}
		else if (buttonIndex == 1)
		{
			// No
			//[alertView dismissWithClickedButtonIndex:2 animated:TRUE];
		}
	}	
	
	tmpTitle  = [NSString stringWithUTF8String:"BACKUP ALL"];
	if ([alertView.title compare:tmpTitle] == 0) {
		if (buttonIndex == 0)
		{
			// Yes, do something
			[self runBackup];
		}
		else if (buttonIndex == 1)
		{
			// No
			//[alertView dismissWithClickedButtonIndex:2 animated:TRUE];
		}
	}	
	
}

-(void) disableButtons {
	user0.enabled = FALSE;
	user0.alpha = 0.5f;
	user1.enabled = FALSE;
	user1.alpha = 0.5f;
	user2.enabled = FALSE;
	user2.alpha = 0.5f;
	user3.enabled = FALSE;
	user3.alpha = 0.5f;
	user4.enabled = FALSE;
	user4.alpha = 0.5f;
	user5.enabled = FALSE;
	user5.alpha = 0.5f;
	fixIconButton.enabled = FALSE;
	fixIconButton.alpha = 0.5f;
	deleteAllButton.enabled = FALSE;
	deleteAllButton.alpha = 0.5f;
	settingsButton.enabled = FALSE;
	settingsButton.alpha = 0.5f;
	addButton.enabled = FALSE;
	addButton.alpha = 0.5f;
	hideSettingsButton.enabled = FALSE;
	hideSettingsButton.alpha = 0.5f;
}	

-(void) runBackup {
	[UIApplication sharedApplication].idleTimerDisabled = NO;
	[UIApplication sharedApplication].idleTimerDisabled = YES;

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Backing Up"
													message:@"Please wait while we back up. The application will quit when this is complete."
												   delegate:self
										  cancelButtonTitle:nil
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-18, self.view.frame.size.height/2+150, 36.0f, 36.0f)];
	[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[self.view addSubview:activityIndicator];
	[self.view bringSubviewToFront:activityIndicator];
	[activityIndicator startAnimating];
	[self performSelectorInBackground:@selector(doBackup) withObject:nil];
}


-(void) doBackup {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	char *path = "/private/var/mobile/UserProfiles/";
	char exec[9000];
	strcpy(exec,"");
	sprintf(exec, "%scd %s/..;", exec, path);
	sprintf(exec, "%sif [[ -a UserProfilesBackup ]]; then rm -rf UserProfilesBackup; fi;", exec);
	sprintf(exec, "%smkdir -p UserProfilesBackup;", exec);
	sprintf(exec, "%scp -a Library UserProfilesBackup;", exec);
	sprintf(exec, "%scp -a Applications UserProfilesBackup;", exec);
	system(exec);
	[self performSelectorOnMainThread:@selector(doneWithBackup) withObject:nil waitUntilDone:NO];
	[pool release];
}

-(void) doneWithBackup {
	[UIApplication sharedApplication].idleTimerDisabled = NO;
	[[NSThread mainThread] exit];	
}


-(void) runFixIcons {
	[self disableButtons];
	char *path = "/private/var/mobile/UserProfiles/";
	char exec[9000];
	strcpy(exec,"");
	sprintf(exec, "%scd %s;", exec, path);	
	sprintf(exec, "%scd ..;", exec);	
	sprintf(exec, "%srm -rf Library/Caches/;touch Applications/*; sleep 5;", exec);
	system(exec);
	reboot(RB_HALT);
}

-(void) runDeleteSingleUser {
	[self disableButtons];
	constAlert = [[UIAlertView alloc] initWithTitle:@"Deleting User"
											message:@"Please wait while we delete the user. The application will exit when this is complete."
										   delegate:self
								  cancelButtonTitle:nil
								  otherButtonTitles:nil];
	[constAlert show];
	[constAlert release];
	constActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-18, self.view.frame.size.height/2+150, 36.0f, 36.0f)];
	[constActivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[self.view addSubview:constActivityIndicator];
	[self.view bringSubviewToFront:constActivityIndicator];
	[constActivityIndicator startAnimating];
	[constDeleteButton removeFromSuperview];
	[self performSelectorInBackground:@selector(deleteUser) withObject:nil];
}

-(void) runDeleteAllUsers {
	[self disableButtons];
	[UIApplication sharedApplication].idleTimerDisabled = NO;
	[UIApplication sharedApplication].idleTimerDisabled = YES;
	UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"Please Wait"
										message:@"Please wait while the removal takes place. Depending on the number of applications installed, this can take a few minutes. Please do NOT exit the application during this process."
									   delegate:self
							  cancelButtonTitle:nil
							  otherButtonTitles:nil];
	[alert1 show];
	[alert1 release];
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-18, self.view.frame.size.height/2+150, 36.0f, 36.0f)];
	[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[self.view addSubview:activityIndicator];
	[self.view bringSubviewToFront:activityIndicator];
	[activityIndicator startAnimating];
	
	[self performSelectorInBackground:@selector(scriptDeleteAllUsers) withObject:nil];
}

-(void) scriptDeleteAllUsers {
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	//char *path = [[[NSBundle mainBundle] bundlePath] UTF8String];
	char *path = "/private/var/mobile/UserProfiles/";
	
	char exec[9000];
	strcpy(exec,"");
	sprintf(exec, "%srm -rf %s;", exec, path);
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
	
	[self performSelectorOnMainThread:@selector(doneWithScript) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

-(void) doneWithScript {
	//[activityIndicator release];
	[UIApplication sharedApplication].idleTimerDisabled = NO;
	//[alert1 dismissWithClickedButtonIndex:0 animated:TRUE];
	[[NSThread mainThread] exit];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	NSLog(@"dealloc SelectUser");
	//[listData dealloc];
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
