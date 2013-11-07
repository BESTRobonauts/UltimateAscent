//
//  AddTeamViewController.m
//  UltimateAscent
//
//  Created by FRC on 10/14/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "AddTeamViewController.h"

@interface AddTeamViewController ()

@end

@implementation AddTeamViewController {
    NSNumber *teamNumber;
    NSString *teamName;
}

@synthesize teamNumberTextField = _teamNumberTextField;
@synthesize teamNameTextField = _teamNameTextField;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title =  @"Add Team";
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    teamName = nil;
    teamNumber = nil;
}

- (IBAction)cancelVC:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)addAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"Adding team %@", teamNumber);
    if (_delegate == nil) NSLog(@"no delegate");
    [_delegate teamAdded:teamNumber forName:teamName];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField != _teamNumberTextField)  return YES;

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
    if (textField == _teamNumberTextField) {
        teamNumber = [NSNumber numberWithInt:[_teamNumberTextField.text intValue]];
	}
	else if (textField == _teamNameTextField) {
        teamName = _teamNameTextField.text;
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
