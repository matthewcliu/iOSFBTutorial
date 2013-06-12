//
//  AppDelegate.m
//  FBTutorial
//
//  Created by Matthew Liu on 6/11/13.
//  Copyright (c) 2013 Matthew Liu. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

#import "SCLoginViewController.h"
#import "SCViewController.h"

@implementation AppDelegate

@synthesize navController;
@synthesize mainViewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    

    
    mainViewController = [[SCViewController alloc] initWithNibName:@"SCViewController" bundle:nil];
    navController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    
    [[self window] setRootViewController:navController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    NSLog(@"Session state: %u", [[FBSession activeSession] state]);
    
    //Check to see if the app has a valid token for the current state
    if ([[FBSession activeSession] state] == FBSessionStateCreatedTokenLoaded) {
        //User is logged in
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//Facebook Authentication
- (void)showLoginView
{
    //Grab a pointer to the top most view controller
    UIViewController *topViewController = [navController topViewController];
    
    //Grab a pointer to the presented view controller
    UIViewController *presentedViewController = [topViewController presentedViewController];
    
    if (![presentedViewController isKindOfClass:[SCLoginViewController class]]) {
        SCLoginViewController *loginViewController = [[SCLoginViewController alloc] initWithNibName:@"SCLoginViewController" bundle:nil];
        [topViewController presentViewController:loginViewController animated:NO completion:nil];
        NSLog(@"Attempted to run presentViewController");

    } else {
        SCLoginViewController *loginViewController = (SCLoginViewController *)presentedViewController;
        [loginViewController loginFailed];
    }
    
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
        {
            UIViewController *topViewController = [[self navController] topViewController];
            if ([[topViewController presentedViewController] isKindOfClass:[SCLoginViewController class]]) {
                [topViewController dismissViewControllerAnimated:YES completion:nil];
            }
        }
            break;
            
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
        {
            //Once the user has logged in, we want them to be looking at the root view
            [[self navController] popToRootViewControllerAnimated:NO];
            [FBSession.activeSession closeAndClearTokenInformation];
            [self showLoginView];
        }
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)openSession
{
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state, NSError *error) {
        [self sessionStateChanged:session state:state error:error];
    }];
}

//Handles callback from mobile web browser that logs user in
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSession activeSession] handleOpenURL:url];
}

@end
