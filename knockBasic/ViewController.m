//
//  ViewController.m
//  knockBasic
//
//  Created by David Brodegard on 1/16/15.
//  Copyright (c) 2015 David Brodegard. All rights reserved.
//

#import "ViewController.h"

CLBeacon *currentBeacon;

NSMutableArray *theBeaconsAround;

// toggles ranging
BOOL ranging;

// tracks how long a beacon has been ranged
int countOut;

@interface ViewController ()



@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // set delagates
    [self.mainWeb setDelegate:self];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // end set delagates
    
    ranging = NO;
    
    // sets the count out timer to 20
    countOut = 20;
    
    
    
    // start monitoring for the beacons
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"A64A513A-96DF-4117-AFE4-6835A1D1285E"];
    
   
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                             identifier:@"beacon"];
    
    
    //[self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    
    
    // request authorization or location monitor
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8+
        // Sending a message to avoid compile time error
        [[UIApplication sharedApplication] sendAction:@selector(requestAlwaysAuthorization)
                                                   to:self.locationManager
                                                 from:self
                                             forEvent:nil];
    }
    
    // webview setup
    
    self.mainWeb.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    [self.mainWeb.scrollView setDelegate:self];
    
    
    //design ranging toggle
    
    self.rightOptionButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.rightOptionButton.layer.borderWidth = 3;
    
    self.rightOptionButton.layer.cornerRadius = 17;
    
    self.rightOptionButton.clipsToBounds = YES;
    
    self.topBackImageView.layer.cornerRadius = 17;
    
    self.topBackImageView.clipsToBounds = YES;
    
    
    self.mainWeb.scrollView.alwaysBounceHorizontal = NO;
    
    
    
    // TURN ON RANGING FOR 20 SECONDS EACH TIME THE APP WAKES   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnOnBeaconRanging) name:UIApplicationDidBecomeActiveNotification object:nil];

    
}





// webview delagate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
   
    

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}


/// handle beacons

- (void)locationManager:(CLLocationManager*)manager didEnterRegion:(CLRegion*)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    NSLog(@"you are entering");
}

-(void)locationManager:(CLLocationManager*)manager didExitRegion:(CLRegion*)region
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
   
}


-(void)locationManager:(CLLocationManager*)manager
       didRangeBeacons:(NSArray*)beacons
              inRegion:(CLBeaconRegion*)region
{
    
    
    
    /// this will be called multiple times while in range of the beacon

   // NSLog(@"this is a beacon");
    
    CLBeacon *foundBeacon = [beacons firstObject];

    
    // beacons array is the array of beacons ordered by closest.
    
    // retrieve beacon data from properties
    
    NSString *uuid = foundBeacon.proximityUUID.UUIDString;
    NSString *major = [NSString stringWithFormat:@"%@", foundBeacon.major];
    NSString *minor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
    
    
    if (foundBeacon.major ==nil) {
       NSLog(@"you are not in range of any beacons, will range for 20 seconds");
        
        if (countOut>0) {
            countOut = countOut-1;
        }
        else{
            
            // turn off beacon ranging because you are not listening to any beacon
            
            [self turnOffBeaconRanging];
        }
        
    }
    else{
        
        if (currentBeacon.major==foundBeacon.major&&currentBeacon.minor==currentBeacon.minor) {
            NSLog(@"same beacon");
            
            if (countOut>0) {
                countOut = countOut-1;
            }
            else{
                
                // turn off beacon ranging because you are just listening to the same beacon
                
                [self turnOffBeaconRanging];
            }
            
        }
        else{
            
            
            // make sure the user is within immediate vicinity
            
            if (CLProximityImmediate == foundBeacon.proximity) {
                
                // light up the right button to identify found beacon
                
                self.rightOptionButton.backgroundColor = [UIColor greenColor];
                
                
                NSLog(@"new beacon, go get the data");
                
                // set current beacon to the newly discovered beacon to prevent multiple data calls
                
                currentBeacon = [[CLBeacon alloc]init];
                
                currentBeacon = foundBeacon;
                
                [self getData:currentBeacon];
                
                // reset the count down to turn off the beacon ranging
                countOut = 20;
                
                
                
            } else {
                // do nothing
            }
            
            
            
            
            
            
        }
    }
    
    
    
    
    
}

// send a data request when you have found a new beacon


-(void)getData:(CLBeacon *)theBeacon{
    
    
    NSLog(@"going to get data for new beacon");
    
    NSString *major = [NSString stringWithFormat:@"%@", theBeacon.major];
    NSString *minor = [NSString stringWithFormat:@"%@", theBeacon.minor];
    
    
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"beacon"];
    
    
    
    [query whereKey:@"major" equalTo:major];
    [query whereKey:@"minor" equalTo:minor];
    
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * beacon, NSError *error) {
        if (!error) {
            
        NSLog(@"it did retrieve a beacon");
            
            NSString *command = [beacon objectForKey:@"command"];
            
            NSString *displayName = [beacon objectForKey:@"displayName"];
            
            self.beaconDisplayTitle.text = displayName;
            
            // remove the right button display color
            
           self.rightOptionButton.backgroundColor = [UIColor clearColor];
            
            [self goTo:command];
            
            
            
        }
        else {
        
            // remove the right button display color
            
            self.rightOptionButton.backgroundColor = [UIColor clearColor];
        
        
        }
    }];
    
    
    
}

-(void)goTo:(NSString*)theSite{
    
    
    NSURL *url = [NSURL URLWithString:theSite];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.mainWeb loadRequest:requestObj];
    
    
    /*
    
    //2
    NSURL *url = [NSURL URLWithString:theSite];
    
    //3
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //4
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //5
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil) [self.mainWeb loadRequest:request];
         else if (error != nil) NSLog(@"Error: %@", error);
     }];
*/
    
}



// end handle beacons


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






- (IBAction)backButtonAction:(id)sender {
    
    NSLog(@"back button");
    
    if (self.mainWeb.canGoBack) {
        [self.mainWeb goBack];
    }
}
- (IBAction)rightOptionAction:(id)sender {
    
    
    
    
    if (ranging) {
        
        [self turnOffBeaconRanging];
        
    }
    else{
        
        [self turnOnBeaconRanging];
    }
    
    
}

-(void)turnOffBeaconRanging{
    
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    
    ranging = NO;
    
    [self.rightOptionButton setTitle:@"Off" forState:UIControlStateNormal];
    
    self.rightOptionButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.rightOptionButton.backgroundColor = [UIColor clearColor];
    
    [self.rightOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    countOut = 20;
    
    
}

-(void)turnOnBeaconRanging{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    ranging = YES;
    
    [self.rightOptionButton setTitle:@"On" forState:UIControlStateNormal];
    
    self.rightOptionButton.layer.borderColor = [UIColor greenColor].CGColor;
    
    self.rightOptionButton.backgroundColor = [UIColor clearColor];
    
    [self.rightOptionButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
}

@end
