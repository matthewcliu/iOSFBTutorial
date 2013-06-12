//
//  AppDelegate.m
//  FBTutorial
//
//  Created by Matthew Liu on 6/11/13.
//  Copyright (c) 2013 Matthew Liu. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

//Import both default and logging in view controllers
#import "SCLoginViewController.h"
#import "SCViewController.h"

NSString *const SCSessionStateChangedNotification = @"com.unicyclelabs.FBTutorial:SCSessionStateChangedNotification";

@implementation AppDelegate

//I didn't synthesize these as private variables like the tutorial suggested - purposefully did this to allow controllers to access
@synthesize navController;
@synthesize mainViewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    //Simple initialization of default view as root view in navigationController and navigationController as rootViewController of window
    mainViewController = [[SCViewController alloc] initWithNibName:@"SCViewController" bundle:nil];
    navController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    [[self window] setRootViewController:navController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //FB Auth logic at finish launched
    
    //Necessary for XIB files to recognize this class - this will be something that is used repeatedly for various FB libraries
    [FBProfilePictureView class];
    
    NSLog(@"Session state: %u", [[FBSession activeSession] state]);
    
    //Check to see if the app has a valid token for the current state
    if ([[FBSession activeSession] state] == FBSessionStateCreatedTokenLoaded) {
        //User is logged in, so call openSession
        [self openSession];
    } else {
        //Display the login page
        [self showLoginView];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //It's possible the auth was interrupted by a phone call or the user pressing the home button - the FB SDK will take care of cleanup. The session needs to know when the app is active again
    [[FBSession activeSession] handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//Facebook Authentication

//This method presents the login modal when FB Session state is closed or error
- (void)showLoginView
{
    //Grab a pointer to the top most view controller in the navigationController - this is standard practice with navigationControllers
    UIViewController *topViewController = [navController topViewController];
    
    //Grab a pointer to the presented view controller - note that this may be null if there is currently no presented controller
    UIViewController *presentedViewController = [topViewController presentedViewController];
    
    //If the current presented view controller is not the login controller, alloc/init a new login controller and present it
    if (![presentedViewController isKindOfClass:[SCLoginViewController class]]) {
        SCLoginViewController *loginViewController = [[SCLoginViewController alloc] initWithNibName:@"SCLoginViewController" bundle:nil];
        [topViewController presentViewController:loginViewController animated:NO completion:nil];
        NSLog(@"Login view controller presented");

    } else {
        //Grab a pointer to the presented login view controller
        SCLoginViewController *loginViewController = (SCLoginViewController *)presentedViewController;
        NSLog(@"About to call loginFailed");
        [loginViewController loginFailed];

    }
    
}

//Open a new active session in the FBSession object
- (void)openSession
{
    
    //Generate a completion handler to pass to below method back during session opening
    //Permissions can be set below
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state, NSError *error) {
                                      [self sessionStateChanged:session state:state error:error];
                                      NSLog(@"A new session has been opened - state: %u, error: %@", state, error);

                                  }];
}

//This handler is EXTREMELY important. It is passed the session object, the state, and any error messages. This will serve as the app-wide notification method for all other parts of the app
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    
    NSLog(@"Session state handler has been called. App-wide notification enabled");
    
    switch (state) {
        case FBSessionStateOpen:
        {
            //Grab a pointer to the topmost view on navigationController stack
            UIViewController *topViewController = [[self navController] topViewController];
            
            //If the topmost view is the login view, dismiss it to show content on next view in the stack
            if ([[topViewController presentedViewController] isKindOfClass:[SCLoginViewController class]]) {
                [topViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
        
        //For either closed or failed login cases, show the login view
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
        {
            //Pop off all other views that are accessible in logged in state
            [[self navController] popToRootViewControllerAnimated:NO];
            //Close session and clear tokens
            [FBSession.activeSession closeAndClearTokenInformation];
            //Then present login view over the default view state, remembering that other views have already been popped
            [self showLoginView];
        }
        default:
            break;
    }
    
    //Post to the notification center the session object under the notification name SCSessionStateChangedNotification - app-wide methods can sign up as observers to changes in the session object
    [[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification object:session];
    
    //Show an UIAlertView on authentication failure
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}


//Handles callback from mobile web browser or FB native app that logs user into - EXTREMELY IMPORTANT
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //Note that in this case we treat the callback URL in the same way, regardless of whether it came from the native app or mobile web
    NSLog(@"Callback URL from mobile web or native FB app is: %@", url);
    return [[FBSession activeSession] handleOpenURL:url];
}

@end
