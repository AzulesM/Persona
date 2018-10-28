//
//  LoginTableViewController.m
//  Persona
//
//  Created by Azules on 2018/10/27.
//  Copyright © 2018年 Azules. All rights reserved.
//

#import "LoginTableViewController.h"

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
}

- (IBAction)loginButtonTapped {
    [self.view endEditing:YES];
    
    if ([self.emailTextField.text isEqualToString:@""] || [self.passwordTextField.text isEqualToString:@""]) {
        [self alertWithMessage:NSLocalizedString(@"Please enter an email and password.", nil)];
    } else {
        
    }
}

- (void)resetPasswordWithEmail:(NSString *)email {
    if ([email isEqualToString:@""]) {
        [self alertWithMessage:@"Please enter an email."];
        return;
    }
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

- (void)alertWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                          style:UIAlertActionStyleCancel
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
