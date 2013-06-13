//
//  SCViewController.m
//  FBTutorial
//
//  Created by Matthew Liu on 6/11/13.
//  Copyright (c) 2013 Matthew Liu. All rights reserved.
//

#import "SCViewController.h"
#import "AppDelegate.h"

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

@end

@implementation SCViewController

@synthesize menuTableView;
@synthesize locationManager;

@synthesize friendPickerController;
@synthesize selectedFriends;

@synthesize placePickerController;
@synthesize selectedPlace;

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
    
    [self updateCellIndex:1 withSubtitle: selectedPlace ? [selectedPlace name] : @"Select One"];
    [self updateCellIndex:2 withSubtitle:friendsSubtitle];
    
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

@end
