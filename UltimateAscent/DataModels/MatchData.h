//
//  MatchData.h
//  UltimateAscent
//
//  Created by Kris Pettinger on 1/26/13.
//  Copyright (c) 2013 ROBONAUTS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamScore;

@interface MatchData : NSManagedObject

@property (nonatomic, retain) NSNumber * blueScore;
@property (nonatomic, retain) NSNumber * driverRating;
@property (nonatomic, retain) NSString * matchType;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * redScore;
@property (nonatomic, retain) NSSet *score;
@end

@interface MatchData (CoreDataGeneratedAccessors)

- (void)addScoreObject:(TeamScore *)value;
- (void)removeScoreObject:(TeamScore *)value;
- (void)addScore:(NSSet *)values;
- (void)removeScore:(NSSet *)values;

@end
