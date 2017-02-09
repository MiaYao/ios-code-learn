[webView evaluateJavaScript: @"navigator.userAgent" completionHandler: ^(id result, NSError *error){
    NSString *oldAgent = result;
    NSString *newAgent = [NSString stringWithFormat:@"%@;***",oldAgent];
    webView.customUserAgent = newAgent;
}];