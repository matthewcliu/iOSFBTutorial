//
//  SCViewController.h
//  FBTutorial
//
//  Created by Matthew Liu on 6/11/13.
//  Copyright (c) 2013 Matthew Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreLocation/CoreLocation.h>

//Need to clarify this - WTF?
typedef void(^SelectedItemCallback)(id sender, id selectedItem);

//Add protocol declarations since the view controller has a table view and a FBFriendPicker
@interface SCViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, FBFriendPickerDelegate, CLLocationManagerDelegate, FBPlacePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end
