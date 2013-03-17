//
//  MatchListViewController.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MatchListViewController.h"
#import "MatchDetailViewController.h"
#import "MatchData.h"
#import "CreateMatch.h"
#import "TeamData.h"
#import "TeamScore.h"
#import "DataManager.h"
#import "SettingsData.h"
#import "TournamentData.h"
#include "MatchTypeDictionary.h"

@implementation MatchListViewController {
    NSIndexPath *pushedIndexPath;
}
@synthesize managedObjectContext, fetchedResultsController;
@synthesize settings;
@synthesize headerView;
@synthesize teamData;
@synthesize teamOrder;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    NSError *error = nil;
    if (!managedObjectContext) {
        DataManager *dataManager = [DataManager new];
        managedObjectContext = [dataManager managedObjectContext];
    }
    [self retrieveSettings];
    if (settings) {
        self.title =  [NSString stringWithFormat:@"%@ Match List", settings.tournament.name];
    }
    else {
        self.title = @"Match List";
    }
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         abort() causes the application to generate a crash log and terminate. 
         You should not use this function in a shipping application, 
         although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
        
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    headerView.opaque = YES;

 	UILabel *matchLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 200, 50)];
	matchLabel.text = @"Match";
    matchLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:matchLabel];

 	UILabel *matchTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(82, 0, 200, 50)];
	matchTypeLabel.text = @"Type";
    matchTypeLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:matchTypeLabel];

 	UILabel *red1Label = [[UILabel alloc] initWithFrame:CGRectMake(145, 0, 200, 50)];
	red1Label.text = @"Red 1";
    red1Label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:red1Label];

    UILabel *red2Label = [[UILabel alloc] initWithFrame:CGRectMake(216, 0, 200, 50)];
	red2Label.text = @"Red 2";
    red2Label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:red2Label];

    UILabel *red3Label = [[UILabel alloc] initWithFrame:CGRectMake(286, 0, 200, 50)];
	red3Label.text = @"Red 3";
    red3Label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:red3Label];

    UILabel *blue1Label = [[UILabel alloc] initWithFrame:CGRectMake(393, 0, 200, 50)];
	blue1Label.text = @"Blue 1";
    blue1Label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:blue1Label];
    
    UILabel *blue2Label = [[UILabel alloc] initWithFrame:CGRectMake(466, 0, 200, 50)];
	blue2Label.text = @"Blue 2";
    blue2Label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:blue2Label];
    
    UILabel *blue3Label = [[UILabel alloc] initWithFrame:CGRectMake(537, 0, 200, 50)];
	blue3Label.text = @"Blue 3";
    blue3Label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:blue3Label];

    UILabel *redLabel = [[UILabel alloc] initWithFrame:CGRectMake(643, 0, 200, 50)];
	redLabel.text = @"Red";
    redLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:redLabel];

    UILabel *blueLabel = [[UILabel alloc] initWithFrame:CGRectMake(711, 0, 200, 50)];
	blueLabel.text = @"Blue";
    blueLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:blueLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void)setTeamList:(MatchData *)match {
    TeamScore *score;
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"alliance" ascending:YES];
    teamData = [[match.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];

    if (teamOrder == nil) {
        teamOrder = [NSMutableArray array];
        // Reds
        for (int i = 3; i < 6; i++) {
            score = [teamData objectAtIndex:i];
            [teamOrder addObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        // Blues
        for (int i = 0; i < 3; i++) {
            score = [teamData objectAtIndex:i];
            [teamOrder addObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        
    }
    else {
        // Reds
        for (int i = 3; i < 6; i++) {
            score = [teamData objectAtIndex:i];
            [teamOrder replaceObjectAtIndex:(i-3)
                                withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        // Blues
        for (int i = 0; i < 3; i++) {
            score = [teamData objectAtIndex:i];
            [teamOrder replaceObjectAtIndex:(i+3)
                                withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
    }
}

- (void)matchAdded:(NSMutableArray *)newMatch {
    NSLog(@"matchAdded");
    // Data map
    // newMatch[0] = Match Number
    // newMatch[1] = Match Type
    // newMatch[2] = Red 1
    // newMatch[3] = Red 2
    // newMatch[4] = Red 3
    // newMatch[5] = Blue 1
    // newMatch[6] = Blue 2
    // newMatch[7] = Blue 3
    // Check to make sure a match number and type have been set
    NSString *matchNumberString = [newMatch objectAtIndex:0];
    NSString *matchType = [newMatch objectAtIndex:1];
    
    NSLog(@"number string = (%@)", matchNumberString);
    NSLog(@"type = (%@)", [newMatch objectAtIndex:1]);

    if ([matchNumberString isEqualToString:@""] || [matchType isEqualToString:@""]) {
        NSLog(@"blank match data");
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Match Add Alert"
                                                          message:@"You must have both a match number and type"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];        
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
        return;
    }
    NSNumber *matchNumber = [NSNumber numberWithInt:[matchNumberString intValue]];
    NSNumber *red1 = [NSNumber numberWithInt:[[newMatch objectAtIndex:2] intValue]];
    NSNumber *red2 = [NSNumber numberWithInt:[[newMatch objectAtIndex:3] intValue]];
    NSNumber *red3 = [NSNumber numberWithInt:[[newMatch objectAtIndex:4] intValue]];
    NSNumber *blue1 = [NSNumber numberWithInt:[[newMatch objectAtIndex:5] intValue]];
    NSNumber *blue2 = [NSNumber numberWithInt:[[newMatch objectAtIndex:6] intValue]];
    NSNumber *blue3 = [NSNumber numberWithInt:[[newMatch objectAtIndex:7] intValue]];
    CreateMatch *matchObject = [CreateMatch new];
    matchObject.managedObjectContext = managedObjectContext;
    MatchData *match = [matchObject AddMatchObjectWithValidate:matchNumber
                                              forTeam1:red1
                                              forTeam2:red2
                                              forTeam3:red3
                                              forTeam4:blue1
                                              forTeam5:blue2
                                              forTeam6:blue3
                                              forMatch:matchType
                                         forTournament:settings.tournament.name
                                           forRedScore:[NSNumber numberWithInt:-1]
                                          forBlueScore:[NSNumber numberWithInt:-1]];
    if (match) {
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
    }
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MatchDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        pushedIndexPath = [self.tableView indexPathForCell:sender];
        [segue.destinationViewController setMatch:[fetchedResultsController objectAtIndexPath:indexPath]];
        [segue.destinationViewController setManagedObjectContext:managedObjectContext];
        [segue.destinationViewController setDelegate:self];
    }
    if ([segue.identifier isEqualToString:@"Add"]) {
        NSLog(@"add");
        UINavigationController *nv = (UINavigationController *)[segue destinationViewController];
        AddMatchViewController *addvc = (AddMatchViewController *)nv.topViewController;
        addvc.delegate = self;
    }
 }

- (void)matchDetailReturned:(BOOL)dataChange {
    if (dataChange) {
        NSError *error;
        if (![managedObjectContext save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        [self configureCell:[self.tableView cellForRowAtIndexPath:pushedIndexPath] atIndexPath:pushedIndexPath];
    }
}


#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [[fetchedResultsController sections] count];    
	if (count == 0) {
		count = 1;
	}
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = 
    [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:0 inSection:section];
    MatchData *matchData = [fetchedResultsController objectAtIndexPath:matchIndex];
    
    return matchData.matchType;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    MatchData *info = [fetchedResultsController objectAtIndexPath:indexPath];
    // Configure the cell...
    // Set a background for the cell
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
    UIImage *image = [UIImage imageNamed:@"Gold Fade.gif"];
    imageView.image = image;
    cell.backgroundView = imageView;
    [self setTeamList:info];
    
	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", [info.number intValue]];
    
	UILabel *matchTypeLabel = (UILabel *)[cell viewWithTag:15];
    matchTypeLabel.text = [info.matchType substringToIndex:4];

	UILabel *red1Label = (UILabel *)[cell viewWithTag:20];
    red1Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:0] intValue]];

    UILabel *red2Label = (UILabel *)[cell viewWithTag:30];
    red2Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:1] intValue]];

	UILabel *red3Label = (UILabel *)[cell viewWithTag:40];
    red3Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:2] intValue]];

	UILabel *blue1Label = (UILabel *)[cell viewWithTag:50];
    blue1Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:3] intValue]];

	UILabel *blue2Label = (UILabel *)[cell viewWithTag:60];
    blue2Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:4] intValue]];

	UILabel *blue3Label = (UILabel *)[cell viewWithTag:70];
    blue3Label.text = [NSString stringWithFormat:@"%d", [[teamOrder objectAtIndex:5] intValue]];

	UILabel *redScoreLabel = (UILabel *)[cell viewWithTag:80];
    redScoreLabel.text = [NSString stringWithFormat:@"%d", [info.redScore intValue]];
	UILabel *blueScoreLabel = (UILabel *)[cell viewWithTag:90];
    blueScoreLabel.text = [NSString stringWithFormat:@"%d", [info.blueScore intValue]];
}    

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
	UITableViewCell *cell = [tableView 
                             dequeueReusableCellWithIdentifier:@"MatchList"];
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)retrieveSettings {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SettingsData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *settingsRecord = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!settingsRecord) {
        NSLog(@"Karma disruption error");
        settings = Nil;
    }
    else {
        if([settingsRecord count] == 0) {  // No Settings Exists
            NSLog(@"Karma disruption error");
            settings = Nil;
        }
        else {
            settings = [settingsRecord objectAtIndex:0];
        }
    }
}

#pragma mark -
#pragma mark Match List Management

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchData" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchTypeSection" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        // Add the search for tournament name
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournament CONTAINS %@", settings.tournament.name];
        [fetchRequest setPredicate:pred];
        [fetchRequest setFetchBatchSize:20];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = 
        [[NSFetchedResultsController alloc] 
         initWithFetchRequest:fetchRequest 
         managedObjectContext:managedObjectContext 
         sectionNameKeyPath:nil
         cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	return fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


@end
