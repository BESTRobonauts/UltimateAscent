//
//  TeamData.h
//  UltimateAscent
//
//  Created by FRC on 1/30/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamScore, Tournament;

@interface TeamData : NSManagedObject

@property (nonatomic, retain) NSNumber * climb;
@property (nonatomic, retain) NSNumber * down;
@property (nonatomic, retain) NSString * history;
@property (nonatomic, retain) NSNumber * intake;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * saved;
@property (nonatomic, retain) NSSet *match;
@property (nonatomic, retain) NSSet *tournament;
@end

@interface TeamData (CoreDataGeneratedAccessors)

- (void)addMatchObject:(TeamScore *)value;
- (void)removeMatchObject:(TeamScore *)value;
- (void)addMatch:(NSSet *)values;
- (void)removeMatch:(NSSet *)values;

- (void)addTournamentObject:(Tournament *)value;
- (void)removeTournamentObject:(Tournament *)value;
- (void)addTournament:(NSSet *)values;
- (void)removeTournament:(NSSet *)values;

@end
