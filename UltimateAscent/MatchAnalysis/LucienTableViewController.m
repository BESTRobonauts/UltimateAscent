//
//  LucienTableViewController.m
//  UltimateAscent
//
//  Created by FRC on 7/13/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "LucienTableViewController.h"
#import "LucienNumberObject.h"

@interface LucienTableViewController ()

@end

@implementation LucienTableViewController
@synthesize lucienNumbers = _lucienNumbers;
@synthesize headerView = _headerView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"lucienNumber" ascending:NO];
    [_lucienNumbers sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
 
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,50)];
    _headerView.backgroundColor = [UIColor lightGrayColor];
    _headerView.opaque = YES;
    
	UILabel *teamLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 50)];
	teamLabel.text = @"Team";
    teamLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:teamLabel];
    
	UILabel *lucienNumber = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 200, 50)];
	lucienNumber.text = @"Lucien";
    lucienNumber.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:lucienNumber];

	UILabel *aveAutonLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 200, 50)];
	aveAutonLabel.text = @"Auton";
    aveAutonLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:aveAutonLabel];
    
 	UILabel *aveTeleopLabel = [[UILabel alloc] initWithFrame:CGRectMake(290, 0, 200, 50)];
	aveTeleopLabel.text = @"TeleOp";
    aveTeleopLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:aveTeleopLabel];
    
	UILabel *aveHangLabel = [[UILabel alloc] initWithFrame:CGRectMake(380, 0, 200, 50)];
	aveHangLabel.text = @"Hang";
    aveHangLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:aveHangLabel];
    
	UILabel *speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(470, 0, 200, 50)];
	speedLabel.text = @"Speed";
    speedLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:speedLabel];
    
    UILabel *driveLabel = [[UILabel alloc] initWithFrame:CGRectMake(560, 0, 200, 50)];
	driveLabel.text = @"Drive";
    driveLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:driveLabel];
    
    UILabel *defenseLabel = [[UILabel alloc] initWithFrame:CGRectMake(650, 0, 200, 50)];
	defenseLabel.text = @"Defense";
    defenseLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:defenseLabel];
    
    UILabel *minHeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(770, 0, 200, 50)];
	minHeightLabel.text = @"Min Height";
    minHeightLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:minHeightLabel];
    
    UILabel *maxHeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(900, 0, 200, 50)];
	maxHeightLabel.text = @"Max Height";
    maxHeightLabel.backgroundColor = [UIColor clearColor];
    [_headerView addSubview:maxHeightLabel];

    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_lucienNumbers count];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    LucienNumberObject *info = [_lucienNumbers objectAtIndex:indexPath.row];
    // NSLog(@"name = %@", info.name);
    // Configure the cell...
    // Set a background for the cell
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
//    UIImage *image = [UIImage imageNamed:@"Blue Fade.gif"];
//    imageView.image = image;
//    cell.backgroundView = imageView;
    
	UILabel *numberLabel = (UILabel *)[cell viewWithTag:10];
	numberLabel.text = [NSString stringWithFormat:@"%d", info.teamNumber];
 
	UILabel *lucienLabel = (UILabel *)[cell viewWithTag:20];
	lucienLabel.text = [NSString stringWithFormat:@"%.1f", info.lucienNumber];
    
	UILabel *autonLabel = (UILabel *)[cell viewWithTag:30];
	autonLabel.text = [NSString stringWithFormat:@"%.1f", info.autonNumber];

	UILabel *teleOpLabel = (UILabel *)[cell viewWithTag:40];
	teleOpLabel.text = [NSString stringWithFormat:@"%.1f", info.teleOpNumber];
    
	UILabel *hangLabel = (UILabel *)[cell viewWithTag:50];
	hangLabel.text = [NSString stringWithFormat:@"%.1f", info.hangingNumber];
    
	UILabel *speedLabel = (UILabel *)[cell viewWithTag:60];
	speedLabel.text = [NSString stringWithFormat:@"%.1f", info.speedNumber];
    
    UILabel *driveLabel = (UILabel *)[cell viewWithTag:70];
    driveLabel.text = [NSString stringWithFormat:@"%.1f", info.drivingNumber];
     
    UILabel *defenseLabel = (UILabel *)[cell viewWithTag:80];
	defenseLabel.text = [NSString stringWithFormat:@"%.1f", info.defenseNumber];
    
    UILabel *height1Label = (UILabel *)[cell viewWithTag:90];
    height1Label.text = [NSString stringWithFormat:@"%.1f", info.height1Number];
    
    UILabel *height2Label = (UILabel *)[cell viewWithTag:100];
    height2Label.text = [NSString stringWithFormat:@"%.1f", info.height1Number];
                       
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 	UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"LucienList"];
    // NSLog(@"IndexPath =%@", indexPath);
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

@end
