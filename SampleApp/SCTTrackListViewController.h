//
//  SCTTrackListViewController.h
//  SampleApp
//
//  Created by Charles Black on 8/3/14.
//  Copyright (c) 2014 Kathryn Bearden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SCTTrackListViewController : UITableViewController <AVAudioPlayerDelegate>

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, strong) AVAudioPlayer *player;

@end
