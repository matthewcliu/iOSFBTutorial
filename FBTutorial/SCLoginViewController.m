//
//  SCLoginViewController.m
//  FBTutorial
//
//  Created by Matthew Liu on 6/11/13.
//  Copyright (c) 2013 Matthew Liu. All rights reserved.
//

#import "SCLoginViewController.h"

//Note import of AppDelegate so that performLogin can request a new FB session to be opened
#import "AppDelegate.h"

@interface SCLoginViewController ()

- (IBAction)performLogin:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation SCLoginViewController

@synthesize spinner;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Called from AppDelegate
- (IBAction)performLogin:(id)sender
{
    //Turns on activity spinner in the view - non-critical
    [[self spinner] startAnimating];
    
    //Grab a pointer to the appDelegate that is capable of accessing FBSession and opening a session
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"appDelegate from login is: %@", appDelegate);

    //Send message to application delegate to open a new session
    [appDelegate openSession];
}

- (void)loginFailed
{
    //User switched back to the app without authorizing. Stay here, but stop the spinner.
    [self.spinner stopAnimating];
}

@end
