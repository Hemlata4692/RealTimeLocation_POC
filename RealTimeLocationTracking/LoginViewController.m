//
//  LoginViewController.m
//  RealTimeLocationTracking
//
//  Created by Monika Sharma on 23/03/17.
//  Copyright © 2017 Ranosys. All rights reserved.
//

#import "LoginViewController.h"
#import "UserService.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@end

@implementation LoginViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)loginAction:(id)sender {
    [self.view endEditing:YES];
    if([self performValidationsForLogin]) {
        [myDelegate showIndicator];
        [self performSelector:@selector(loginUser) withObject:nil afterDelay:.1];
    }
}
#pragma mark - end

#pragma mark - Web services
-(void)loginUser {
    [[UserService sharedManager] userLogin:_emailText.text password:_passwordText.text success:^(id responseObject) {
        [myDelegate stopIndicator];
        [UserDefaultManager setValue:[responseObject objectForKey:@"userId"] key:@"userId"];
    } failure:^(NSError *error) {
    }] ;
}
#pragma mark - end

#pragma mark - Validation
- (BOOL)performValidationsForLogin {
    if ([_emailText isEmpty]||(_emailText.text.length==0)||([_emailText.text isEqualToString:@""])) {
        [self showAlertMessage:@"Please enter your email address."];
        return NO;
    }
    else  if ([_passwordText isEmpty]||(_passwordText.text.length==0)||([_emailText.text isEqualToString:@""])) {
        [self showAlertMessage:@"Please enter your password."];
        return NO;
    }
    else {
        if ([_emailText isValidEmail]) {
            if (_passwordText.text.length<6 ) {
                [self showAlertMessage:@"Password with minimum 6 characters are required."];
                return NO;
            }
            else {
                return YES;
            }
        }
        else {
            [self showAlertMessage:@"Please enter a valid email address."];
            return NO;
        }
    }
}
#pragma mark - end

#pragma mark - Alert message
-(void)showAlertMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Alert"
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
     UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - end

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
