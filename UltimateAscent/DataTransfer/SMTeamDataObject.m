//
//  SMTeamDataObject.m
//  UltimateAscent
//
//  Created by FRC on 3/30/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "SMTeamDataObject.h"
#import "StackMob.h"
#import "DataManager.h"
#import "TournamentData.h"
#import "TeamData.h"

#define SMALL 0.0000000000001

@implementation SMTeamDataObject

@synthesize dataManager = _dataManager;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(void)sendTeamDataToSM:(NSArray *)teamRecords {
    NSError *error;
    
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    // Loop through local team records
    for (int i=0; i < [teamRecords count]; i++) {
        TeamData *team = [teamRecords objectAtIndex:i];
        NSLog(@"Team = %@", team.name);
        // Execute SM fetch of current local tournament record
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"TeamData" inManagedObjectContext:_dataManager.smManagedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicte = [NSPredicate predicateWithFormat:@"number == %@", team.number];
        [fetchRequest setPredicate:predicte];
        NSArray *SMTeamDataRecord = [_dataManager.smManagedObjectContext executeFetchRequestAndWait:fetchRequest error:&error];
        NSLog(@"Successful fetch count = %d", [SMTeamDataRecord count]);
        if ([SMTeamDataRecord count]) {
            // Team exits, update it
            TeamData *smTeam = [SMTeamDataRecord objectAtIndex:0];
            [self setTeamRecord:smTeam forLocalTeam:team];
        }
        else {
            // Team doesn't exist, create it
            TeamData *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData" inManagedObjectContext:_dataManager.smManagedObjectContext];
            [newManagedObject setValue:[newManagedObject assignObjectId] forKey:[newManagedObject primaryKeyField]];
            [self setTeamRecord:newManagedObject forLocalTeam:team];
        }
    }
}

-(void)retrieveTeamDataFromSM:(NSArray *)teamRecords {
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }

}

-(void)setTeamRecord:(TeamData *)smTeam forLocalTeam:(TeamData *)team {
    NSError *error;
    smTeam.name = team.name;
    smTeam.auton = team.auton;
    smTeam.cims = team.cims;
    smTeam.climbLevel = team.climbLevel;
    smTeam.driveTrainType = team.driveTrainType;
    smTeam.fthing1 = team.fthing1;
    smTeam.fthing2 = team.fthing2;
    smTeam.fthing3 = team.fthing3;
    smTeam.fthing4 = team.fthing4;
    smTeam.fthing5 = team.fthing5;
    smTeam.history = team.history;
    smTeam.intake = team.intake;
    smTeam.maxHeight = team.maxHeight;
    smTeam.minHeight = team.minHeight;
    smTeam.notes = team.notes;
    smTeam.number = team.number;
    smTeam.nwheels = team.nwheels;
    smTeam.pyramidDump = team.pyramidDump;
    smTeam.shooterHeight = team.shooterHeight;
    smTeam.shootsTo = team.shootsTo;
    smTeam.sthing1 = team.sthing1;
    smTeam.sthing3 = team.sthing3;
    smTeam.sthing4 = team.sthing4;
    smTeam.sthing5 = team.sthing5;
    smTeam.sting2 = team.sting2;
    smTeam.thing1 = team.thing1;
    smTeam.thing2 = team.thing2;
    smTeam.thing3 = team.thing3;
    smTeam.thing4 = team.thing4;
    smTeam.thing5 = team.thing5;
    smTeam.wheelDiameter = team.wheelDiameter;
    smTeam.wheelType = team.wheelType;

    if (![_dataManager.smManagedObjectContext saveAndWait:&error]) {
        NSLog(@"There was an error saving team data to Stack Mob %@", error);
        return;
    }
    
    team.stacked = [NSNumber numberWithInt:1];
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
/*
    NSArray *SMtournamentList = [smTeam.tournament allObjects];
    NSArray *tournamentList = [team.tournament allObjects];    
    TournamentData *smTournament;
    for (int i=0; i<[tournamentList count]; i++) {
        BOOL found = FALSE;
        TournamentData *tournament = [tournamentList objectAtIndex:i];
        NSLog(@"tournament = %@", tournament.name);
        for (int j=0; j<[SMtournamentList count]; j++) {
            smTournament = [SMtournamentList objectAtIndex:j];
            NSLog(@"sm tournament = %@", smTournament.name);
            if ([smTournament.name isEqualToString: tournament.name]) {
                found = TRUE;
                break;
            }
        }
        if (found) {
            NSLog(@"Found a T match = %@", smTournament.name);
        }
        else {
            NSLog(@"Need a new T record for %@", tournament.name);
        }
    }
*/
}

@end
