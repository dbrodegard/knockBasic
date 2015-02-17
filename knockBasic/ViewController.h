//
//  ViewController.h
//  knockBasic
//
//  Created by David Brodegard on 1/16/15.
//  Copyright (c) 2015 David Brodegard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import <Parse/Parse.h>

@interface ViewController : UIViewController <UIWebViewDelegate,CLLocationManagerDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *mainWeb;
@property (weak, nonatomic) IBOutlet UIView *progressView;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *beaconDisplayTitle;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *rightOptionButton;
- (IBAction)rightOptionAction:(id)sender;


@end

