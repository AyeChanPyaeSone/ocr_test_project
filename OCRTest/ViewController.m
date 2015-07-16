//
//  ViewController.m
//  OCRTest
//
//  Created by Kyaw Myint Thein on 7/15/15.
//  Copyright (c) 2015 com.acps. All rights reserved.
//

#import "ViewController.h"
#import <TesseractOCR/TesseractOCR.h>
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController
 
- (void)viewDidLoad {
    [super viewDidLoad];
    [self storeLanguageFile];
//    [self scanImage:[UIImage imageNamed:@"images.jpeg"]];
    G8Tesseract* tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];

    tesseract.delegate = self;
    _imageView.frame = self.view.frame;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;

    //[self setTesseractImage:image];
    


    [tesseract setVariableValue:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" forKey:@"tessedit_char_whitelist"];
     [tesseract setVariableValue:@".,:;'" forKey:@"tessedit_char_blacklist"];
    [tesseract setImage:_imageView.image]; //image to check
    [tesseract setRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)]; //optional: set the rectangle to recognize text in the image
    [tesseract recognize];
   
    NSLog(@"Text %@", [tesseract recognizedText]);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 300, 200)];
    label.textColor = [UIColor redColor];
    label.text = [tesseract recognizedText];
    [self.view addSubview:label];
    NSArray *characterBoxes = [tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelSymbol];
    NSLog(@"characterBoxes:%@", characterBoxes);
    
    NSArray *paragraphs = [tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelParagraph];
    NSLog(@"paragraphs:%@", paragraphs);
    
    NSArray *characterChoices = tesseract.characterChoices;
    NSLog(@"characterChoices:%@", characterChoices);
    
//    tesseract = nil; //deallocate and free all memory
    // Do any additional setup after loading the view, typically from a nib.
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract*)tesseract
{
    NSLog(@"progress: %lu", (unsigned long)tesseract.progress);

    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}
- (void)storeLanguageFile {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [docsDirectory stringByAppendingPathComponent:@"/tessdata/eng.traineddata"];
    if(![fileManager fileExistsAtPath:path])
    {
        NSData *data = [NSData dataWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/tessdata/eng.traineddata"]];
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:[docsDirectory stringByAppendingPathComponent:@"/tessdata"] withIntermediateDirectories:YES attributes:nil error:&error];
        [data writeToFile:path atomically:YES];
    }
}

- (NSString *)scanImage:(UIImage *)image {
    
    G8Tesseract *tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
    
    [tesseract setVariableValue:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" forKey:@"tessedit_char_whitelist"];
    [tesseract setVariableValue:@".,:;'" forKey:@"tessedit_char_blacklist"];
    
    if (image) {
        [tesseract setImage:image];
        [tesseract setRect:CGRectMake(0, 25, image.size.width, 50)];
        [tesseract recognize];
        return [tesseract recognizedText];
    }
    return nil;
}

- (void)ocrProcessingFinished:(NSString *)result
{

    [[[UIAlertView alloc] initWithTitle:@"Tesseract Sample"
                                message:[NSString stringWithFormat:@"Recognized:\n%@", result]
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}


@end
