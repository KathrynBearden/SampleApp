//
//  SDCViewController.m
//  SampleApp
//
//  Created by Charles Black on 7/30/14.
//  Copyright (c) 2014 Kathryn Bearden. All rights reserved.
//

#import "SDCViewController.h"
#import "SCUI.h"
#import "SCTTrackListViewController.h"

@interface SDCViewController ()

@end

@implementation SDCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) login:(id) sender
{
    SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Done!");
        }
    };
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCLoginViewController *loginViewController;
        
        loginViewController = [SCLoginViewController
                               loginViewControllerWithPreparedURL:preparedURL
                               completionHandler:handler];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }];
}

- (IBAction) getTracks:(id) sender
{
    SCAccount *account = [SCSoundCloud account];
    if (account == nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Not Logged In"
                              message:@"You must login first"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]])
        {
            [self performSegueWithIdentifier:@"getTracks" sender:(NSArray *)jsonResponse];
            /*
            SCTTrackListViewController *trackListVC;
            trackListVC = [[SCTTrackListViewController alloc]
                           initWithNibName:@"SCTTrackListTableViewController"
                           bundle:nil];
            trackListVC.tracks = (NSArray *)jsonResponse;
            [self presentViewController:trackListVC
                               animated:YES completion:nil];
             */
        }
    };
    
    NSString *resourceURL = @"https://api.soundcloud.com/me/tracks.json";
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
}




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SCTTrackListViewController *trackListVC = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"getTracks"])
    {
        trackListVC.tracks = (NSArray *)sender;
    }
    
}

@end
