//
//  SCViewController.m
//  FBTutorial
//
//  Created by Matthew Liu on 6/11/13.
//  Copyright (c) 2013 Matthew Liu. All rights reserved.
//

#import "SCViewController.h"
#import "AppDelegate.h"
#import "SCMealViewController.h"

#import "SCProtocols.h"
#import <FacebookSDK/FBRequest.h>

@interface SCViewController ()

//Create new property using FB class for profile picture (subclass of UIImage)
@property (weak, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@property (strong, nonatomic) CLLocationManager *locationManager;

//Create new instance of FBFriendPickerViewController
@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) NSArray *selectedFriends;

//Create new instance of FBPlacePickerViewController
@property (strong, nonatomic) FBPlacePickerViewController *placePickerController;
@property (strong, nonatomic) NSObject<FBGraphPlace> *selectedPlace;

//Instance variables for meals
@property (strong, nonatomic) SCMealViewController *mealViewController;
@property (strong, nonatomic) NSString *selectedMeal;

//Image picker
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImage *selectedPhoto;
@property (strong, nonatomic) UIPopoverController *popover;

//Publish Action button
@property (weak, nonatomic) IBOutlet UIButton *announceButton;
- (IBAction)announce:(id)sender;


@end

@implementation SCViewController

@synthesize menuTableView;
@synthesize locationManager;

@synthesize friendPickerController;
@synthesize selectedFriends;

@synthesize placePickerController;
@synthesize selectedPlace;

@synthesize mealViewController;
@synthesize selectedMeal;

@synthesize imagePicker;
@synthesize selectedPhoto;
@synthesize popover;

@synthesize announceButton;

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
    
    //Start location
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [locationManager setDistanceFilter:50];
    [locationManager startUpdatingLocation];
    
    //Add title to navigation toolbar
    [self setTitle:@"Scrumptious"];
    
    //Add FB logout button
    [self navigationItem].rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutButtonWasPressed:)];
    
    //Add this view controller as an observer to the session state that is managed by sessionStatechanged in the Notification Center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:) name:SCSessionStateChangedNotification object:nil];
}

- (void)viewDidUnload
{
    //Remove viewController from Notification Center
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //Kill friend picker, place picker, and location manager
    [self setFriendPickerController: nil];
    [self setPlacePickerController:nil];
    [locationManager setDelegate:nil];
    imagePicker = nil;
    popover = nil;
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


//Methods for managing tableView

//Datasource for cells

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    //Standard memory management of tableView cells - check for cells that are offscreen and replace them - this won't happen in this table though
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        //Note copied cell formatting directly from FB documentation - standard tableViewCell formatting
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        cell.textLabel.clipsToBounds = YES;
        
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.4
                                                         green:0.6
                                                          blue:0.8
                                                         alpha:1];
        cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        cell.detailTextLabel.clipsToBounds = YES;
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"What are you eating?";
            cell.detailTextLabel.text = @"Select one";
            cell.imageView.image = [UIImage imageNamed:@"action-eating.png"];
            break;
            
        case 1:
            cell.textLabel.text = @"Where are you?";
            cell.detailTextLabel.text = @"Select one";
            cell.imageView.image = [UIImage imageNamed:@"action-location.png"];
            break;
            
        case 2:
            cell.textLabel.text = @"With whom?";
            cell.detailTextLabel.text = @"Select friends";
            cell.imageView.image = [UIImage imageNamed:@"action-people.png"];
            break;
            
        case 3:
            cell.textLabel.text = @"Got a picture?";
            cell.detailTextLabel.text = @"Take one";
            cell.imageView.image = [UIImage imageNamed:@"action-photo.png"];
            break;
            
        default:
            break;
    }
    
    return cell;
}

//Delegate method for tableViewCell touches

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath row]) {
        
        case 0:
            
            if (!mealViewController) {
                __block SCViewController *myself = self;
                mealViewController = [[SCMealViewController alloc] initWithNibName:@"SCMealViewController" bundle:nil];
                
                [mealViewController setSelectItemCallback:^(id sender, id selectedItem)  {
                    [myself setSelectedMeal: selectedItem];
                    [myself updateSelections];
                    
                }];
            }
            [[self navigationController] pushViewController:mealViewController animated:YES];
            
            break;
            
        case 1:
            if (!placePickerController) {
                placePickerController = [[FBPlacePickerViewController alloc] initWithNibName:nil bundle:nil];
                [placePickerController setTitle:@"Select a restaurant"];
                
                //Set the place picker delegate
                [placePickerController setDelegate:self];

            }
            
            [placePickerController setLocationCoordinate:[[locationManager location] coordinate]];
            [placePickerController setRadiusInMeters:1000];
            [placePickerController setResultsLimit:50];
            [placePickerController setSearchText:@"restaurant"];
            
            [placePickerController loadData];
            [[self navigationController] pushViewController:placePickerController animated:YES];
            
            break;
        
        case 2:
            if (!friendPickerController) {
                friendPickerController = [[FBFriendPickerViewController alloc] initWithNibName:nil bundle:nil];
                [friendPickerController setTitle:@"Select Friends"];
                
                //Set the friend picker delegate
                [friendPickerController setDelegate:self];
            }
            
            //loadData is a method that was overridden in FBFriendPickerViewController to load all friend data
            [friendPickerController loadData];
            [[self navigationController] pushViewController:friendPickerController animated:YES ];
            
            break;
        
        case 3:
            if (!imagePicker) {
                imagePicker = [[UIImagePickerController alloc] init];
                [imagePicker setDelegate:self];
                
                //Only allow camera roll for this demo
                [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                // Can't use presentModalViewController for image picker on iPad
                if (!popover) {
                    popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
                }
                
                CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
                [popover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                [self presentViewController:imagePicker animated:true completion:nil];
            }
            
            break;
            
        default:
            break;
    }
}

//FB delegate method for picking friends - included in the FBFriendPickerViewController class
- (void)friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker
{
    //selection is a custom FB method to return the selected friends from the friend picker
    selectedFriends = [friendPicker selection];
    
    //Call updateSelections method
    [self updateSelections];
}

//FB delegate method for picking a place - included in the FBPlacePickerViewController class
- (void)placePickerViewControllerSelectionDidChange:(FBPlacePickerViewController *)placePicker
{
    //selection is a custom FB method to return the selected friends from the place picker
    selectedPlace = [placePicker selection];
    
    //Call updateSelections method
    [self updateSelections];
    
    if ([selectedPlace count] > 0) {
        [[self navigationController] popViewControllerAnimated: YES];
    }
}

//Imagepicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    selectedPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [popover dismissPopoverAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:TRUE completion:nil];
    }
    
    [self updateSelections];
}

- (void)updateSelections
{
    NSString *friendsSubtitle = @"Select friends";
    int friendCount = [selectedFriends count];
    
    if (friendCount > 2) {
        //Don't always show the first friend, just to be random
        //Protocol object
        id<FBGraphUser>randomFriend = [selectedFriends objectAtIndex:arc4random() % friendCount];
        friendsSubtitle = [NSString stringWithFormat:@"%@ and %d others", [randomFriend name], friendCount - 1];
    } else if (friendCount == 2) {
        id<FBGraphUser> friend1 = [selectedFriends objectAtIndex:0];
        id<FBGraphUser> friend2 = [selectedFriends objectAtIndex:1];
        friendsSubtitle = [NSString stringWithFormat:@"%@ and %@", [friend1 name], [friend2 name]];
    } else if (friendCount == 1) {
        id<FBGraphUser> friend = [selectedFriends objectAtIndex:0];
        friendsSubtitle = [NSString stringWithFormat:@"%@ ", [friend name]];
    }
    
    [self updateCellIndex:0 withSubtitle: selectedMeal ? selectedMeal : @"Select One"];
    [self updateCellIndex:1 withSubtitle: selectedPlace ? [selectedPlace name] : @"Select One"];
    [self updateCellIndex:2 withSubtitle:friendsSubtitle];
    [self updateCellIndex:3 withSubtitle: selectedPhoto ? @"Ready" : @"Take one"];
    
    [announceButton setEnabled:(selectedMeal != nil)];
    
}

- (void)updateCellIndex:(int)index withSubtitle:(NSString *)subtitle
{
    //Grab a pointer to the cell that was tapped - in this case it will be the select friends cell
    UITableViewCell *cell = (UITableViewCell *) [menuTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [[cell detailTextLabel] setText:subtitle];
}

- (void)dealloc
{
    [friendPickerController setDelegate:nil];
    [imagePicker setDelegate:nil];
}

//locationManager delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"New location: %@", newLocation);
    NSLog(@"got location: %f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);

    /*
    CLLocation *oldLocation = [locations objectAtIndex:[locations count] - 2];
    
    if (!oldLocation || (oldLocation.coordinate.latitude != newLocation.coordinate.latitude && oldLocation.coordinate.longitude != newLocation.coordinate.longitude)) {

        NSLog(@"got location: %f, %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    }
     */

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}


//Pushing to OG

//This method generates an Open Graph URL for POST using the PHP page - in practice this is not how you would do it
- (id<SCOGMeal>)mealObjectForMeal:(NSString *)meal
{
    //Backend heroku URL
    NSString * format = @"https://immense-atoll-7280.herokuapp.com/?fb:app_id=527383000662832&og:type=%@&og:title=%@&og:description=%@isdelicious&og:image=https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn1/c35.34.434.434/s160x160/19850_663333582023_942791_n.jpg&body=%@";
    
    //Creat a FBGraphObject and treat it as a SCOGMeal with typed properties
    id<SCOGMeal> result = (id<SCOGMeal>)[FBGraphObject graphObject];
    
    //Give it a URL that will echo back the name of the meal as its title, description, and body
    
    [result setUrl: [NSString stringWithFormat:format, @"unicycleprototype:meal", meal, meal, meal]];
    
    return result;
    
}

- (void)postPhotoThenOpenGraphAction
{
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    
    //Logging code
    
    NSLog(@"FBSession accesstokenData: %@", [[FBSession activeSession]accessTokenData]);
    NSLog(@"===requestForUploadPhoto logging===");
    [FBSettings setLoggingBehavior:[NSSet
                                    setWithObjects:FBLoggingBehaviorFBRequests,
                                    FBLoggingBehaviorFBURLConnections,
                                    nil]];
    
    //First request uploads the photo
    FBRequest *request1 = [FBRequest requestForUploadPhoto:selectedPhoto];
    [connection addRequest:request1 completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            
        }
    }
        batchEntryName:@"photopost"
    ];
    
    //Logging code
    NSLog(@"===requestForGraphPath logging===");
    [FBSettings setLoggingBehavior:[NSSet
                                    setWithObjects:FBLoggingBehaviorFBRequests,
                                    FBLoggingBehaviorFBURLConnections,
                                    nil]];
    
    //Second request retrieves photo information for just-created photo so we can grab its source
    FBRequest *request2 = [FBRequest requestForGraphPath:@"{result=photopost:$.id}"];
    [connection addRequest:request2 completionHandler:^(FBRequestConnection *connection, id result, NSError * error) {
        if (!error && result) {
            NSString *source = [result objectForKey:@"source"];
            [self postOpenGraphActionWithPhotoURL:source];
        }
    }
    ];
    
    [connection start];
}

//User defined method
- (void)postOpenGraphActionWithPhotoURL:(NSString *)photoURL
{
    //First create the Open Graph meal object for the meal we ate
    id<SCOGMeal> mealObject = [self mealObjectForMeal:selectedMeal];
    
    //Now create an Open Graph eat action with the meal, our location, and the people we were with.
    id<SCOGetMealAction> action = (id<SCOGetMealAction>)[FBGraphObject graphObject];
    
    //Where is this coming from? Unclear where this is being defined in protocol file
    [action setMeal:mealObject];
    
    //setPlace, setTags, and setImage are defined by FBGraphObject so are inherited into our mealObject
    if(selectedPlace) {
        [action setPlace:selectedPlace];
    }
    
    if ([selectedFriends count] > 0) {
        [action setTags:selectedFriends];
    }
    
    if (photoURL) {
        NSMutableDictionary *image = [[NSMutableDictionary alloc] init];
        [image setObject:photoURL forKey:@"url"];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        [images addObject:image];
        
        [action setImage:images];
    }
    
    //Then create the request and post the action to the "me/<unicycleprototype:eat" path
    
    //Logging code
    NSLog(@"FBSession accesstokenData: %@", [[FBSession activeSession]accessTokenData]);
    NSLog(@"===requestForPostWithGraphPath logging===");

    [FBSettings setLoggingBehavior:[NSSet
                                    setWithObjects:FBLoggingBehaviorFBRequests,
                                    FBLoggingBehaviorFBURLConnections,
                                    nil]];
    
    [FBRequestConnection startForPostWithGraphPath:@"me/unicycleprototype:eat" graphObject:action completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSString *alertText;
        if (!error) {
            alertText = [NSString stringWithFormat:@"Posted Open Graph action, id: %@", [result objectForKey:@"id"]];
        } else {
            alertText = [NSString stringWithFormat:@"error: domain = %@, code = %d", [error domain], [error code]];
        }
        [[[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:nil cancelButtonTitle:@"Thanks!" otherButtonTitles:nil] show];
    }
    ];
}

- (IBAction)announce:(id)sender
{
    if ([[[FBSession activeSession] permissions] indexOfObject:@"publish_actions"] == NSNotFound) {
        
        [[FBSession activeSession] requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends completionHandler: ^(FBSession *session, NSError *error) {
            if (!error) {
                [self announce:sender];
            }
        }];
    } else {
        if (selectedPhoto) {
            [self postPhotoThenOpenGraphAction];
        } else {
            [self postOpenGraphActionWithPhotoURL:nil];
        }
    }
}

@end
