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
 
    }
    return self;
}

- (void)viewDidLoad
{
   [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    //Calculate how tall the view should be by multiplying the individual row height
    //by the total number of rows.
    NSInteger rowsCount = [_pickerChoices count];
    NSInteger singleRowHeight = [self.tableView.delegate tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSInteger totalRowsHeight = rowsCount * singleRowHeight;
    //Calculate how wide the view should be by finding how wide each string is expected to be
    CGFloat largestLabelWidth = 0;
    for (NSString *colorName in _pickerChoices) {
        //Checks size of text using the default font for UITableViewCell's textLabel.
        CGSize labelSize = [colorName sizeWithFont:[UIFont boldSystemFontOfSize:20.0f]];
        if (labelSize.width > largestLabelWidth) {
            largestLabelWidth = labelSize.width;
        }
    }
    
    //Add a little padding to the width
    CGFloat popoverWidth = largestLabelWidth + 100;
    
    //Set the property to tell the popover container how big this view will be.
    self.contentSizeForViewInPopover = CGSizeMake(popoverWidth, totalRowsHeight);}

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
