//
//  SMTournamentObject.m
//  UltimateAscent
//
//  Created by FRC on 3/30/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "SMTournamentObject.h"
#import "StackMob.h"
#import "DataManager.h"
#import "TournamentData.h"

@implementation SMTournamentObject

@synthesize dataManager = _dataManager;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(void)sendTournamentDataToSM:(NSArray *)tournamentRecords {
    NSError *error;
    
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
        
    // Loop through local tournament records
    for (int i=0; i < [tournamentRecords count]; i++) {
        TournamentData *tournament = [tournamentRecords objectAtIndex:i];
        NSLog(@"Tournament = %@", tournament.name);
        // Execute SM fetch of current local tournament record
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TournamentData" inManagedObjectContext:_dataManager.smManagedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicte = [NSPredicate predicateWithFormat:@"name == %@", tournament.name];
        [fetchRequest setPredicate:predicte];
        NSArray *SMTournamentRecord = [_dataManager.smManagedObjectContext executeFetchRequestAndWait:fetchRequest error:&error];
        NSLog(@"Successful fetch count = %d", [SMTournamentRecord count]);
        if ([SMTournamentRecord count]) {
            // Tournament exits, update it
            TournamentData *smTournament = [SMTournamentRecord objectAtIndex:0];
            [smTournament setValue:tournament.name forKey:@"name"];
            [smTournament setValue:tournament.directory forKey:@"directory"];
        }
        else {
            // Tournament doesn't exist, create it
            TournamentData *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"TournamentData" inManagedObjectContext:_dataManager.smManagedObjectContext];
            [newManagedObject setValue:tournament.name forKey:@"name"];
            [newManagedObject setValue:tournament.directory forKey:@"directory"];
            [newManagedObject setValue:[newManagedObject assignObjectId] forKey:[newManagedObject primaryKeyField]];            
        }
        if (![_dataManager.smManagedObjectContext saveAndWait:&error]) {
            NSLog(@"There was an error saving tournament data to Stack Mob %@", error);
        }
    }
}
@end
