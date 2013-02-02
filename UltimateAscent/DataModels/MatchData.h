//
//  MatchData.h
//  UltimateAscent
//
//  Created by FRC on 1/30/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamScore, TournamentData;

@interface MatchData : NSManagedObject

@property (nonatomic, retain) NSNumber * blueScore;
@property (nonatomic, retain) NSNumber * driverRating;
@property (nonatomic, retain) NSString * matchType;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * redScore;
@property (nonatomic, retain) NSSet *score;
@property (nonatomic, retain) TournamentData *tournament;
@end

@interface MatchData (CoreDataGeneratedAccessors)

- (void)addScoreObject:(TeamScore *)value;
- (void)removeScoreObject:(TeamScore *)value;
- (void)addScore:(NSSet *)values;
- (void)removeScore:(NSSet *)values;

@end
