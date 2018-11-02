//
//  LoginTableViewController.m
//  Persona
//
//  Created by Azules on 2018/10/27.
//  Copyright © 2018年 Azules. All rights reserved.
//

#import "LoginTableViewController.h"
#import "Spinner.h"
#import "AppDelegate.h"
@import FirebaseAuth;

@interface LoginTableViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *resetLabel;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Persona", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:self.navigationItem.backBarButtonItem.style
                                                                            target:nil
                                                                            action:nil];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    [self.resetLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showResetPassword)]];
    
    self.signUpButton.layer.cornerRadius = CGRectGetHeight(self.signUpButton.frame) / 2.f;
    self.loginButton.layer.cornerRadius = CGRectGetHeight(self.loginButton.frame) / 2.f;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    [Spinner stop];
}

- (IBAction)loginButtonTapped {
    [self.view endEditing:YES];
    
    if ([self.emailTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
        [self alertWithTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"Please enter an email and password.", nil)];
    } else {
        [self loginUser];
    }
}

- (void)loginUser {
    [Spinner start];
    
    [[FIRAuth auth] signInWithEmail:self.emailTextField.text
                           password:self.passwordTextField.text
                         completion:^(FIRAuthDataResult *authResult, NSError *error) {
                             [Spinner stop];
                             
                             if (error) {
                                 [self alertWithTitle:NSLocalizedString(@"Error", nil) andMessage:error.localizedDescription];
                             } else if (!authResult.user.emailVerified) {
                                 [self alertWithTitle:NSLocalizedString(@"Error", nil) andMessage:@"Your account has not been activated."];
                             }
                         }];
}

- (void)resetPasswordWithEmail:(NSString *)email {
    if ([email isEqualToString:@""]) {
        [self alertWithTitle:NSLocalizedString(@"Error", nil) andMessage:@"Please enter an email."];
        return;
    }
    
    [Spinner start];
    
    [[FIRAuth auth] sendPasswordResetWithEmail:email completion:^(NSError *error) {
        [Spinner stop];
        
        if (!error) {
            [self alertWithTitle:NSLocalizedString(@"Reset Password Successful", nil) andMessage:@""];
        } else {
            [self alertWithTitle:NSLocalizedString(@"Error", nil) andMessage:error.localizedDescription];
        }
    }];
}

#pragma mark - Alert Message

- (void)showResetPassword {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter an email"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    UIAlertAction *sendAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Reset", nil)
                                                           style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           UITextField *textField = alertController.textFields.firstObject;
                                                           
                                                           if (textField) {
                                                               [self resetPasswordWithEmail:textField.text];
                                                           }
                                                       }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:sendAction];
    
    if (!self.presentedViewController) {
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    if (textField.returnKeyType == UIReturnKeyNext) {
        [self.passwordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
