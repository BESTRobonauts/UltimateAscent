//
//  AlertPromptViewController.m
//  FieldDrawing
//
//  Created by FRC on 2/18/13.
//  Copyright (c) 2013 Kris. All rights reserved.
//

#import "AlertPromptViewController.h"

@interface AlertPromptViewController ()

@end

@implementation AlertPromptViewController
@synthesize delegate;
@synthesize titleText;
@synthesize msgText;

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // NSLog(@"viewdidLoad");
   
}

- (void) viewWillAppear:(BOOL)animated
{
    // NSLog(@"viewWillAppear");
    UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:titleText
                                                      message:msgText
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Enter", nil];
    
    [prompt setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    [prompt show];    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) { // Enter
        UITextField *textEntered = [alertView textFieldAtIndex:0];    
        [delegate passCodeResult:textEntered.text];
    }
    else {
        [delegate passCodeResult:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
