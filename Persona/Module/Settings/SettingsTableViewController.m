//
//  SettingsTableViewController.m
//  Persona
//
//  Created by Azules on 2018/11/1.
//  Copyright © 2018年 Azules. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "AppDelegate.h"
#import "Spinner.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
@import FirebaseAuth;
@import FirebaseStorage;

@interface SettingsTableViewController () <UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (strong, nonatomic) UIImage *image;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Persona", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:self.navigationItem.backBarButtonItem.style
                                                                            target:nil
                                                                            action:nil];
    
    self.imageView.layer.borderWidth = 1.f;
    self.imageView.layer.borderColor = [[UIColor blackColor] CGColor];
    self.imageView.layer.cornerRadius = CGRectGetWidth(self.imageView.frame) / 2.f;
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView)]];
    
    FIRUser *user = [[FIRAuth auth] currentUser];
    
    if (user) {
        self.nameLabel.text = user.displayName;
        self.emailLabel.text = user.email;
        [self fecthPhoto];
    }
}

- (void)fecthPhoto {
    FIRUser *user = [[FIRAuth auth] currentUser];
    
    if (user.photoURL) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:user.photoURL];
            UIImage *image = [[UIImage alloc] initWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    self.imageView.image = image;
                }
            });
        });
    }
}

- (void)didTapImageView {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIImagePickerController *pickerController = [UIImagePickerController new];
    pickerController.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                                                                [self presentViewController:pickerController animated:YES completion:nil];
                                                            }];
        [alertController addAction:alertAction];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photo Library", nil)
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *action) {
                                                                pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                                                [self presentViewController:pickerController animated:YES completion:nil];
                                                            }];
        [alertController addAction:alertAction];
    }

    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    if (!self.presentedViewController) {
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)uploadPhoto {
    FIRUser *user = [[FIRAuth auth] currentUser];
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    FIRStorageReference *imagesRef = [storageRef child:[NSString stringWithFormat:@"images/%@.png", user.uid]];
    NSData *data = UIImagePNGRepresentation(self.image);
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"image/png";
    FIRStorageUploadTask *uploadTask = [imagesRef putData:data metadata:metadata];
    [uploadTask observeStatus:FIRStorageTaskStatusProgress handler:^(FIRStorageTaskSnapshot *snapshot) {
        if (snapshot.error) {
            [self alertWithMessage:snapshot.error.localizedDescription];
        } else if (snapshot.progress.completedUnitCount == snapshot.progress.totalUnitCount) {
//            [self downloadPhoto];
            [imagesRef downloadURLWithCompletion:^(NSURL *URL, NSError *error) {
                if (error) {
                    [self alertWithMessage:error.localizedDescription];
                } else {
                    FIRUserProfileChangeRequest *request = [user profileChangeRequest];
                    request.photoURL = URL;
                    [request commitChangesWithCompletion:^(NSError *error) {
                        if (error) {
                            [self alertWithMessage:error.localizedDescription];
                        }
                    }];
                }
            }];
        }
    }];
//    [uploadTask observeStatus:FIRStorageTaskStatusFailure handler:^(FIRStorageTaskSnapshot *snapshot) {
//        [self alertWithMessage:snapshot.error.localizedDescription];
//    }];
//    [uploadTask observeStatus:FIRStorageTaskStatusSuccess handler:^(FIRStorageTaskSnapshot *snapshot) {
//        [imagesRef downloadURLWithCompletion:^(NSURL *URL, NSError *error) {
//            NSLog(@"url %@, error2 %@", URL.absoluteString, error);
//
//            if (error) {
//                [self alertWithMessage:error.localizedDescription];
//            } else {
//                FIRUserProfileChangeRequest *request = [user profileChangeRequest];
//                request.photoURL = URL;
//                [request commitChangesWithCompletion:^(NSError *error) {
//                    NSLog(@"error3 %@", error);
//                    if (error) {
//                        [self alertWithMessage:error.localizedDescription];
//                    } else {
//                        [Spinner stop];
//                    }
//                }];
//            }
//        }];
//    }];
}

- (void)downloadPhoto {
    FIRUser *user = [[FIRAuth auth] currentUser];
    FIRStorageReference *storageRef = [[FIRStorage storage] reference];
    FIRStorageReference *imagesRef = [storageRef child:[NSString stringWithFormat:@"images/%@.png", user.uid]];
    [imagesRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error) {
        NSLog(@"data %@, error %@", data, error);
        if (error) {
            [self alertWithMessage:error.localizedDescription];
        } else {
            self.imageView.image = [UIImage imageWithData:data];
        }
    }];
}

#pragma mark - Alert Message

- (void)alertWithMessage:(NSString *)message {
    [Spinner stop];
    
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [[FIRAuth auth] signOut:nil];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate checkCurrentUser];
        
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filePath = [documentPath stringByAppendingPathComponent:@"/keystore/key.json"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if (image) {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [image drawInRect:CGRectMake(0.f, 0.f, 500.f, 500.f)];
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        self.imageView.image = self.image;
        UIGraphicsEndImageContext();
        [self uploadPhoto];
    }
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
