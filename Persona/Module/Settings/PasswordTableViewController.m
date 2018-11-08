//
//  PasswordTableViewController.m
//  Persona
//
//  Created by Azules on 2018/11/6.
//  Copyright © 2018年 Azules. All rights reserved.
//

#import "PasswordTableViewController.h"
#import "Spinner.h"
@import FirebaseAuth;

@interface PasswordTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *comfirmTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;

@end

@implementation PasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Persona", nil);
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)]];
    self.changeButton.layer.cornerRadius = CGRectGetHeight(self.changeButton.frame) / 2.f;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
    [Spinner stop];
}

- (IBAction)didTapChangeButton {
    [self.view endEditing:YES];
    
    if ([self.oldPasswordTextField.text isEqualToString:@""]) {
        [self alertWithMessage:NSLocalizedString(@"Please enter old password.", nil)];
    } else if ([self.passwordTextField.text isEqualToString:@""] || [self.comfirmTextField.text isEqualToString:@""]) {
        [self alertWithMessage:NSLocalizedString(@"Please enter new password.", nil)];
    } else if (![self.passwordTextField.text isEqualToString:self.comfirmTextField.text]) {
        [self alertWithMessage:NSLocalizedString(@"Please check your password.", nil)];
    } else {
        [self updatePassword];
    }
}

- (void)updatePassword {
    [Spinner start];
    
    FIRUser *user = [[FIRAuth auth] currentUser];
    FIRAuthCredential *credential = [FIREmailAuthProvider credentialWithEmail:user.email password:self.oldPasswordTextField.text];
    [user reauthenticateAndRetrieveDataWithCredential:credential completion:^(FIRAuthDataResult *authResult, NSError *error) {
        if (error) {
            [Spinner stop];
            
            [self alertWithMessage:error.localizedDescription];
        } else {
            [user updatePassword:self.passwordTextField.text completion:^(NSError *error) {
                [Spinner stop];
                
                if (error) {
                    [self alertWithMessage:error.localizedDescription];
                } else {
                    [self showSuccessfulMessage];
                }
            }];
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
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Password Changed"
                                                                             message:@"Your password have been changed."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                            [self.navigationController popViewControllerAnimated:YES];
                                                        }];
    [alertController addAction:alertAction];
    
    if (!self.presentedViewController) {
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    if ([textField isEqual:self.oldPasswordTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordTextField]) {
        [self.comfirmTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
