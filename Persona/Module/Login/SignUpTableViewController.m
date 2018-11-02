//
//  SignUpTableViewController.m
//  Persona
//
//  Created by Azules on 2018/10/27.
//  Copyright © 2018年 Azules. All rights reserved.
//

#import "SignUpTableViewController.h"
#import "Spinner.h"
@import FirebaseAuth;

@interface SignUpTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *comfirmTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@end

@implementation SignUpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Persona", nil);
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    self.signUpButton.layer.cornerRadius = CGRectGetHeight(self.signUpButton.frame) / 2.f;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    [Spinner stop];
}

- (IBAction)signUpButtonTapped {
    [self.view endEditing:YES];
    
    if ([self.emailTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""] || [self.comfirmTextField.text isEqualToString:@""]) {
        [self alertWithMessage:NSLocalizedString(@"Please enter an email and password.", nil)];
    } else if (![self.passwordTextField.text isEqualToString:self.comfirmTextField.text]) {
        [self alertWithMessage:NSLocalizedString(@"Please check your password.", nil)];
    } else {
        [self createUser];
    }
}

- (void)createUser {
    [Spinner start];
    
    [[FIRAuth auth] createUserWithEmail:self.emailTextField.text
                               password:self.passwordTextField.text
                             completion:^(FIRAuthDataResult *authResult, NSError *error) {                                 
                                 if (!error) {
                                     [authResult.user sendEmailVerificationWithCompletion:^(NSError *error) {
                                         [Spinner stop];
                                         
                                         if (!error) {
                                             [self showSuccessfulMessage];
                                         } else {
                                             [self alertWithMessage:error.localizedDescription];
                                         }
                                     }];
                                 } else {
                                     [Spinner stop];
                                     [self alertWithMessage:error.localizedDescription];
                                 }
                             }];
}

#pragma mark - Alert Message

- (void)alertWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:nil];
    [alertController addAction:alertAction];
    
    if (!self.presentedViewController) {
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)showSuccessfulMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Activate Your Account"
                                                                             message:@"A validation email has been sent to your email, please click the link to activate your account."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [self.navigationController popViewControllerAnimated:YES];
                                                        }];
    [alertController addAction:alertAction];
    
    if (!self.presentedViewController) {
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    if ([textField isEqual:self.emailTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordTextField]) {
        [self.comfirmTextField resignFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
