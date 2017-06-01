//
//  SidebarViewController.m
//  SidebarDemoApp
//
//  Created by Ranosys on 06/02/15.
//  Copyright (c) 2015 Shivendra. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "LoginViewController.h"

@interface SidebarViewController (){
    NSArray *menuItems;
}

@end

@implementation SidebarViewController

#pragma mark - View life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //Set status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, self.view.frame.size.width, 20)];
    statusBarView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statusBarView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    menuItems = @[@"Dashboard",@"Your trips",@"Payment", @"Logout"];
    self.tableView.scrollEnabled=NO;
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:NO];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:YES];
}
#pragma mark - end

#pragma mark - Table view delegate/data-source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //Side bar customisation
    cell.textLabel.text = [menuItems objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15.0];
     return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([[UIScreen mainScreen] bounds].size.height > 570) {
        float aspectHeight = 186.0/480.0;
        return (tableView.bounds.size.height * aspectHeight - 40);
    }
    else{
        return 180;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSLog(@"table size %f",tableView.bounds.size.width);
    float aspectHeight, profileViewHeight, nameHeight;
    nameHeight = 18;
    aspectHeight = 186.0/480.0;
    profileViewHeight = 80;
    if([[UIScreen mainScreen] bounds].size.height > 570) {
        aspectHeight = (tableView.bounds.size.height * aspectHeight - 20);
    }
    else {
        aspectHeight = 180;
    }
    //Header view frame
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, aspectHeight)];
    headerView.backgroundColor=[UIColor blackColor];
    //Profile image view
    UIImageView *ProfileImgView = [[UIImageView alloc] initWithFrame:CGRectMake((tableView.bounds.size.width/2)-(profileViewHeight/2), 15, profileViewHeight, profileViewHeight)];
    ProfileImgView.contentMode = UIViewContentModeScaleAspectFill;
    ProfileImgView.clipsToBounds = YES;
    ProfileImgView.backgroundColor=[UIColor whiteColor];
    // profile image url
    __weak UIImageView *weakRef = ProfileImgView;
    //    NSString *tempImageString = [UserDefaultManager getValue:@"userImage"];
    //    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:tempImageString]
    //                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
    //                                              timeoutInterval:60];
    //    [ProfileImgView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"sideBarPlaceholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    //        weakRef.contentMode = UIViewContentModeScaleAspectFill;
    //        weakRef.clipsToBounds = YES;
    //        weakRef.image = image;
    //    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    //    }];
    ProfileImgView.layer.cornerRadius = ProfileImgView.frame.size.width / 2;
    ProfileImgView.layer.masksToBounds = YES;
    //Name label
    UILabel * nameLabel;
    UILabel *emailLabel;
    CGSize size = CGSizeMake(self.view.frame.size.width-10,50);
    CGRect textRect = [self setDynamicHeight:size textString:[UserDefaultManager getValue:@"name"]];
    
    if (textRect.size.height < 40){
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, ProfileImgView.frame.origin.y + ProfileImgView.frame.size.height + 15, tableView.bounds.size.width - 10, textRect.size.height+1)];
        emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, nameLabel.frame.origin.y + nameLabel.frame.size.height +10, tableView.bounds.size.width - 10, nameHeight)];
    }
    else {
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, ProfileImgView.frame.origin.y + ProfileImgView.frame.size.height + 5, tableView.bounds.size.width - 10, textRect.size.height+1)];
        emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, nameLabel.frame.origin.y + nameLabel.frame.size.height +1, tableView.bounds.size.width - 10, nameHeight)];
    }
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment=NSTextAlignmentCenter;
    nameLabel.textColor=[UIColor whiteColor];
    nameLabel.numberOfLines = 2;
    nameLabel.text=[UserDefaultManager getValue:@"name"];
    //Email label
    emailLabel.backgroundColor = [UIColor clearColor];
    emailLabel.textAlignment=NSTextAlignmentCenter;
    emailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    emailLabel.numberOfLines = 1;
    emailLabel.textColor=[UIColor whiteColor];
    emailLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:14];
    emailLabel.text = [UserDefaultManager getValue:@"email"];
    [headerView addSubview:nameLabel];
    [headerView addSubview:emailLabel];
    [headerView addSubview:ProfileImgView];
    
    return headerView;   // return headerLabel;
}

//Set dynamic height
-(CGRect)setDynamicHeight:(CGSize)rectSize textString:(NSString *)textString {
    CGRect textHeight = [textString
                         boundingRectWithSize:rectSize
                         options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Roboto-Regular" size:18]}
                         context:nil];
    return textHeight;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (void)logoutUser {
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert addButton:@"Yes" actionBlock:^(void) {
            [self removeDefaultValues];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            myDelegate.navigationController = [storyboard instantiateViewControllerWithIdentifier:@"mainNavController"];
            myDelegate.window.rootViewController = myDelegate.navigationController;
        }];
        [alert showWarning:nil title:@"Alert" subTitle:@"Are you sure, you want to logout" closeButtonTitle:@"No" duration:0.0f];
    
}
- (void)removeDefaultValues {
    [UserDefaultManager removeValue:@"userId"];
       [UserDefaultManager removeValue:@"email"];
}

#pragma mark - end
@end
