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

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(TeamData *)addTeam:(NSNumber *)teamNumber forName:(NSString *)teamName forTournament:(NSString *)tournamentName {
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    // Check to make sure tournament exists, if not, error out
    TournamentData *tournamentRecord = [[[CreateTournament alloc] initWithDataManager:_dataManager] GetTournament:tournamentName];
    if (!tournamentRecord) {
        NSString *msg = [NSString stringWithFormat:@"Tournament %@ does not exist", tournamentName];
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Team Add Alert"
                                                          message:msg
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
        return nil;
    }
    
    TeamData *teamRecord = [self getTeam:teamNumber];
    if (teamRecord) {
        // If team already exists, add it to the tournament
        NSArray *allTournaments = [teamRecord.tournament allObjects];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", tournamentRecord.name];
        NSArray *list = [allTournaments filteredArrayUsingPredicate:pred];
        if (![list count]) {
             NSLog(@"Adding Tournament");
            [teamRecord addTournamentObject:tournamentRecord];
        }
        else {
            NSLog(@"Tournament Exists, count = %d", [list count]);
            NSLog(@"Add Team %@ already exists", teamNumber);
            NSString *msg = [NSString stringWithFormat:@"%@ already exists in this tournament", teamNumber];
            UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Team Add Alert"
                                                              message:msg
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
            [prompt setAlertViewStyle:UIAlertViewStyleDefault];
            [prompt show];
            teamRecord = nil;
        }

        return teamRecord;
    }
    else {
        // If team does not exist, add it and add it to the tournament
        teamRecord = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData"
                                             inManagedObjectContext:_dataManager.managedObjectContext];
        [self setTeamDefaults:teamRecord];
        [teamRecord setValue:teamNumber forKey:@"number"];
        [teamRecord setValue:teamName forKey:@"name"];
        [teamRecord addTournamentObject:tournamentRecord];
        return teamRecord;
    }
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
    NSDictionary *properties = [[team entity] propertiesByName];
    for (int i=1; i<[data count]; i++) {
        [self setTeamValue:team forHeader:[headers objectAtIndex:i] withValue:[data objectAtIndex:i] withProperties:properties];
    }
    //    NSLog(@"Team = %@", team);
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        results = DB_ERROR;
    }
    return results;
}

-(void)setTeamValue:(TeamData *)team forHeader:header withValue:data withProperties:(NSDictionary *)properties {

    id value = [properties valueForKey:header];
    if (!value) {
        value = [self checkAlternateKeys:properties forEntry:header];
    }
    if ([value isKindOfClass:[NSRelationshipDescription class]]) {
        NSRelationshipDescription *destination = [value inverseRelationship];
        if ([destination.entity.name isEqualToString:@"TournamentData"]) {
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
                    // NSLog(@"Team before T add = %@", team);
                    [team addTournamentObject:tournamentRecord];
                    // NSLog(@"Team after T add = %@", team);
                }
                else {
                    // NSLog(@"Tournament Exists, count = %d", [list count]);
                }
            }
        }
    }
    else if ([value isKindOfClass:[NSAttributeDescription class]]) {
        [self setAttributeValue:team forValue:data forAttribute:value];
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
    NSDictionary *attributes = [[regionalRecord entity] attributesByName];
    for (int i=2; i<[data count]; i++) {
        [self setRegionalValue:regionalRecord forHeader:[headers objectAtIndex:i] withValue:[data objectAtIndex:i] withProperties:attributes];
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

-(void)setRegionalValue:(Regional *)regional forHeader:(NSString *)header withValue:(NSString *)data withProperties:(NSDictionary *)properties {

    id value = [properties valueForKey:header];
    if (!value) {
        value = [self checkAlternateKeys:properties forEntry:header];
    }

    [self setAttributeValue:regional forValue:data forAttribute:value];
}

-(id)checkAlternateKeys:(NSDictionary *)keyList forEntry:header {
    for (NSString *item in keyList) {
        if( [item caseInsensitiveCompare:header] == NSOrderedSame ) {
            return [keyList valueForKey:item];
        }
        NSString *list = [[[keyList objectForKey:item] userInfo] objectForKey:@"key"];
        NSArray *allKeys = [list componentsSeparatedByString:@", "];
        for (int i=0; i<[allKeys count]; i++) {
            if( [[allKeys objectAtIndex:i] caseInsensitiveCompare:header] == NSOrderedSame ) {
                return [keyList valueForKey:item];
            }
        }
    }
    return NULL;
}

-(void)setAttributeValue:record forValue:data forAttribute:(id) attribute {
    NSAttributeType attributeType = [attribute attributeType];
    if (attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType) {
        [record setValue:[NSNumber numberWithInt:[data intValue]] forKey:[attribute name]];
    }
    else if (attributeType == NSFloatAttributeType || attributeType == NSDoubleAttributeType || attributeType == NSDecimalAttributeType) {
        [record setValue:[NSNumber numberWithFloat:[data floatValue]] forKey:[attribute name]];
    }
    else if (attributeType == NSBooleanAttributeType) {
        [record setValue:[NSNumber numberWithInt:[data intValue]] forKey:[attribute name]];
    }
    else if (attributeType == NSStringAttributeType) {
        [record setValue:data forKey:[attribute name]];
    }
}

-(NSString *) exportTeamsToCSV:(NSString *)tournament {
    NSLog(@"Export teams to csv");
    TeamData *team;
    NSError *error;
    NSString *csvString;
    NSString *csvTournament;
    NSString *csvRegionals;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    NSEntityDescription *entity = [NSEntityDescription
    entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
     
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    if (tournament) {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournament.name = %@", tournament];
        [fetchRequest setPredicate:pred];
    }
     NSArray *teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
     if(!teamData) {
         NSLog(@"Karma disruption error");
     }
     else {
         csvString = @"";
         BOOL firstPass = TRUE;
         if ([teamData count]) {
             NSDictionary *properties = [[[teamData objectAtIndex:0] entity] attributesByName];
             for (NSString *key in properties) {
                 if (!firstPass) {
                     csvString = [csvString stringByAppendingString:@", "];
                 }
                 csvString = [csvString stringByAppendingFormat:@"%@", key];
                 firstPass = FALSE;
             }
             csvString = [csvString stringByAppendingFormat:@"\n"];
             csvTournament = @"Team Number, tournament\n";
             csvRegionals = @"Team History, week, name, rank, seedingRecord, CCWM, opr, finishPosition, awards\n";
//             csvRegionals =
             for (int c = 0; c < [teamData count]; c++) {
                 team = [teamData objectAtIndex:c];
                 NSLog(@"index = %d", c);
                 /************************************************************/
                 NSArray *allTournaments = [team.tournament allObjects];
                 for (int j=0; j<[allTournaments count]; j++) {
                     TournamentData *tourney = [allTournaments objectAtIndex:j];
                     csvTournament = [csvTournament stringByAppendingFormat:@"%@, %@\n", team.number, tourney.name];
                 }
                 NSArray *allRegionals = [team.regional allObjects];
                 for (int j=0; j<[allRegionals count]; j++) {
                     Regional *regional = [allRegionals objectAtIndex:j];
                     csvRegionals = [csvRegionals stringByAppendingFormat:@"%@, %@, %@, %@, %@, %@, %@, \"%@\", \"%@\"\n", team.number, regional.reg1, regional.name, regional.rank, regional.seedingRecord, regional.reg3, regional.opr, regional.finishPosition, regional.reg5];
                 }
                 /************************************************************/
                 firstPass = TRUE;
                 for (NSString *key in properties) {
                     id description = [properties valueForKey:key];
                     if ([description isKindOfClass:[NSAttributeDescription class]]) {
                         if (!firstPass) {
                             csvString = [csvString stringByAppendingString:@", "];
                         }
                         firstPass = FALSE;
                         NSAttributeType attributeType = [description attributeType];
                         switch (attributeType) {
                             case NSInteger16AttributeType:
                             case NSInteger32AttributeType:
                             case NSInteger64AttributeType: {
                                 NSNumber *value = [team valueForKey:key];
                                 if (value) {
                                     csvString = [csvString stringByAppendingFormat:@"%@", value];
                                 }
                             }
                             break;
                             case NSFloatAttributeType:
                             case NSDoubleAttributeType:
                             case NSDecimalAttributeType: {
                                 NSNumber *value = [team valueForKey:key];
                                 if (value) {
                                     csvString = [csvString stringByAppendingFormat:@"%@", value];
                                 }
                             }
                             break;
                             case NSBooleanAttributeType: {
                                 NSNumber *value = [team valueForKey:key];
                                 if (value) {
                                     csvString = [csvString stringByAppendingFormat:@"%@", value];
                                 }
                             }
                             break;
                             case NSStringAttributeType: {
                                 NSString *value = [team valueForKey:key];
                                 if (value) {
                                     csvString = [csvString stringByAppendingFormat:@"\"%@\"", value];
                                 }
                             }
                             break;
                             default:
                                 break;
                         }
                     }
                 }
                 csvString = [csvString stringByAppendingFormat:@"\n"];
             }
         }
             //else if ([value isKindOfClass:[NSAttributeDescription class]]) {
//     csvString = [csvString stringByAppendingFormat:@"%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@ %@\n", team.number, team.name, settings.tournament.name, team.driveTrainType, team.intake, team.wheelDiameter, team.cims, team.minHeight, team.maxHeight, team.pyramidDump, team.climbLevel, team.climbSpeed, team.wheelType, ([team.notes isEqualToString:@""] ? @"," : [NSString stringWithFormat:@",\"%@\"", team.notes])];
    }
    csvString = [csvString stringByAppendingString:csvTournament];
    csvString = [csvString stringByAppendingString:csvRegionals];
    return csvString;
}

-(Regional *)getRegionalRecord:(TeamData *)team forWeek:(NSNumber *)week {
    NSArray *regionalList = [team.regional allObjects];
    // Store the week in reg1 because I forgot to add a week spot in the database
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"reg1 = %@", week];
    NSArray *list = [regionalList filteredArrayUsingPredicate:pred];
    
    if ([list count]) return [list objectAtIndex:0];
    else return Nil;
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
