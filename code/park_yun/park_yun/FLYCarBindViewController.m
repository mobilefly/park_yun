//
//  FLYCarBindViewController.m
//  park_yun
//
//  Created by chen on 14-7-17.
//  Copyright (c) 2014年 无线飞翔. All rights reserved.
//

#import "FLYCarBindViewController.h"
#import "FLYDataService.h"
#import "UIButton+Bootstrap.h"

#define kCarBackgroundColor Color(249,249,249,1)
#define kCarBorderColor Color(204,204,204,1)
#define kCarTitColor Color(172,172,172,1)

@interface FLYCarBindViewController ()

@end

@implementation FLYCarBindViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"绑定车牌";
        _isUpload = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _carnoField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, 280, 40)];
    _carnoField.layer.masksToBounds = YES;
    _carnoField.layer.borderColor = [kCarBorderColor CGColor];
    _carnoField.layer.borderWidth = 1.0f;
    _carnoField.layer.cornerRadius = 5.0;
    _carnoField.backgroundColor = kCarBackgroundColor;
    _carnoField.placeholder = @"输入车牌号";
    _carnoField.textAlignment = NSTextAlignmentCenter;
    _carnoField.textColor = [UIColor grayColor];
    _carnoField.font = [UIFont systemFontOfSize:14.0];
    [self.view addSubview:_carnoField];
    
    
    _uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _uploadBtn.frame =CGRectMake(20, _carnoField.bottom + 20, 280, 40);
    [_uploadBtn defaultStyle];
    [_uploadBtn setTitle:@"上传行车证" forState:UIControlStateNormal];
    _uploadBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_uploadBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_uploadBtn];
    
    _photoView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 200) / 2, _uploadBtn.bottom + 20, 200, 140)];
    _photoView.image = [UIImage imageNamed:@"mfpparking_bdcpsc_all_0.png"];
    _photoView.layer.masksToBounds = YES;
    _photoView.layer.borderColor = [kCarBorderColor CGColor];
    _photoView.layer.borderWidth = 1.0f;
    _photoView.layer.cornerRadius = 2.0;
    [self.view addSubview:_photoView];
    
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _photoView.bottom + 20, 280, 0)];
    _detailLabel.numberOfLines = 0;
    _detailLabel.text = @"请确保照片中车辆部分清晰，行车证号码及车牌号码清晰可辨认";
    _detailLabel.font = [UIFont systemFontOfSize:13.0];
    _detailLabel.textColor = [UIColor grayColor];
    [_detailLabel sizeToFit];
    [self.view addSubview:_detailLabel];
    
    _submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _submitBtn.frame = CGRectMake(20,_detailLabel.bottom + 20 , 280, 40);
    [_submitBtn primaryStyle];
    [_submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitBtn];
}

#pragma mark - 数据请求
- (void)requestUpload{
    [self showHUDProgress:@"文件上传中" isDim:NO];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults stringForKey:@"token"];
    NSString *userid = [defaults stringForKey:@"memberId"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   token,
                                   @"token",
                                   userid,
                                   @"userid",
                                   _carnoField.text,
                                   @"carno",
                                   nil];

    NSData *picData = UIImageJPEGRepresentation(_photoView.image, 1);
    [params setObject:picData forKey:@"image"];
    [params setObject:picData forKey:@"image1"];
    
    //防止循环引用
    __weak FLYCarBindViewController *ref = self;
    [FLYDataService requestWithURL:kHttpAddCarno params:params progress:self completeBolck:^(id result){
        [ref loadLoginData:result];
    } errorBolck:^(){
        [ref loadLoginError];
    }];
}

- (void)loadLoginError{
    [self hideHUD];
    [FLYBaseUtil networkError];
}

//
- (void)loadLoginData:(id)data{
    
    NSString *flag = [data objectForKey:@"flag"];
    if ([flag isEqualToString:kFlagYes]) {
        [self showHUDComplete:@"提交成功"];
        [self performSelector:@selector(closeWin) withObject:nil afterDelay:1];
    }else{
        [self hideHUD];
        NSString *msg = [data objectForKey:@"msg"];
        [self showAlert:msg];
    }
}

- (void)closeWin{
     [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - 控件事件
- (void)submitAction:(UIButton *)button{
    if ([FLYBaseUtil isEmpty:_carnoField.text]) {
        [self showAlert:@"请输入车牌号"];
    }else if (_carnoField.text.length != 7){
        [self showAlert:@"车牌号必须为7位"];
    }else if (!_isUpload) {
        [self showAlert:@"请上传行车证"];
    }else{
         if ([FLYBaseUtil isEnableInternate]) {
             [self requestUpload];
         }else{
             [self showToast:@"请打开网络"];
         }
    }
}

- (void)selectAction:(UIButton *)button{
    [_carnoField resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍摄" otherButtonTitles:@"相册", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)backgroundTap:(id)sender {
    [_carnoField resignFirstResponder];
}

#pragma mark - ASIProgressDelegate delegate
- (void)setProgress:(float)newProgress{
    NSLog(@"%f",newProgress);
    [self updateHUDProgress:newProgress];
}

#pragma mark - UIActionSheetDelegate delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    UIImagePickerControllerSourceType sourceType;
    
    //拍照
    if (buttonIndex == 0) {
        
        BOOL isCamer = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
        if (!isCamer) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"此设备没有摄像头" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }
        sourceType = UIImagePickerControllerSourceTypeCamera;
        
    }
    //用户相册
    else if (buttonIndex == 1){
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    //取消
    else if (buttonIndex == 2){
        return;
    }
    
    //拍照
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = sourceType;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    int height = image.size.height;
    int width = image.size.width;
    
    int nWidth = 140 * width / height;
    
    _photoView.image = image;
    _photoView.frame = CGRectMake((ScreenWidth - nWidth) / 2, _uploadBtn.bottom + 20, nWidth, 140);
    
    _isUpload = YES;
    
    //关闭
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [_carnoField resignFirstResponder];
}

#pragma mark - Override UIViewController
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

@end
