//
//  MenuViewController.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 01/05/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "MenuViewController.h"
#import "RealTimeTrackViewController.h"

@interface MenuViewController () {
    NSArray *menuArray;
}

@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@end

@implementation MenuViewController
#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Show Route";
    menuArray = [NSArray arrayWithObjects:@"Show path from database",@"Show path from server",@"Show real time moving path", nil];
    [self addMenuButton];
    //Remove extra separators
    [[UITableView appearance] setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
#pragma mark - end

#pragma mark - Table view delegate and datasource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Data fetched from autocomplete search
    return menuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"cell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //Display data fetched from autocomplete search
    cell.textLabel.text = [menuArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //Fetch lat,long from selected address
    if (indexPath.row == 2) {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"PathTrackingViewController"];
        [self.navigationController pushViewController:pushView animated:NO];
    } else {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RealTimeTrackViewController *pushView =[storyboard instantiateViewControllerWithIdentifier:@"RealTimeTrackViewController"];
        pushView.selectedMenu = indexPath.row;
        [self.navigationController pushViewController:pushView animated:NO];
    }
}
#pragma mark - end
@end
