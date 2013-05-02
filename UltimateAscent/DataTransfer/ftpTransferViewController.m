//
//  ftpTransferViewController.m
//  UltimateAscent
//
//  Created by FRC on 4/21/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//
/*
 
 Source:   SimpleFTPSample.
 
 Written by: DTS
 
 Copyright:  Copyright (c) 2009-2012 Apple Inc. All Rights Reserved.
 
 Disclaimer: IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of
 these terms.  If you do not agree with these terms, please do
 not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following
 terms, and subject to these terms, Apple grants you a personal,
 non-exclusive license, under Apple's copyrights in this
 original Apple software (the "Apple Software"), to use,
 reproduce, modify and redistribute the Apple Software, with or
 without modifications, in source and/or binary forms; provided
 that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the
 following text and disclaimers in all such redistributions of
 the Apple Software. Neither the name, trademarks, service marks
 or logos of Apple Inc. may be used to endorse or promote
 products derived from the Apple Software without specific prior
 written permission from Apple.  Except as expressly stated in
 this notice, no other rights or licenses, express or implied,
 are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or
 by other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.
 APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
 WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT,
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING
 THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT,
 INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY
 OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
 OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY
 OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR
 OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF
 SUCH DAMAGE.
 
 */


#import "ftpTransferViewController.h"
#import "DataManager.h"
#import "SettingsData.h"
#import "TournamentData.h"
#import "TeamData.h"
#import "NetworkManager.h"

#include <CFNetwork/CFNetwork.h>

enum {
    kSendBufferSize = 32768
};

@interface ftpTransferViewController ()
@property (nonatomic, assign, readonly ) BOOL              isSending;
@property (nonatomic, strong, readwrite) NSOutputStream *  networkStream;
@property (nonatomic, strong, readwrite) NSInputStream *   fileStream;
@property (nonatomic, assign, readonly ) uint8_t *         buffer;
@property (nonatomic, assign, readwrite) size_t            bufferOffset;
@property (nonatomic, assign, readwrite) size_t            bufferLimit;


@end

@implementation ftpTransferViewController {
    uint8_t                     _buffer[kSendBufferSize];
    BOOL sending;
    NSTimer *sendTimer;
    NSMutableArray *fileList;
    int sendIndex;
}
@synthesize dataManager = _dataManager;
@synthesize settings = _settings;
@synthesize pushDataButton = _pushDataButton;
@synthesize getDataButton = _getDataButton;
@synthesize sendDatabaseButton = _sendDatabaseButton;
@synthesize picturesButton = _picturesButton;
@synthesize urlText = _urlText;
@synthesize usernameText = _usernameText;
@synthesize passwordText = _passwordText;

@synthesize networkStream = _networkStream;
@synthesize fileStream    = _fileStream;
@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;

#pragma mark * Status management

// These methods are used by the core transfer code to update the UI.

- (void)sendDidStart
{
    self.statusLabel.text = @"Sending";
    self.cancelButton.enabled = YES;
    [self.activityIndicator startAnimating];
    [[NetworkManager sharedInstance] didStartNetworkOperation];
}

- (void)updateStatus:(NSString *)statusString
{
    assert(statusString != nil);
    self.statusLabel.text = statusString;
}

- (void)sendDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        statusString = @"Put succeeded";
        sending = FALSE;
    }
    self.statusLabel.text = statusString;
    self.cancelButton.enabled = NO;
    [self.activityIndicator stopAnimating];
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

// Because buffer is declared as an array, you have to use a custom getter.
// A synthesised getter doesn't compile.

- (uint8_t *)buffer
{
    return self->_buffer;
}

- (BOOL)isSending
{
    return (self.networkStream != nil);
}

- (void)startSend:(NSString *)filePath forDestination:(NSString *)destination
{
    BOOL                    success;
    NSURL *                 url;
    NSLog(@"destination = %@", destination);

    assert(filePath != nil);
    assert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
    
    assert(self.networkStream == nil);      // don't tap send twice in a row!
    assert(self.fileStream == nil);         // ditto
    
    // First get and check the URL.

    url = [[NetworkManager sharedInstance] smartURLForString:self.urlText.text];
    success = (url != nil);

    NSLog(@"filepath = %@", filePath);
    if (success) {
        // Add the last part of the file name to the end of the URL to form the final
        // URL that we're going to put to.
        
        url = CFBridgingRelease(
                                CFURLCreateCopyAppendingPathComponent(NULL, (__bridge CFURLRef) url, (__bridge CFStringRef) [filePath lastPathComponent], false)
                                );
        success = (url != nil);
    }
    NSLog(@"url = %@", url);
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        self.statusLabel.text = @"Invalid URL";
    } else {
        
        // Open a stream for the file we're going to send.  We do not open this stream;
        // NSURLConnection will do it for us.
        
        self.fileStream = [NSInputStream inputStreamWithFileAtPath:filePath];
        assert(self.fileStream != nil);
        
        [self.fileStream open];
        
        // Open a CFFTPStream for the URL.
        
        self.networkStream = CFBridgingRelease(
                                               CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url)
                                               );
        assert(self.networkStream != nil);
        
        if ([self.usernameText.text length] != 0) {
            NSLog(@"user = %@", self.usernameText.text);
            NSLog(@"password = %@", self.passwordText.text);
            success = [self.networkStream setProperty:self.usernameText.text forKey:(id)kCFStreamPropertyFTPUserName];
            assert(success);
            success = [self.networkStream setProperty:self.passwordText.text forKey:(id)kCFStreamPropertyFTPPassword];
            assert(success);
        }
        
        self.networkStream.delegate = self;
        [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.networkStream open];
        
        // Tell the UI we're sending.
        
        [self sendDidStart];
    }
 
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    if (self.networkStream != nil) {
        [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.networkStream.delegate = nil;
        [self.networkStream close];
        self.networkStream = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    [self sendDidStopWithStatus:statusString];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our
// network stream.
{
#pragma unused(aStream)
    assert(aStream == self.networkStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            [self updateStatus:@"Opened connection"];
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            [self updateStatus:@"Sending"];
            
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (self.bufferOffset == self.bufferLimit) {
                NSInteger   bytesRead;
                
                bytesRead = [self.fileStream read:self.buffer maxLength:kSendBufferSize];
                
                if (bytesRead == -1) {
                    [self stopSendWithStatus:@"File read error"];
                } else if (bytesRead == 0) {
                    [self stopSendWithStatus:nil];
                } else {
                    self.bufferOffset = 0;
                    self.bufferLimit  = bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            
            if (self.bufferOffset != self.bufferLimit) {
                NSInteger   bytesWritten;
                bytesWritten = [self.networkStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [self stopSendWithStatus:@"Network write error"];
                } else {
                    self.bufferOffset += bytesWritten;
                }
            }
        } break;
        case NSStreamEventErrorOccurred: {
            [self stopSendWithStatus:@"Stream open error"];
        } break;
        case NSStreamEventEndEncountered: {
            NSLog(@"Event ended");
        } break;
        default: {
            assert(NO);
        } break;
    }
}

#pragma mark * Actions

- (IBAction)sendAction:(UIView *)sender
{
    assert( [sender isKindOfClass:[UIView class]] );
    
    if ( ! self.isSending ) {
        NSString *  filePath;
        
        // User the tag on the UIButton to determine which image to send.
        
        assert(sender.tag >= 0);
        filePath = [[NetworkManager sharedInstance] pathForTestImage:(NSUInteger) sender.tag];
        assert(filePath != nil);
        
        [self startSend:filePath forDestination:nil];
    }
}

- (IBAction)cancelAction:(id)sender
{
#pragma unused(sender)
    [self stopSendWithStatus:@"Cancelled"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
// A delegate method called by the URL text field when the editing is complete.
// We save the current value of the field in our settings.
{
    NSString *  defaultsKey;
    NSString *  newValue;
    NSString *  oldValue;
    
    if (textField == self.urlText) {
        defaultsKey = @"CreateDirURLText";
    } else if (textField == self.usernameText) {
        defaultsKey = @"Username";
    } else if (textField == self.passwordText) {
        defaultsKey = @"Password";
    } else {
        assert(NO);
        defaultsKey = nil;          // quieten warning
    }
    
    newValue = textField.text;
//    if (oldValue == nil) oldValue = @"empty";
    oldValue = [[NSUserDefaults standardUserDefaults] stringForKey:defaultsKey];
    
    // Save the URL text if it's changed.
    
    assert(newValue != nil);        // what is UITextField thinking!?!
    assert(oldValue != nil);        // because we registered a default
    
    if ( ! [newValue isEqual:oldValue] ) {
        [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:defaultsKey];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
// A delegate method called by the URL text field when the user taps the Return
// key.  We just dismiss the keyboard.
{
#pragma unused(textField)
    assert( (textField == self.urlText) || (textField == self.usernameText) || (textField == self.passwordText) );
    [textField resignFirstResponder];
    return NO;
}

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
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    [self retrieveSettings];
    if (_settings) {
        self.title =  [NSString stringWithFormat:@"%@ FTP Transfer Page", _settings.tournament.name];
    }
    else {
        self.title = @"FTP Transfer Page";
    }
    [_pushDataButton setTitle:@"Push Data to Website" forState:UIControlStateNormal];
    _pushDataButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:20.0];
    [_getDataButton setTitle:@"Get Data from Website" forState:UIControlStateNormal];
    _getDataButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:20.0];
    [_sendDatabaseButton setTitle:@"Push Database" forState:UIControlStateNormal];
    _sendDatabaseButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:20.0];
    [_picturesButton setTitle:@"Pictures" forState:UIControlStateNormal];
    _picturesButton.titleLabel.font = [UIFont fontWithName:@"Nasalization" size:20.0];
    [_sendDatabaseButton setHidden:YES];
    [_picturesButton setHidden:YES];
    [_urlText setHidden:YES];
    [_usernameText setHidden:YES];
    [_passwordText setHidden:YES];
    sending = FALSE;
    fileList = [[NSMutableArray alloc] init];
}

- (IBAction)pushData:(id)sender {
    [_sendDatabaseButton setHidden:NO];
    [_picturesButton setHidden:NO];
    [_urlText setHidden:NO];
    [_usernameText setHidden:NO];
    [_passwordText setHidden:NO];
}

- (IBAction)getData:(id)sender {
//    [_databaseButton setHidden:NO];
    [_picturesButton setHidden:NO];
    [_urlText setHidden:NO];
    [_usernameText setHidden:NO];
    [_passwordText setHidden:NO];
}

- (IBAction)pushDatabase:(id)sender {    
    if ( ! self.isSending ) {
        NSString *  filePath;        
        // User the tag on the UIButton to determine which image to send.
        
        filePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"UltimateAscent.sqlite"];
        assert(filePath != nil);
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
                
        NSString *stringFromDate = [formatter stringFromDate:now];
        NSString  *destination = [@"UlimateAscent" stringByAppendingString:stringFromDate];
        destination = [destination stringByAppendingString:@".sqlite"];
 //destination = @"fieldDrawingTest.png";
        [self startSend:filePath forDestination:destination];
    }
}

-(NSArray *)listFileAtPath:(NSString *)path
{
    //-----> LIST ALL FILES <-----//
    // NSLog(@"LISTING ALL FILES FOUND");
    
    //int count;
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
/*    for (count = 0; count < (int)[directoryContent count]; count++)
    {
        NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
    } */
    return directoryContent;
}

- (IBAction)pictures:(id)sender {
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    // Add the search for tournament name
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournament = %@", _settings.tournament];
    [fetchRequest setPredicate:pred];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *teamList = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    [fileList removeAllObjects];
    NSString *  filePath;
    sendIndex = 0;
    filePath = [[self applicationLibraryDirectory] stringByAppendingPathComponent: @"RobotPhotos"];
    NSString *path;
    for (int i=0; i<[teamList count]; i++) {
        TeamData *team = [teamList objectAtIndex:i];
        path = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", [team.number intValue]]];
        NSArray *dirList = [self listFileAtPath:path];
        for (int j=0; j<[dirList count]; j++) {
            NSString *file;
            file = [path stringByAppendingPathComponent:[dirList objectAtIndex:j]];
            [fileList addObject:file];
        }
    }
    NSLog(@"Sending file = %@", fileList);
    [self timerStart];

/*     path = @"/Users/frc/Library/Application Support/iPhone Simulator/5.0/Applications/492F3A65-3B0D-4ACC-A50C-7BAFF2D5CAFA/Library/RobotPhotos/118/T0118_img001.jpg";
        NSLog(@"Sending file = %@", path);
        [self startSend:path forDestination:nil];*/
}

-(void)timerStart {
    if (sendTimer == nil) {
        sendTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                     target:self
                                                   selector:@selector(timerFired)
                                                   userInfo:nil
                                                    repeats:YES];
    }
//    timerCount = 0;
    sending = TRUE;
    NSLog(@"start send");
    //  [self startSend:path forDestination:nil];
 
}

- (void)timerFired {
    
}

-(void)timerEnd {
    
}

- (void)retrieveSettings {
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"SettingsData" inManagedObjectContext:_dataManager.managedObjectContext];
    
    [fetchRequest setEntity:entity];
    NSArray *settingsRecord = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!settingsRecord) {
        NSLog(@"Karma disruption error");
        _settings = Nil;
    }
    else {
        if([settingsRecord count] == 0) {  // No Settings Exists
            NSLog(@"Karma disruption error");
            _settings = Nil;
        }
        else {
            _settings = [settingsRecord objectAtIndex:0];
        }
    }
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

/**
 Returns the path to the application's Library directory.
 */
- (NSString *)applicationLibraryDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPushDataButton:nil];
    [self setGetDataButton:nil];
    [self setSendDatabaseButton:nil];
    [self setPicturesButton:nil];
    [self setUrlText:nil];
    [self setUsernameText:nil];
    [self setPasswordText:nil];
    [super viewDidUnload];
}
@end
