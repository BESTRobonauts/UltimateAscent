//
//  SMMatchObject.m
//  UltimateAscent
//
//  Created by FRC on 4/8/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "SMMatchObject.h"
#import "StackMob.h"
#import "DataManager.h"
#import "MatchData.h"
#import "TeamScore.h"

@implementation SMMatchObject

@synthesize dataManager = _dataManager;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(void)sendMatchDataToSM:(NSArray *)matchRecords {
    NSError *error;
    MatchData *smMatch;
    
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }

    // Loop through local match records
    for (int i=0; i < [matchRecords count]; i++) {
        MatchData *match = [matchRecords objectAtIndex:i];
        if ([match.number intValue] == 118) continue;
        // Execute SM fetch of current local tournament record

        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"MatchData" inManagedObjectContext:_dataManager.smManagedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                  @"number == %@ AND matchType CONTAINS %@ and tournament.name CONTAINS %@", match.number, match.matchType, match.tournament];
        [fetchRequest setPredicate:predicate];
        NSArray *SMMatchDataRecord = [_dataManager.smManagedObjectContext executeFetchRequestAndWait:fetchRequest error:&error];
        NSLog(@"Successful fetch count = %d", [SMMatchDataRecord count]);
        if ([SMMatchDataRecord count]) {
            NSLog(@"Shouldn't be here");
            // Match exits, update it
            smMatch = [SMMatchDataRecord objectAtIndex:0];
      //      [self setMatchRecord:smMatch forLocalMatch:match];
        }
        else {
            // Match doesn't exist, create it
            NSLog(@"SM match does not exist");
            smMatch = [NSEntityDescription insertNewObjectForEntityForName:@"MatchData" inManagedObjectContext:_dataManager.smManagedObjectContext];
            [smMatch setValue:[smMatch assignObjectId] forKey:[smMatch primaryKeyField]];
            smMatch.number = match.number;
            smMatch.tournament = match.tournament;
            int stupid = [match.matchTypeSection intValue];
            smMatch.matchTypeSection = match.matchTypeSection;  // [NSNumber numberWithInt:stupid*10];

     //       [self setMatchRecord:newManagedObject forLocalMatch:match];
        }
        smMatch.redScore = match.redScore;
        smMatch.blueScore = match.blueScore;
        NSLog(@"match = %@ Type = %@ Section = %@ Red %@ Blue %@", smMatch.number, smMatch.matchType, smMatch.matchTypeSection, smMatch.redScore, smMatch.blueScore);
       if (![_dataManager.smManagedObjectContext saveAndWait:&error]) {
            NSLog(@"There was an error saving team data to Stack Mob %@", error);
            return;
        }
    }
}

-(void)setMatchRecord:(MatchData *)smMatch forLocalMatch:(MatchData *)match {
    NSError *error;
    
    smMatch.redScore = match.redScore;
    smMatch.blueScore = match.blueScore;
    
    if (![_dataManager.smManagedObjectContext saveAndWait:&error]) {
        NSLog(@"There was an error saving team data to Stack Mob %@", error);
        return;
    }
    
/*    match.stacked = [NSNumber numberWithInt:1];
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }*/
}

@end
