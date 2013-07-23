//
//  TeamDataInterfaces.m
//  UltimateAscent
//
//  Created by FRC on 5/2/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "TeamDataInterfaces.h"
#import "DataManager.h"
#import "TeamData.h"
#import "TournamentData.h"
#import "CreateTournament.h"
#import "Regional.h"

@implementation TeamDataInterfaces
@synthesize dataManager = _dataManager;
@synthesize teamDataDictionary = _teamDataDictionary;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
        [self createTeamDataCollection];
	}
	return self;
}

-(AddRecordResults)createTeamFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    NSNumber *teamNumber;
    TeamData *team;
    AddRecordResults results = DB_ADDED;

    if (![data count]) return DB_ERROR;
    
    // For now, I am going to only allow it to work if the team number is in the first column
    if (![[headers objectAtIndex:0] isEqualToString:@"Team Number"]) {
        return DB_ERROR;
    }
    teamNumber = [NSNumber numberWithInt:[[data objectAtIndex: 0] intValue]];
    NSLog(@"Found team number = %@", teamNumber);
    team = [self getTeam:teamNumber];
    if (team) {
        // NSLog(@"createTeamFromFile:Team %@ already exists", teamNumber);
        // NSLog(@"Team = %@", team);
        results = DB_MATCHED;
    }
    else {
        team = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData"
                                                       inManagedObjectContext:_dataManager.managedObjectContext];
        [self setTeamDefaults:team];        
        [team setValue:teamNumber forKey:@"number"];
    }
    for (int i=1; i<[data count]; i++) {
        [self setTeamValue:team forHeader:[headers objectAtIndex:i] withValue:[data objectAtIndex:i]];
    }
    //    NSLog(@"Team = %@", team);
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        results = DB_ERROR;
    }
    return results;
}

-(void)setTeamValue:(TeamData *)team forHeader:header withValue:data {
    NSNumber *type =[_teamDataDictionary objectForKey:header];
    NSLog (@"Key = %@, Type = %@, Value = %@", header, type, data);
    switch ([type intValue]) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
            [team setValue:[NSNumber numberWithInt:[data intValue]] forKey:header];
            break;
        case NSFloatAttributeType:
        case NSDoubleAttributeType:
        case NSDecimalAttributeType:
            [team setValue:[NSNumber numberWithFloat:[data floatValue]] forKey:header];
            break;
        case NSStringAttributeType:
            [team setValue:data forKey:header];
            break;
        case NSBooleanAttributeType:
            [team setValue:[NSNumber numberWithInt:[data intValue]] forKey:header];
            break;
        case -100: {
            // Check to make sure that the tournament exists in the TournamentData db
            TournamentData *tournamentRecord = [[[CreateTournament alloc] initWithDataManager:_dataManager] GetTournament:data];
            if (tournamentRecord) {
                NSLog(@"Found = %@", tournamentRecord.name);
                // Check to make sure this team does not already have this tournament
                NSArray *allTournaments = [team.tournament allObjects];
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", tournamentRecord.name];
                NSArray *list = [allTournaments filteredArrayUsingPredicate:pred];
                if (![list count]) {
                    NSLog(@"Adding Tournament");
                    [team addTournamentObject:tournamentRecord];
                }
                else {
                    NSLog(@"Tournament Exists, count = %d", [list count]);
                }
            }
            break;
        }
        case -200:
            break;
        default: break;
    }
}

-(void) createTeamDataCollection {
    NSLog(@"createTeamDataCollection");
    _teamDataDictionary = [[NSMutableDictionary alloc] init];
    TeamData *team = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData"
                                                   inManagedObjectContext:_dataManager.managedObjectContext];
    // NSLog(@"team data = %@", team);
    NSDictionary *attributes = [[team entity] attributesByName];
    for (NSAttributeDescription *teamProperties in [[team entity] properties]) {
        if ([attributes objectForKey:teamProperties.name]) {
            // NSLog(@"name = %@, type = %d", teamProperties.name, teamProperties.attributeType);
            [_teamDataDictionary setObject:[NSNumber numberWithInt:teamProperties.attributeType] forKey:teamProperties.name];
         }
    }
//  Hack work around to get the relationship. Must fix this someday.
    [_teamDataDictionary setObject:[NSNumber numberWithInt:-100] forKey:@"tournament"];
    [_teamDataDictionary setObject:[NSNumber numberWithInt:-200] forKey:@"regional"];
    // NSLog(@"Disctionary = %@", _teamDataDictionary);
}

-(TeamData *)getTeam:(NSNumber *)teamNumber {
    TeamData *team;
    
    // NSLog(@"Searching for team = %@", teamNumber);
    NSError *error;
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number == %@", teamNumber];
    [fetchRequest setPredicate:pred];
    NSArray *teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        NSLog(@"Karma disruption error");
        return Nil;
    }
    else {
        if([teamData count] > 0) {  // Team Exists
            team = [teamData objectAtIndex:0];
            // NSLog(@"Team %@ exists", team.number);
            return team;
        }
        else {
            return Nil;
        }
    }
}

-(NSArray *)getTeamListTournament:(NSString *)tournament {
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Add the search for tournament name
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournament.name = %@",  tournament];
    [fetchRequest setPredicate:pred];
    NSArray *teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSSortDescriptor *sortByNumber = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    NSArray *sortedTeams = [teamData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByNumber]];
    return sortedTeams;
}

-(void)setTeamDefaults:(TeamData *)blankTeam {
    blankTeam.number = [NSNumber numberWithInt:0];
    blankTeam.name = @"";
    blankTeam.climbLevel = [NSNumber numberWithInt:-1];
    blankTeam.driveTrainType = [NSNumber numberWithInt:-1];
    blankTeam.history = @"";
    blankTeam.intake = [NSNumber numberWithInt:-1];
    blankTeam.climbSpeed = [NSNumber numberWithFloat:0.0];
    blankTeam.notes = @"";
    blankTeam.wheelDiameter = [NSNumber numberWithFloat:0.0];
    blankTeam.cims = [NSNumber numberWithInt:0];
    blankTeam.minHeight = [NSNumber numberWithFloat:0.0];
    blankTeam.maxHeight = [NSNumber numberWithFloat:0.0];
    blankTeam.shooterHeight = [NSNumber numberWithFloat:0.0];
    blankTeam.pyramidDump = [NSNumber numberWithInt:-1];
    blankTeam.saved = [NSNumber numberWithInt:0];
}


@end
