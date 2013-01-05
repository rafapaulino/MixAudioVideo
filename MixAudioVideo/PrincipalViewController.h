//
//  PrincipalViewController.h
//  MixAudioVideo
//
//  Created by Rafael Brigagão Paulino on 24/09/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>

@interface PrincipalViewController : UIViewController

-(IBAction)mixarClicado:(id)sender;

-(void)elaborarComposicao;
-(void)tocarVideo:(NSString*)pathVideo;

@end
