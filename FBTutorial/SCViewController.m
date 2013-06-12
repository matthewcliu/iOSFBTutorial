//
//  SCViewController.m
//  FBTutorial
//
//  Created by Matthew Liu on 6/11/13.
//  Copyright (c) 2013 Matthew Liu. All rights reserved.
//

#import "SCViewController.h"
#import <FacebookSDK/FacebookSDK.h>

//Note import of AppDelegate to ???
#import "AppDelegate.h"

@interface SCViewController ()

@property (weak, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation SCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Add FB logout button
    [self navigationItem].rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonWasPressed:)];
    
    //Add this view controller as an observer to the session state that is managed by sessionStatechanged in the Notification Center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:) name:SCSessionStateChangedNotification object:nil];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Every single time the view appears, check to see if the session is open
    if ([[FBSession activeSession] isOpen]) {
        [self populateUserDetails];
    }
}

//Whenever the view controller gets a notification (through adding itself as an observer in viewDidLoad), call populateUserDetails
- (void)sessionStateChanged:(NSNotification *)notification
{
    [self populateUserDetails];
}

- (void)logoutButtonWasPressed:(id)sender
{
    //Close the FB activeSession - note that because of the always-on handler sessionStateChanged: no logic to display the login view needs to be implemented here. It will be done by the handler.
    [[FBSession activeSession] closeAndClearTokenInformation];
}

- (void)populateUserDetails
{
    if([[FBSession activeSession] isOpen]) {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error)  {
            if (!error){
                //If there is no error populate the view with response details
                [[self userNameLabel] setText:[user name]];
                [[self userProfileImage] setProfileID: [user id]];
            }
        }];
    }
}

@end
