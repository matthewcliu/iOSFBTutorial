//
//  SCMealViewController.h
//  FBTutorial
//
//  Created by Matthew Liu on 6/13/13.
//  Copyright (c) 2013 Matthew Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCViewController.h"

@interface SCMealViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) SelectedItemCallback selectItemCallback;

@end
