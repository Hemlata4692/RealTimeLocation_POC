//
//  GlobalViewController.m
//  ComplainManager
//
//  Created by Monika Sharma on 16/05/17.
//  Copyright © 2017 Monika Sharma. All rights reserved.
//

#import "GlobalViewController.h"
#import "SWRevealViewController.h"

@interface GlobalViewController ()<SWRevealViewControllerDelegate>
{
    UIBarButtonItem *backButton;
    UIBarButtonItem *menuButton;
}
@end

@implementation GlobalViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    myDelegate.navigationController=self.navigationController;
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - Add back button
- (void)addBackButton {
    //    CGRect framing = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    CGRect framing = CGRectMake(0, 0, 20, 20);
    UIButton *button = [[UIButton alloc] initWithFrame:framing];
    [button setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [button setContentMode:UIViewContentModeScaleAspectFit];
    backButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = backButton;
    [button addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

//Logout button action
-(void)backButtonAction :(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - end
- (void)addMenuButton {
    CGRect framing = CGRectMake(0, 0, 20, 20);
    UIButton *button = [[UIButton alloc] initWithFrame:framing];
    [button setBackgroundImage:[UIImage imageNamed:@"menu.png"] forState:UIControlStateNormal];
    [button setContentMode:UIViewContentModeScaleAspectFit];
    menuButton =[[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = menuButton;
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [button addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

@end
