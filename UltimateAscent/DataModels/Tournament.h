//
//  Tournament.h
//  UltimateAscent
//
//  Created by FRC on 1/30/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MatchData, Settings, TeamData, TeamScore;

@interface Tournament : NSManagedObject

@property (nonatomic, retain) NSString * directory;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) MatchData *match;
@property (nonatomic, retain) TeamScore *score;
@property (nonatomic, retain) TeamData *teams;
@property (nonatomic, retain) Settings *settings;

@end
