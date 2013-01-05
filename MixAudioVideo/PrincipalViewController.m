//
//  PrincipalViewController.m
//  MixAudioVideo
//
//  Created by Rafael Brigagão Paulino on 24/09/12.
//  Copyright (c) 2012 rafapaulino.com. All rights reserved.
//

#import "PrincipalViewController.h"

@interface PrincipalViewController ()
{
    //Objeto responsavel por pegar a minha composition e criar um arquivo de video em um formato conhecido, que posso paasar mais tarde para um player executar
    AVAssetExportSession *exportador;
}

@end

@implementation PrincipalViewController

-(IBAction)mixarClicado:(id)sender
{
    //disparando em uma nova thread
    //elaboracaodo mix audio e video pode demorar alguns miutos por isso disparamos o processo em uma thread secundaria
    [NSThread detachNewThreadSelector:@selector(elaborarComposicao) toTarget:self withObject:nil];
}

-(void)elaborarComposicao
{
    //localizar os arquivos de audio e video
    NSString *pathVideo = [[NSBundle mainBundle] pathForResource:@"filme" ofType:@"mov"];
    NSString *pathAudio = [[NSBundle mainBundle] pathForResource:@"Paradise" ofType:@"m4a"];
    
    
    AVURLAsset *urlAudio = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:pathAudio] options:nil];
    AVURLAsset *urlVideo = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:pathVideo] options:nil];
    
    //composition vazia
    AVMutableComposition *composicao = [AVMutableComposition composition];
    
    //trilha de audio
    AVMutableCompositionTrack *trilhaAudio = [composicao addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    //quando nao quiser identificar a track passa o kCMPersistentTrackID_Invalid como parametro
    
    //criando o asset track
    AVAssetTrack *audioTrack = [[urlAudio tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    
    //inserttime range momento da muscia onde vou comecar a inserir na composicao
    //offtrack e a trilha da musica que queremos adicionar a essa trilha da composicao
    
    
    [trilhaAudio insertTimeRange:CMTimeRangeMake(kCMTimeZero, urlAudio.duration) ofTrack:audioTrack atTime:CMTimeMake(1,1) error:nil];
    
    //trilha de video
        AVMutableCompositionTrack *trilhaVideo = [composicao addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    //neste momento que esrtou pegando apenas as imagens do video descartando o audio
    AVAssetTrack *videoTrack = [[urlVideo  tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //cmtimemake -> divide o primeiro valor pelo segundo parater como resultado o tempo em segfundos para a insercao na composicao
    [trilhaVideo insertTimeRange:CMTimeRangeMake(kCMTimeZero, urlVideo.duration) ofTrack:videoTrack atTime:CMTimeMake(1, 1) error:nil];
    
    //efetivamente criar uma composicao e exportar para um arquivo de video
    
    //definir onde sera salvo o arquivo
    NSString *pathArquivoExportado = [NSHomeDirectory() stringByAppendingString:@"/Documents/videoExportado.mov"];
    
    //verificando se o arquivo ja existe na pasta indicada pela string acima
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathArquivoExportado])
    {
       //apagar o arquivo anterior antes de friar um novo
        [[NSFileManager defaultManager] removeItemAtPath:pathArquivoExportado error:nil];
    }
    
    //estou inicializando o exportador com a composicao que criamos
    exportador = [[AVAssetExportSession alloc] initWithAsset:composicao presetName:AVAssetExportPresetPassthrough];
    
    //passar para o exportador onde sera salvo o arquivo
    exportador.outputURL = [NSURL fileURLWithPath:pathArquivoExportado];
    
    //passar p/o exportador qual o formato do arquivo
    exportador.outputFileType = AVFileTypeQuickTimeMovie;
    
    [exportador exportAsynchronouslyWithCompletionHandler:^{
        //ao final do processo de criacao do video, vamos executá-lo
        
        //lembrete: metodos que lidam com alteracao de interface com o usuario devem ser executados na thred princicpal
        [self performSelectorOnMainThread:@selector(tocarVideo:) withObject:pathArquivoExportado waitUntilDone:NO];
    }];
}

-(void)tocarVideo:(NSString*)pathVideo
{
    MPMoviePlayerViewController *playerView = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:pathVideo]];
    
    [self presentModalViewController:playerView animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
