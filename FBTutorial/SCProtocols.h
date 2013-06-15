//
//  SCProtocols.h
//  FBTutorial
//
//  Created by Matthew Liu on 6/13/13.
//  Copyright (c) 2013 Matthew Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

//SCOGMeal conforms to FBGraphObject protocol
@protocol SCOGMeal <FBGraphObject>

//Additionally there is an id to the graph object and a URL - why is this not already part of the FBGraphObject protocol?
@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;

@end

//SCOGGetMealAction protocol conforms to FBOpenGraphAction
@protocol SCOGetMealAction <FBOpenGraphAction>

//SCOGGetMealAction objects must have a meal that conforms to the SCOGMeal protocol
@property (retain, nonatomic) id<SCOGMeal> meal;

@end