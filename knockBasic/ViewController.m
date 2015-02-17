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
    
    
    
    // start monitoring for the beacons
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"A64A513A-96DF-4117-AFE4-6835A1D1285E"];
    
   
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                             identifier:@"beacon"];
    
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    
    
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) { // iOS8+
        // Sending a message to avoid compile time error
        [[UIApplication sharedApplication] sendAction:@selector(requestAlwaysAuthorization)
                                                   to:self.locationManager
                                                 from:self
                                             forEvent:nil];
    }
    
    
    ///end start monitoring
    
    
    
    self.mainWeb.scrollView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    [self.mainWeb.scrollView setDelegate:self];
    NSString *urlString = @"http://cnn.com";
    
    //2
    NSURL *url = [NSURL URLWithString:urlString];
    
    //3
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //4
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    //5
    //[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
    // {
    //     if ([data length] > 0 && error == nil) [self.mainWeb loadRequest:request];
    //     else if (error != nil) NSLog(@"Error: %@", error);
    // }];
    
    
}




// webview delagate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.progressView.backgroundColor = [UIColor lightGrayColor];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.progressView.backgroundColor = [UIColor whiteColor];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    self.progressView.backgroundColor = [UIColor whiteColor];
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
    
    
    
    /// this will be called multiple times while in rang eof the beacon
    
    // Beacon found!
    //self.statusLabel.text = @"Beacon found!";
    
   // NSLog(@"this is a beacon");
    
    CLBeacon *foundBeacon = [beacons firstObject];
    
    //check if its null
    
    // beacons array is the array of beacons ordered by closest.
    
    // You can retrieve the beacon data from its properties
    NSString *uuid = foundBeacon.proximityUUID.UUIDString;
    NSString *major = [NSString stringWithFormat:@"%@", foundBeacon.major];
    NSString *minor = [NSString stringWithFormat:@"%@", foundBeacon.minor];
    
    
    if (foundBeacon.major ==nil) {
       // NSLog(@"you are not listening to a beacon!!!!");
        
    }
    else{
       // NSLog(@"the closest beacon is %@,%@",foundBeacon.major, foundBeacon.minor);
        
      //  NSLog(@"the size of the array is %lu", (unsigned long)beacons.count);
        
        
        if (currentBeacon.major==foundBeacon.major&&currentBeacon.minor==currentBeacon.minor) {
           // NSLog(@"same beacon");
        }
        else{
            
            NSLog(@"new beacon, go get the data or display something?");
            
            currentBeacon = [[CLBeacon alloc]init];
            
            currentBeacon = foundBeacon;
            
            [self getData:currentBeacon];
            
            //[self makeArray:beacons];
        }
    }
    
    
    
    
    
}

// send a data request when you have found a new beacon


-(void)makeArray:(NSArray*)beacons{
    
    
    NSLog(@"the beacons when sent  around contains: %lu", (unsigned long)beacons.count);
    
    // get the data on the beacons
    
    NSMutableArray *queries = [[NSMutableArray alloc]init];
    
    
    for (int i =0; i<beacons.count; i++) {
        CLBeacon *theBeac = [beacons objectAtIndex:i];
        
        NSString *major = [NSString stringWithFormat:@"%@", theBeac];
        NSString *minor = [NSString stringWithFormat:@"%@", theBeac];
        
        
        PFQuery *query = [PFQuery queryWithClassName:@"beacon"];
        
        
        
        [query whereKey:@"major" equalTo:major];
        [query whereKey:@"minor" equalTo:minor];
        
        [queries addObject:query];
        
    }
    
   
    NSArray*arrayForQuery = [[NSArray alloc]initWithArray:queries];
    
    NSLog(@"the array for queries: %lu", (unsigned long)arrayForQuery.count);
    
    
    PFQuery *mainQuery = [PFQuery orQueryWithSubqueries:arrayForQuery];
    
    [mainQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            // the things to display
            
            theBeaconsAround = [[NSMutableArray alloc]initWithArray:objects];
            NSLog(@"the beacons around contains: %lu", (unsigned long)objects.count);
            
            NSLog(@"it was successful");
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];}


-(void)getData:(CLBeacon *)theBeacon{
    
    
    //NSLog(@"it is a new beacon so go get the data");
    
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
            
           
            
            [self goTo:command];
            
            
            
        }
        else {
        
        
        
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
}
- (IBAction)rightOptionAction:(id)sender {
    
    
    
    
    if (ranging) {
        [self.locationManager stopMonitoringForRegion:self.beaconRegion];
        
        ranging = NO;
        
        [self.rightOptionButton setTitle:@"Off" forState:UIControlStateNormal];
    }
    else{
        
        [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
        
        ranging = YES;
        
        [self.rightOptionButton setTitle:@"On" forState:UIControlStateNormal];
    }
}
@end
