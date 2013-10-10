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
@synthesize regionalDictionary = _regionalDictionary;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
        [self createTeamDataCollection];
        [self createRegionalCollection];
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
    // NSLog(@"Found team number = %@", teamNumber);
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
    // NSLog (@"Key = %@, Type = %@, Value = %@", header, type, data);
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
                // NSLog(@"Found = %@", tournamentRecord.name);
                // Check to make sure this team does not already have this tournament
                NSArray *allTournaments = [team.tournament allObjects];
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", tournamentRecord.name];
                NSArray *list = [allTournaments filteredArrayUsingPredicate:pred];
                if (![list count]) {
                    // NSLog(@"Adding Tournament");
                    [team addTournamentObject:tournamentRecord];
                }
                else {
                    // NSLog(@"Tournament Exists, count = %d", [list count]);
                }
            }
            break;
        }
        case -200:
            break;
        default: break;
    }
}

-(AddRecordResults)addTeamHistoryFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    NSNumber *teamNumber;
    TeamData *team;
    AddRecordResults results = DB_ADDED;
    
    if (![data count]) return DB_ERROR;
    
    // For now, I am going to only allow it to work if the team number is in the first column
    // and the header is Team History
    if (![[headers objectAtIndex:0] isEqualToString:@"Team History"]) {
        return DB_ERROR;
    }
    teamNumber = [NSNumber numberWithInt:[[data objectAtIndex: 0] intValue]];
    team = [self getTeam:teamNumber];
    
    // Team doesn't exist, return error
    if (!team) return DB_ERROR;

    // NSLog(@"Team History for %@", teamNumber);
    NSString *week = [data objectAtIndex:1];

    // Week is not the first field after team number or is blank, return error
    if (!week || [week isEqualToString:@""]) return DB_ERROR;
        
    NSNumber *weekNumber = [NSNumber numberWithInt:[[data objectAtIndex: 1] intValue]];

    // Check to see if this regional data already exists in the db
    if ([self getRegionalRecord:team forWeek:weekNumber]) return DB_MATCHED;
    
    // Create the regional record and add the data to it.
    Regional *regionalRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Regional"
                                         inManagedObjectContext:_dataManager.managedObjectContext];
    // NSLog(@"Adding week = %@", weekNumber);
    regionalRecord.reg1 = [NSNumber numberWithInt:[weekNumber intValue]];
    for (int i=2; i<[data count]; i++) {
        [self setRegionalValue:regionalRecord forHeader:[headers objectAtIndex:i] withValue:[data objectAtIndex:i]];
    }
    // NSLog(@"Regional = %@", regionalRecord);

    [team addRegionalObject:regionalRecord];

    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        results = DB_ERROR;
    }

    return results;
}

-(void)setRegionalValue:(Regional *)regional forHeader:(NSString *)header withValue:(NSString *)data {
    NSNumber *type;
    if ([header isEqualToString:@"CCWM"]) type =[_regionalDictionary objectForKey:@"reg3"];
    else if ([header isEqualToString:@"awards"]) type =[_regionalDictionary objectForKey:@"reg5"];
    else type =[_regionalDictionary objectForKey:header];

    // NSLog (@"Key = %@, Type = %@, Value = %@", header, type, data);
    switch ([type intValue]) {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
            [regional setValue:[NSNumber numberWithInt:[data intValue]] forKey:header];
            break;
        case NSFloatAttributeType:
        case NSDoubleAttributeType:
        case NSDecimalAttributeType:
            // Store the CCWM in reg3
            if ([header isEqualToString:@"CCWM"]) {
                [regional setValue:[NSNumber numberWithFloat:[data floatValue]] forKey:@"reg3"];
            }
            else {
                [regional setValue:[NSNumber numberWithFloat:[data floatValue]] forKey:header];
            }
            break;
        case NSStringAttributeType:
            // Store the Awards in reg5
            if ([header isEqualToString:@"awards"]) {
                [regional setValue:data forKey:@"reg5"];
            }
            else {
                [regional setValue:data forKey:header];
            }
            break;
        case NSBooleanAttributeType:
            [regional setValue:[NSNumber numberWithInt:[data intValue]] forKey:header];
            break;
         default: break;
    }
}

-(Regional *)getRegionalRecord:(TeamData *)team forWeek:(NSNumber *)week {
    NSArray *regionalList = [team.regional allObjects];
    // Store the week in reg1 because I forgot to add a week spot in the database
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"reg1 = %@", week];
    NSArray *list = [regionalList filteredArrayUsingPredicate:pred];
    
    if ([list count]) return [list objectAtIndex:0];
    else return Nil;
}


-(void)createTeamDataCollection {
    // NSLog(@"createTeamDataCollection");
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
	[_dataManager.managedObjectContext deleteObject:team];
}

-(void)createRegionalCollection {
    // NSLog(@"createRegionalCollection");
    _regionalDictionary = [[NSMutableDictionary alloc] init];
    Regional *regional = [NSEntityDescription insertNewObjectForEntityForName:@"Regional"
                                                   inManagedObjectContext:_dataManager.managedObjectContext];
    // NSLog(@"team data = %@", team);
    NSDictionary *attributes = [[regional entity] attributesByName];
    for (NSAttributeDescription *regionalProperties in [[regional entity] properties]) {
        if ([attributes objectForKey:regionalProperties.name]) {
            // NSLog(@"name = %@, type = %d", teamProperties.name, teamProperties.attributeType);
            [_regionalDictionary setObject:[NSNumber numberWithInt:regionalProperties.attributeType] forKey:regionalProperties.name];
        }
    }
    // NSLog(@"Regional Dictionary = %@", _regionalDictionary);
	[_dataManager.managedObjectContext deleteObject:regional];
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

- (void)dealloc
{
    _dataManager = nil;
    _teamDataDictionary = nil;
    _regionalDictionary = nil;
#ifdef TEST_MODE
	NSLog(@"dealloc %@", self);

#endif
}

#ifdef TEST_MODE
-(void)testTeamInterfaces {
    NSLog(@"Testing Team Interfaces");
    NSError *error;
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    NSLog(@"Total Teams = %d", [teamData count]);
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"driveTrainType" ascending:YES];
    teamData = [teamData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
    
    int prev_int = -99;
    BOOL firstTime = TRUE;
    int counter = 0;
    for (int i=0; i<[teamData count]; i++) {
        int driveType = [[[teamData objectAtIndex:i] valueForKey:@"driveTrainType"] intValue];
        // NSLog(@"%d\t%d", i+1, driveType);
        if (driveType == prev_int) {
            counter++;
        }
        else {
            if (!firstTime) {
                NSLog(@"%d\tDrive Type = %d", counter, prev_int);
            }
            firstTime = FALSE;
            counter = 1;
            prev_int = driveType;
        }
    }
    NSLog(@"%d\tDrive Type = %d", counter, prev_int);

    sorter = [NSSortDescriptor sortDescriptorWithKey:@"intake" ascending:YES];
    teamData = [teamData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
    prev_int = -99;
    firstTime = TRUE;
    for (int i=0; i<[teamData count]; i++) {
        int intake = [[[teamData objectAtIndex:i] valueForKey:@"intake"] intValue];
        // NSLog(@"%d\t%d", i+1, intake);
        if (intake == prev_int) {
            counter++;
        }
        else {
            if (!firstTime) {
                NSLog(@"%d\tIntake Type = %d", counter, prev_int);
            }
            firstTime = FALSE;
            counter = 1;
            prev_int = intake;
        }
    }
    NSLog(@"%d\tIntake Type = %d", counter, prev_int);

    NSFetchRequest *fetchRegionals = [[NSFetchRequest alloc] init];
    NSEntityDescription *regionalEntity = [NSEntityDescription
                                             entityForName:@"Regional" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRegionals setEntity:regionalEntity];
    NSArray *regionalData = [_dataManager.managedObjectContext executeFetchRequest:fetchRegionals error:&error];
    if (regionalData) NSLog(@"History records = %d", [regionalData count]);
    else NSLog(@"History records = 0");

    NSFetchRequest *fetchTournaments = [[NSFetchRequest alloc] init];
    NSEntityDescription *tournamentEntity = [NSEntityDescription
                                   entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchTournaments setEntity:tournamentEntity];
    NSArray *tournamentData = [_dataManager.managedObjectContext executeFetchRequest:fetchTournaments error:&error];
    
    if (tournamentData) {
        NSLog(@"Total Tournaments = %d", [tournamentData count]);
        for (int i=0; i<[tournamentData count]; i++) {
            NSString *tournament = [[tournamentData objectAtIndex:i] valueForKey:@"name"];
            entity = [NSEntityDescription entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
            [fetchRequest setEntity:entity];
            // Add the search for tournament name
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournament.name = %@",  tournament];
            [fetchRequest setPredicate:pred];
            teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (teamData) NSLog(@"Teams in tournament %@ = %d", tournament, [teamData count]);
            else NSLog(@"Teams in tournament %@ = 0", tournament);
        }
    }
    else {
        NSLog(@"Total Tournaments = 0");
    }
    
}
#endif


@end
