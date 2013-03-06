//
//  AddMatchViewController.m
//  UltimateAscent
//
//  Created by FRC on 2/25/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "AddMatchViewController.h"
#import "MatchTypePickerController.h"
#import "MatchTypeDictionary.h"

@implementation AddMatchViewController {
    NSMutableArray *newMatch;
}

@synthesize popover = _popover;
@synthesize delegate;
@synthesize matchNumber;
@synthesize red1;
@synthesize red2;
@synthesize red3;
@synthesize blue1;
@synthesize blue2;
@synthesize blue3;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameTypeSelected:) name:@"cellSelected" object:nil];
    newMatch = [[NSMutableArray alloc] initWithObjects:@"", @"", @"", @"Red 2", @"Red 3", @"Blue 1", @"Blue 2", @"Blue 3", nil];
}

- (void)viewDidUnload
{
    [self setMatchTypeButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (IBAction)cancelVC:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)addAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"Adding match");
    NSLog(@"match = %@", newMatch);
    if (delegate == nil) NSLog(@"no delegate");
    [delegate matchAdded:newMatch];
}

- (void)gameTypeSelected:(NSNotification *)notification {
    NSLog(@"Object in dictionary: %@", [[notification userInfo] objectForKey:@"selectedChoice"]);
    if ([_popover isPopoverVisible]) {
        [_popover dismissPopoverAnimated:YES];
    }
    
    NSString *passedString = [[notification userInfo] objectForKey:@"selectedChoice"];
    if ([passedString isEqualToString:@"Practice"]) {
            gameType = kMatchTypePractice;
        } else if ([passedString isEqualToString:@"Seeding"]) {
            gameType = kMatchTypeSeeding;
        } else if ([passedString isEqualToString:@"Elimination"]) {
            gameType = kMatchTypeElimination;
        } else if ([passedString isEqualToString:@"Testing"]) {
            gameType = kMatchTypeTesting;
        } else if ([passedString isEqualToString:@"Other"]) {
            gameType = kMatchTypeOther;
        }
    _matchTypeButton.titleLabel.text = passedString;
    [newMatch replaceObjectAtIndex:1 withObject:passedString];
}

- (IBAction)showPopup:(id)sender {

    MatchTypePickerController *pickerTable = [[MatchTypePickerController alloc] initWithStyle:UITableViewStylePlain];
    pickerTable.senderID = @"addMatch";
    MatchTypeDictionary *dict = [[MatchTypeDictionary alloc] init];
    NSMutableArray *types = [[dict getMatchTypes] copy];
    [pickerTable setMatchTypeChoices:types];
    _popover = [[UIPopoverController alloc] initWithContentViewController:pickerTable];
    [_popover setDelegate:self];
    [_popover setPopoverContentSize:[pickerTable contentSizeForViewInPopover]];
    [_popover presentPopoverFromRect:CGRectMake(213, 90, 100, 145) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}

#pragma mark -
#pragma mark Text

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"team should end editing");
    if (textField == matchNumber) {
        [newMatch replaceObjectAtIndex:0
                            withObject:matchNumber.text];
	}
	else if (textField == red1) {
        [newMatch replaceObjectAtIndex:2
                            withObject:red1.text];	}
	else if (textField == red2) {
        [newMatch replaceObjectAtIndex:3
                            withObject:red2.text];	}
	else if (textField == red3) {
        [newMatch replaceObjectAtIndex:4
                            withObject:red3.text];	}
	else if (textField == blue1) {
        [newMatch replaceObjectAtIndex:5
                            withObject:blue1.text];	}
	else if (textField == blue2) {
        [newMatch replaceObjectAtIndex:6
                            withObject:blue2.text];	}
	else if (textField == blue3) {
        [newMatch replaceObjectAtIndex:7
                            withObject:blue3.text];	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Row at index %i selected", indexPath.row);
}
@end
