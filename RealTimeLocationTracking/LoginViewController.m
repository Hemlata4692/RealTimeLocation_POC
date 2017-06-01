
#import "LoginViewController.h"
#import "UserService.h"
#import "DemoViewController.h"
@interface LoginViewController ()<UITextFieldDelegate,BSKeyboardControlsDelegate>{
    NSArray *textfieldArray;
}

@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@end

@implementation LoginViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //BSKeyboard
    textfieldArray = @[_emailText,_passwordText];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:textfieldArray]];
    [self.keyboardControls setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
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
        [UserDefaultManager setValue:[responseObject objectForKey:@"user_id"] key:@"userId"];
        [UserDefaultManager setValue:_emailText.text key:@"email"];
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        DemoViewController * loginView = [storyboard instantiateViewControllerWithIdentifier:@"DemoViewController"];
//        [myDelegate.window setRootViewController:loginView];
//        [myDelegate.window makeKeyAndVisible];
        
        UIViewController * objReveal = [storyboard instantiateViewControllerWithIdentifier:@"SWRevealViewController"];
        myDelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [myDelegate.window setRootViewController:objReveal];
        [myDelegate.window setBackgroundColor:[UIColor whiteColor]];
        [myDelegate.window makeKeyAndVisible];
        
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

#pragma mark - Keyboard controls delegate
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *view;
    view = field.superview.superview.superview;
}
- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [keyboardControls.activeField resignFirstResponder];
}
#pragma mark - end

#pragma mark - Textfield delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.keyboardControls setActiveField:textField];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - end

@end
