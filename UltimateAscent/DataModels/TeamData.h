//
//  TeamData.h
//  UltimateAscent
//
//  Created by Kris Pettinger on 1/26/13.
//  Copyright (c) 2013 ROBONAUTS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamScore;

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
@end

@interface TeamData (CoreDataGeneratedAccessors)

- (void)addMatchObject:(TeamScore *)value;
- (void)removeMatchObject:(TeamScore *)value;
- (void)addMatch:(NSSet *)values;
- (void)removeMatch:(NSSet *)values;

@end
