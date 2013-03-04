//
//  TournamentPickerController.m
//  UltimateAscent
//
//  Created by FRC on 2/28/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "TournamentPickerController.h"

@interface TournamentPickerController ()

@end

@implementation TournamentPickerController
@synthesize tournamentChoices;
@synthesize delegate;

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
    CGFloat height;
    [super viewDidLoad];
    height = [tournamentChoices count] * 44;
    self.clearsSelectionOnViewWillAppear = YES;
    self.contentSizeForViewInPopover = CGSizeMake(250.0, height);
 }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [tournamentChoices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSString *tournament = [tournamentChoices objectAtIndex:indexPath.row];
    cell.textLabel.text = tournament;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (delegate != nil) {
        NSString *newTournament = [tournamentChoices objectAtIndex:indexPath.row];
        [delegate tournamentSelected:newTournament];
    }

}

@end
