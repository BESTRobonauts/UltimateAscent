//
//  CreateTeam.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 5/24/12.
//  Copyright (c) 2013 ROBONAUTS. All rights reserved.
//

#import "CreateTeam.h"
#import "DataManager.h"
#import "TeamData.h"

// Current File Order
/*
 1  Number
 2  Name
 3  Climbing
 4  Intake
 5  Upside Down
 6  Notes
 7  History

 Things to add yet
    Drive Train Notes
    
*/
@implementation CreateTeam
@synthesize managedObjectContext;

-(AddRecordResults)createTeamFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    NSNumber *teamNumber;

    if (![data count]) return DB_ERROR;

    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }

    teamNumber = [NSNumber numberWithInt:[[data objectAtIndex: 0] intValue]];
    NSLog(@"createTeamFromFile:Team Number = %@", teamNumber);
    TeamData *team = [self GetTeam:teamNumber];
    if (team) {
        NSLog(@"createTeamFromFile:Team %@ already exists", teamNumber);
        return DB_MATCHED;
    }
    else {
        NSNumber *number;
        TeamData *team = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData" 
                                                           inManagedObjectContext:managedObjectContext];        
        switch ([data count]) {
            case 7:
                team.history = [data objectAtIndex: 3];
            case 6:
                 team.notes = [data objectAtIndex: 2];
            case 5:
                number = [NSNumber numberWithInt:[[data objectAtIndex:4] intValue]];
                team.down = number;
            case 4:
                number = [NSNumber numberWithInt:[[data objectAtIndex:3] intValue]];
                team.intake = number;
            case 3:
                number = [NSNumber numberWithInt:[[data objectAtIndex:2] intValue]];
                team.climb = number;
            case 2:
                team.name = [data objectAtIndex: 1];
            case 1:
                team.number = teamNumber;
        }
        // NSLog(@"Added Team Record %@", team);
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            return DB_ERROR;
        }
        else return DB_ADDED;
    }
}

-(TeamData *)GetTeam:(NSNumber *)teamNumber {
    TeamData *team;

    NSLog(@"Searching for team = %@", teamNumber);
    NSError *error;
    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"TeamData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number == %@", teamNumber];    
    [fetchRequest setPredicate:pred];   
    NSArray *teamData = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        NSLog(@"Karma disruption error");
        return Nil;
    } 
    else {
        if([teamData count] > 0) {  // Team Exists
            team = [teamData objectAtIndex:0];
            NSLog(@"Team %@ exists", team.number);
            return team;
        }
        else {
            return Nil;
        }
    }
}

-(void)setTeamDefaults:(TeamData *)blankTeam {
    blankTeam.number = [NSNumber numberWithInt:0];
    blankTeam.name = @"";
    blankTeam.climb = [NSNumber numberWithInt:-1];
    blankTeam.intake = [NSNumber numberWithInt:-1];
    blankTeam.down = [NSNumber numberWithInt:0];
    blankTeam.notes = @"";
    blankTeam.history = @"";
    blankTeam.saved = [NSNumber numberWithInt:0];
}


@end
