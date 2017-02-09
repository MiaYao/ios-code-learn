- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSURLRequest *request = navigationAction.request;
    NSString *requestString = [[request URL] absoluteString];
    
    NSLog(@"current URL: %@",requestString);
    
    NSString *protocol = @"js-call://uploadImage()";
    if([requestString hasPrefix:protocol]){
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            // Cancel button tappped.
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take Photo or Video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self takePhoto];
            }];
        }]];
        
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self choosePhotoFromLibrary];
            }];
        }]];
        
        // Present action sheet.
        [self presentViewController:actionSheet animated:YES completion:nil];
    }

}

- (void)takePhoto
{
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.allowsEditing = YES;
        imagePickerController.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePickerController.delegate = self;
        //[self presentViewController:
        //imagePickerController animated: YES completion: nil];
        [self addChildViewController:imagePickerController];
        [imagePickerController didMoveToParentViewController:self];
        [self.view addSubview:imagePickerController.view];
        [imagePickerController viewWillAppear:YES];
        [imagePickerController viewDidAppear:YES];
    }
    
}



- (void)choosePhotoFromLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.allowsEditing = YES;
        imagePickerController.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        imagePickerController.delegate = self;
        //[self presentViewController:
        //imagePickerController animated: YES completion: nil];
        [self addChildViewController:imagePickerController];
        [imagePickerController didMoveToParentViewController:self];
        [self.view addSubview:imagePickerController.view];
        [imagePickerController viewWillAppear:YES];
        [imagePickerController viewDidAppear:YES];
    }
    
    
}

+ (UIImage*)resizeImage:(UIImage*)image withWidth:(CGFloat)width
{
    
    float oldWidth = image.size.width;
    float scaleFactor = width  / oldWidth;
    
    float newHeight = image.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker.view removeFromSuperview];
    [picker removeFromParentViewController];
    
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    UIImage *image2 = [***View resizeImage: image withWidth:200];
    NSData *flatImage = UIImagePNGRepresentation(image2);
    NSString *image64 = [flatImage base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    image64 = [image64 stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    NSString *con = [NSString stringWithFormat:@"data:image/png;base64,%@",image64];
    
    NSString *javascript = [NSString stringWithFormat:@"$('#image').show();"];
    [content evaluateJavaScript:javascript completionHandler:nil];
    NSString *javascript1 = [NSString stringWithFormat:@"$('#output').attr('src',\"%@\");",con];
    [content evaluateJavaScript:javascript1 completionHandler:^(id result, NSError *error){

    }];
    
    NSString *js = [NSString stringWithFormat:@"$('#filePath').attr('value',\"%@\");",image64];
    [content evaluateJavaScript:js completionHandler:^(id result, NSError *error){

    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker.view removeFromSuperview];
    [picker removeFromParentViewController];
}