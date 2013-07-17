//
//  ValuePromptViewController.m
//  UltimateAscent
//
//  Created by FRC on 7/7/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "ValuePromptViewController.h"

@interface ValuePromptViewController ()

@end

@implementation ValuePromptViewController
@synthesize delegate = _delegate;
@synthesize titleText = _titleText;
@synthesize msgText = _msgText;

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
    self.contentSizeForViewInPopover = CGSizeMake(9.0, 7.0);
    UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:_titleText
                                                      message:_msgText
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Enter", nil];
    
    [prompt setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [prompt show];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) { // Enter
        UITextField *textEntered = [alertView textFieldAtIndex:0];
        [_delegate valueEnteredAtPrompt:textEntered.text];
    }
    else {
        [_delegate valueEnteredAtPrompt:nil];
    }
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
