//
//  DemoViewController.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 14/02/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "DemoViewController.h"
#import "MapViewController.h"
@interface DemoViewController ()
{
    BOOL isLocationUpdateStart;
}
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showMapScreenAction:(id)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MapViewController *nextView =[storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    [self.navigationController pushViewController:nextView animated:YES];

}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
