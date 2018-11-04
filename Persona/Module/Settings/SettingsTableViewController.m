//
//  SettingsTableViewController.m
//  Persona
//
//  Created by Azules on 2018/11/1.
//  Copyright © 2018年 Azules. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "AppDelegate.h"
@import FirebaseAuth;

@interface SettingsTableViewController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [[FIRAuth auth] signOut:nil];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate checkCurrentUser];
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
