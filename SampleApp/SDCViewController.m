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

- (IBAction)upload:(id)sender
{
    NSURL *trackURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"Spring" ofType:@"mp3"]];
    
    SCShareViewController *shareViewController;
    SCSharingViewControllerCompletionHandler handler;
    
    handler = ^(NSDictionary *trackInfo, NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Uploaded track: %@", trackInfo);
        }
    };
    shareViewController = [SCShareViewController
                           shareViewControllerWithFileURL:trackURL
                           completionHandler:handler];
    [shareViewController setTitle:@"Spring"];
    [shareViewController setPrivate:YES];
    
    [self presentViewController:shareViewController animated:YES completion:nil];
}


- (IBAction) downloadPlaylist:(id) sender
{
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_sync(concurrentQueue, ^{
        
        // SoundCloud info : songsonsunday user_ID 41080003
        // https://api.soundcloud.com/resolve.json?url=https://soundcloud.com/songsonsunday/tracks&client_id=72e3bbd3fe1128c8761cfaa4e0a237c2
        
        
        NSURL *url = [NSURL URLWithString:@"https://api.soundcloud.com/users/41080003/tracks.json?client_id=72e3bbd3fe1128c8761cfaa4e0a237c2&limit=3"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSError *error;
        
        id trackData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (!error)
        {
            [self performSegueWithIdentifier:@"getTracks" sender:(NSArray *)trackData];
            NSLog(@"Sending Track Data to VC");
        } else {
            NSLog(@"Playlist wasn't able to download: %@", error);
        }
    });
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
        NSLog(@"Performed Json Response");
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]])
        {
            [self performSegueWithIdentifier:@"getTracks" sender:(NSArray *)jsonResponse];
            NSLog(@"Got to Perform Segue");
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
       int trackCount = trackListVC.tracks.count;
        NSLog(@"num of tracks: %d", trackCount);
    }
    
}

@end
