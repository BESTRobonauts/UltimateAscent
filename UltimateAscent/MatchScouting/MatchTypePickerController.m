//
//  MatchTypePickerController.m
//  ReboundRumble
//
//  Created by Kris Pettinger on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MatchTypePickerController.h"

@implementation MatchTypePickerController
@synthesize matchTypeChoices;
@synthesize delegate;
@synthesize senderID = _senderID;

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
    CGFloat height;
   [super viewDidLoad];

    height = [matchTypeChoices count] * 44;
    self.clearsSelectionOnViewWillAppear = YES;
    self.contentSizeForViewInPopover = CGSizeMake(150.0, height);
}

- (void)viewDidUnload
{
    [self setMatchTypeChoices:nil];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"Match Types Popper = %@", matchTypeChoices);
    return [matchTypeChoices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSString *matchType = [matchTypeChoices objectAtIndex:indexPath.row];
    cell.textLabel.text = matchType;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (delegate != nil) {
        NSString *newMatchType= [matchTypeChoices objectAtIndex:indexPath.row];
        [delegate matchTypeSelected:newMatchType];
    }

    if ([_senderID isEqual: @"addMatch"]) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"cellSelected" object:nil userInfo:[NSDictionary dictionaryWithObject:[matchTypeChoices objectAtIndex:indexPath.row] forKey:@"selectedChoice"]]];
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
    }
}

@end
