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
        //To do - show logged in view
    } else {
        //Display the login page instead
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
    
    NSLog(@"The Navigation Controller is: %@", navController);
    NSLog(@"the topViewController is: %@", topViewController);
    
    SCLoginViewController *loginViewController = [[SCLoginViewController alloc] initWithNibName:@"SCLoginViewController" bundle:nil];
    [topViewController presentViewController:loginViewController animated:NO completion:nil];
    NSLog(@"Attempted to run presentViewController");
}

@end
