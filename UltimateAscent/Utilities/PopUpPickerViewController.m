//
//  PopUpPickerViewController.m
//  UltimateAscent
//
//  Created by FRC on 4/7/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "PopUpPickerViewController.h"

@interface PopUpPickerViewController ()

@end

@implementation PopUpPickerViewController
@synthesize pickerChoices = _pickerChoices;
@synthesize delegate = _delegate;


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

    height = [_pickerChoices count] * 44;
    self.clearsSelectionOnViewWillAppear = YES;
    self.contentSizeForViewInPopover = CGSizeMake(150.0, height);
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_pickerChoices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSString *picker = [_pickerChoices objectAtIndex:indexPath.row];
    cell.textLabel.text = picker;
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate != nil) {
        NSString *newChoice = [_pickerChoices objectAtIndex:indexPath.row];
        [_delegate pickerSelected:newChoice];
    }
}

@end
