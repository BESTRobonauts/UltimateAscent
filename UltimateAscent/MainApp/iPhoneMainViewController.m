//
//  iPhoneMainViewController.m
//  UltimateAscent
//
//  Created by FRC on 4/4/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "iPhoneMainViewController.h"
#import "iPhoneMatchXferViewController.h"

@interface iPhoneMainViewController ()

@end

@implementation iPhoneMainViewController {
    NSString *csvString;
}

@synthesize dataManager = _dataManager;
/*@synthesize viewWeb = _viewWeb;
@synthesize url = _url;
@synthesize urlTextField = _urlTextField;
 */

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"iPhone main");
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Receive"]) {
        [segue.destinationViewController setXfer_mode:0];
    }
    else {
        [segue.destinationViewController setXfer_mode:1];
    }
    [segue.destinationViewController setDataManager:_dataManager];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#ifdef JUNK
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"iPhone main");
    NSString *fullURL = @"http://www2.usfirst.org/2013comp/events/CASJ/ScheduleQual.html";
    _urlTextField.text = fullURL;
    _url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:_url];
    [_viewWeb loadRequest:requestObj];
}

-(void) extractMatchList:(NSArray *)allLines {
    char *p;
    char *q;
    char *r;
    char tourney[100];
    int seed = 1;
    char type[20];
    int i=0;
    int stage1=1, stage2=0;
    int n;
    int nlines = [allLines count];
    
    strcpy(type, "Seeding");
    csvString = @"Match, Red 1, Red 2, Red 3, Blue 1, Blue 2, Blue 3, Type, Tournament, Red Score, Blue Score\n";
    
    /* Search for the tournament */
    for (i=0; i<nlines; i++) {
        const char *line;
        line = [[allLines objectAtIndex:i] cStringUsingEncoding:NSUTF8StringEncoding];
        if (stage1) {
            p = strchr(line, '2');
            if (p && !strncmp(p, "2013", 4)) {
                q=p+5;
                if (q) {
                    r = strchr(q, '<');
                    if (r) {
                        *(r-1) = '\0';
                        strncpy(tourney, q, r-q);
                        NSLog(@"Tourney = %s\n", tourney);
                        stage1 = 0;
                        stage2 = 1;
                        continue;
                    } /* if r */
                } /* if q */
            } // if p
        }
        else if (stage2) {
            if (seed == 1) {
                p = strchr(line, 'E');
                if (p && !strncmp(p, "Elimination", 11)) {
                    seed = 0;
                    strcpy(type, "Elimination");
                } // if p
            } // if seed
            if (strncmp(line, "<TR", 3)) continue;
            int j = i+2;
            n = 0;
            while (j<nlines) {
                line = [[allLines objectAtIndex:j] cStringUsingEncoding:NSUTF8StringEncoding];
                j++, i++;
                if (!strncmp(line, "</TR", 3)) {
                    break;
                }
                q = strchr(line, '>');
                if (q) {
                    r = strchr(q, '<');
                    if (r) {
                        *r = '\0';
                        csvString = [csvString stringByAppendingFormat:@"%s, ", q+1];
                        //                 if (n==8) printf("%s, %s, %s, -1, -1\n", q+1, type, tourney);
                        //                 else printf("%s,", q+1);
                    } /* if r */
                } /* if q */
                n++;
            }
            csvString = [csvString stringByAppendingFormat:@"%s, %s, -1, -1\n", type, tourney];
        }
    }
    NSLog(@"Match List\n%@", csvString);
}

- (IBAction)getMatchList:(id)sender {
    NSError *error;
    NSURL *currentURL;
    
    NSString *currentUrlString = _viewWeb.request.mainDocumentURL.absoluteString;
    if ([currentUrlString isEqualToString:_url.absoluteString]) {
        currentURL = _url;
    }
    else {
        currentURL = [NSURL URLWithString:currentUrlString];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:currentURL];
        [_viewWeb loadRequest:requestObj];
    }
    NSString *html = [NSString stringWithContentsOfURL:currentURL encoding:NSASCIIStringEncoding error:&error];
    NSArray *line = [html componentsSeparatedByString:@"\n"];
    
    [self extractMatchList:line];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //    NSLog(@"should end editing");
    NSString *fullURL = textField.text;
    _url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:_url];
    [_viewWeb loadRequest:requestObj];
	return YES;
}
#endif

@end
