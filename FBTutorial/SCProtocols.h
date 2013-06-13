//
//  SCProtocols.h
//  FBTutorial
//
//  Created by Matthew Liu on 6/13/13.
//  Copyright (c) 2013 Matthew Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol SCOGMeal <FBGraphObject>

@property (retain, nonatomic) NSString *id;
@property (retain, nonatomic) NSString *url;

@end

@protocol SCOGeatMealAction <FBOpenGraphAction>

@property (retain, nonatomic) id<SCOGMeal> meal;

@end