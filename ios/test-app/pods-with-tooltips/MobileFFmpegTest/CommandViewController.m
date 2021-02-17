//
// CommandViewController.m
//
// Copyright (c) 2018 Taner Sener
//
// This file is part of MobileFFmpeg.
//
// MobileFFmpeg is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// MobileFFmpeg is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with MobileFFmpeg.  If not, see <http://www.gnu.org/licenses/>.
//

#import <mobileffmpeg/MobileFFmpegConfig.h>
#import <mobileffmpeg/MobileFFmpeg.h>
#import <mobileffmpeg/MobileFFprobe.h>
#import "CommandViewController.h"
#import "RCEasyTipView.h"

@interface CommandViewController ()

@property (strong, nonatomic) IBOutlet UILabel *header;
@property (strong, nonatomic) IBOutlet UITextField *commandText;
@property (strong, nonatomic) IBOutlet UIButton *runFFmpegButton;
@property (strong, nonatomic) IBOutlet UIButton *runFFprobeButton;
@property (strong, nonatomic) IBOutlet UITextView *outputText;

@end

@implementation CommandViewController {

    // Tooltip view reference
    RCEasyTipView *tooltip;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // STYLE UPDATE
    [Util applyEditTextStyle: self.commandText];
    [Util applyButtonStyle: self.runFFmpegButton];
    [Util applyButtonStyle: self.runFFprobeButton];
    [Util applyOutputTextStyle: self.outputText];
    [Util applyHeaderStyle: self.header];

    // TOOLTIP INIT
    RCEasyTipPreferences *preferences = [[RCEasyTipPreferences alloc] initWithDefaultPreferences];
    [Util applyTooltipStyle: preferences];
    preferences.drawing.arrowPostion = Top;
    preferences.animating.showDuration = 1.0;
    preferences.animating.dismissDuration = COMMAND_TEST_TOOLTIP_DURATION;
    preferences.animating.dismissTransform = CGAffineTransformMakeTranslation(0, -15);
    preferences.animating.showInitialTransform = CGAffineTransformMakeTranslation(0, -15);

    tooltip = [[RCEasyTipView alloc] initWithPreferences:preferences];
    tooltip.text = COMMAND_TEST_TOOLTIP_TEXT;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self setActive];
    });
}

- (NSString*)getAudioOutputFilePath {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [[docFolder stringByAppendingPathComponent: @"result."] stringByAppendingString: @"mp4"];
}

- (NSString*)getAudioSamplePath {
    NSString* docFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [docFolder stringByAppendingPathComponent: @"original.mp4"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)logCallback:(long)executionId :(int)level :(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendOutput: message];
    });
}

- (IBAction)runFFmpegAction:(id)sender {
    [self hideTooltip];

    [self clearOutput];
    
    [[self commandText] endEditing:TRUE];
    
    NSString *ffmpegCommand = [NSString stringWithFormat:@"-hide_banner %@", [[self commandText] text]];
    
    NSLog(@"Current log level is %d.\n", [MobileFFmpegConfig getLogLevel]);

    NSLog(@"Testing FFmpeg COMMAND synchronously.\n");
    
    NSLog(@"FFmpeg process started with arguments\n\'%@\'\n", ffmpegCommand);
    
    // EXECUTE
    int result = [MobileFFmpeg execute:ffmpegCommand];
    
    NSLog(@"FFmpeg process exited with rc %d\n", result);

    if (result != RETURN_CODE_SUCCESS) {
        [Util alert:self withTitle:@"Error" message:@"Command failed. Please check output for the details." andButtonText:@"OK"];
    }
}

- (IBAction)runFFmpegAudioAction:(id)sender {
    [self hideTooltip];

    [self clearOutput];
    
    [[self commandText] endEditing:TRUE];
    
    NSString *audioSampleFile = [self getAudioSamplePath];
    NSString *audioOutputFile = [self getAudioOutputFilePath];
//    NSString *ffmpegCommand = [NSString stringWithFormat:@"-hide_banner -y -i %@ -filter_complex \"rubberband=pitch=1.5\" %@", audioSampleFile, audioOutputFile];
    
//    NSString *ffmpegCommand = [NSString stringWithFormat:@"-hide_banner -y -i %@  -filter_complex \"sofalizer=sofa=temp/hrtf c_nh877.sofa:type=freq:radius=1\" %@", audioSampleFile, audioOutputFile];
    
    NSString *ffmpegCommand = [NSString stringWithFormat:@"-hide_banner -y -i %@ -af \"pan=mono|c0<c0-c1\" %@", audioSampleFile, audioOutputFile];
    
//    NSString *ffmpegCommand = [NSString stringWithFormat:@"-hide_banner -y -i %@ -af \"superequalizer=1b=10:2b=10:3b=1:4b=5:5b=7:6b=5:7b=2:8b=3:9b=4:10b=5:11b=6:12b=7:13b=8:14b=8:15b=9:16b=9:17b=10:18b=10[a];[a]loudnorm=I=-16:TP=-1.5:LRA=14\" -ar 48k %@", audioSampleFile, audioOutputFile];
    
    NSLog(@"Current log level is %d.\n", [MobileFFmpegConfig getLogLevel]);

    NSLog(@"Testing FFmpeg COMMAND synchronously.\n");
    
    NSLog(@"FFmpeg process started with arguments\n\'%@\'\n", ffmpegCommand);
    
    // EXECUTE
    int result = [MobileFFmpeg execute:ffmpegCommand];
    
    NSLog(@"FFmpeg process exited with rc %d\n", result);

    if (result != RETURN_CODE_SUCCESS) {
        [Util alert:self withTitle:@"Error" message:@"Command failed. Please check output for the details." andButtonText:@"OK"];
    }
}

- (IBAction)runFFprobeAction:(id)sender {
    [self hideTooltip];

    [self clearOutput];
    
    [[self commandText] endEditing:TRUE];
    
    NSString *ffprobeCommand = [NSString stringWithFormat:@"-hide_banner %@", [[self commandText] text]];
    
    NSLog(@"Testing FFprobe COMMAND synchronously.\n");
    
    NSLog(@"FFprobe process started with arguments\n\'%@\'\n", ffprobeCommand);
    
    // EXECUTE
    int result = [MobileFFprobe execute:ffprobeCommand];
    
    NSLog(@"FFprobe process exited with rc %d\n", result);

    if (result != RETURN_CODE_SUCCESS) {
        [Util alert:self withTitle:@"Error" message:@"Command failed. Please check output for the details." andButtonText:@"OK"];
    }
}

- (void)setActive {
    [MobileFFmpegConfig setLogDelegate:self];
    [self hideTooltip];
    [self showTooltip];
}

- (void)hideTooltip {
    [tooltip dismissWithCompletion:nil];
}

- (void)showTooltip {
    [tooltip showAnimated:YES forView:self.commandText withinSuperView:self.view];
}

- (void)clearOutput {
    [[self outputText] setText:@""];
}

- (void)appendOutput:(NSString*) message {
    self.outputText.text = [self.outputText.text stringByAppendingString:message];
    
    if (self.outputText.text.length > 0 ) {
        NSRange bottom = NSMakeRange(self.outputText.text.length - 1, 1);
        [self.outputText scrollRangeToVisible:bottom];
    }
}

@end
