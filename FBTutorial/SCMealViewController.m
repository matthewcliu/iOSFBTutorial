//
//  SCMealViewController.m
//  FBTutorial
//
//  Created by Matthew Liu on 6/13/13.
//  Copyright (c) 2013 Matthew Liu. All rights reserved.
//

#import "SCMealViewController.h"

@interface SCMealViewController ()

{
    NSArray *meals;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SCMealViewController

@synthesize selectItemCallback;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setTitle:@"Select a meal"];
        
        meals = [NSArray arrayWithObjects:@"Cheeseburger",@"Pizza", @"Hotdog", @"Italian", @"French", @"Chinese", @"Thai", @"Indian", nil];
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

//UITableView datasource and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [meals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    [[cell textLabel] setText: [meals objectAtIndex:[indexPath row]]];
    
    //Where is this image? May need to comment it out
    [[cell imageView] setImage:[UIImage imageNamed:@"action-eating.png"]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectItemCallback) {
        selectItemCallback(self, [meals objectAtIndex:[indexPath row]]);
    }
    
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
