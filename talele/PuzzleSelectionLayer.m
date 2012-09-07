/*
 * Copyright (c) Maxwell Dayvson <dayvson@gmail.com>
 * Copyright (c) Luiz Adolpho <luiz.adolpho@gmail.com>
 * Created 08/2012
 * All rights reserved.
 */

#import "PuzzleSelectionLayer.h"
#import "GameConstants.h"
#import "GameManager.h"
#import "GameHelper.h"
#import "ImageHelper.h"
#import <MobileCoreServices/UTCoreTypes.h>

@implementation PuzzleSelectionLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	PuzzleSelectionLayer *layer = [PuzzleSelectionLayer node];
	[scene addChild: layer];
	return scene;
}

-(void) loadPlistLevel {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"buttons.plist"];
    sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"buttons.png"];        
}

-(void) onClickHard {
    [[GameManager sharedGameManager] runSceneWithID:kLevelHard];
}

-(void) onClickEasy {
    [[GameManager sharedGameManager] runSceneWithID:kLevelEasy];
}

-(void) onClickPrevPuzzle {
    [puzzleGrid gotoPrevPage];
}

-(void) onClickNextPuzzle {
    [puzzleGrid gotoNextPage];
}

-(void) onClickPhotoSelection {
    [self showPhotoLibrary];
}

-(CCMenuItemSprite *) createItemBySprite:(NSString *)name andCallback:(SEL)callback{
    CCSprite *itemSprite = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache
                                                                         sharedSpriteFrameCache]
                                                                        spriteFrameByName:name]];
    CCSprite *itemSpriteUp = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache
                                                                   sharedSpriteFrameCache]
                                                                  spriteFrameByName:name]];
    [itemSpriteUp setScale:1.2];
    CCMenuItemSprite *itemMenu = [CCMenuItemSprite itemWithNormalSprite:itemSprite
                                                         selectedSprite:itemSpriteUp target:self selector:callback];
    return itemMenu;
}
-(void) initStartGameButtons {

    CCMenuItemSprite *easyButton = [self createItemBySprite:@"btn-facil.png" andCallback:@selector(onClickEasy)];
    CCMenuItemSprite *hardButton = [self createItemBySprite:@"btn-dificil.png" andCallback:@selector(onClickHard)];
    CCMenu *mainMenu = [CCMenu menuWithItems:easyButton,hardButton, nil];
    [mainMenu alignItemsHorizontallyWithPadding:screenSize.height * 0.059f];
    [mainMenu setPosition: ccp(screenSize.width * 2.0f, screenSize.height / 2.0f)];
    id moveAction = [CCMoveTo actionWithDuration:0.5f 
                                        position:ccp(screenSize.height/2.0f + 140,100)];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    id sequenceAction = [CCSequence actions:moveEffect,nil];
    [mainMenu runAction:sequenceAction];

    mainMenu.anchorPoint = ccp(0,0);
    [self addChild:mainMenu z:7 tag:7];
}

-(void) initNavigationButtons {
    prevButton = [self createItemBySprite:@"btn-voltar.png" andCallback:@selector(onClickPrevPuzzle)];
    nextButton = [self createItemBySprite:@"btn-proximo.png" andCallback:@selector(onClickNextPuzzle)];
    CCMenu *mainMenu = [CCMenu menuWithItems:prevButton,nextButton, nil];
    [mainMenu alignItemsHorizontallyWithPadding:680];
    [mainMenu setPosition: ccp(screenSize.width * 2.0f, screenSize.height / 2.0f)];
    id moveAction = [CCMoveTo actionWithDuration:0.5f 
                                        position:ccp(510 ,
                                        screenSize.height/2.0f )];
    id moveEffect = [CCEaseIn actionWithAction:moveAction rate:1.0f];
    id sequenceAction = [CCSequence actions:moveEffect,nil];
    [mainMenu runAction:sequenceAction];
    [self addChild:mainMenu z:5 tag:5];
}

-(void) initPhotoButton {
    CCMenuItemSprite *pickbutton = [self createItemBySprite:@"btn-foto.png" andCallback:@selector(onClickPhotoSelection)];
    CCMenu *mainMenu = [CCMenu menuWithItems:pickbutton, nil];
    mainMenu.anchorPoint = ccp(0,0);
    mainMenu.position = ccp(screenSize.width - 150 , screenSize.height - 100 );
    [self addChild:mainMenu z:3 tag:3];
}

-(void) initBackground {
	CCSprite *background;
    background = [CCSprite spriteWithFile:@"background-puzzle-selection.png"];
	background.position = ccp(screenSize.width/2, screenSize.height/2);
	[self addChild: background z:1 tag:1];
}
-(void) updateSelectedImage:(CCMenuItemSprite*)sender{
    [[GameManager sharedGameManager] setCurrentPuzzle:(NSString*)sender.userData];
}

-(void) onMoveToCurrentPage:(NSObject*)obj {
    [prevButton setOpacity:(puzzleGrid.currentPage >= 1)? 255 : 30];
    [nextButton setOpacity:(puzzleGrid.currentPage < puzzleGrid.totalPages-1)? 255 : 30];
    [prevButton setIsEnabled:(puzzleGrid.currentPage >= 1)? YES : NO];
    [nextButton setIsEnabled:(puzzleGrid.currentPage < puzzleGrid.totalPages-1)? YES : NO];

    [[GameManager sharedGameManager] setCurrentPuzzle:(NSString*)obj];
    [[GameManager sharedGameManager] setCurrentPage:puzzleGrid.currentPage];
    if([self getChildByTag:40]){
        [self removeChildByTag:40 cleanup:YES];
    }
}

-(void)showEmptyBox{
    CCSprite *itemSprite = [[CCSprite alloc] initWithFile:@"photobg.png"];
    CCMenuItemSprite *itemMenu = [CCMenuItemSprite itemWithNormalSprite:itemSprite selectedSprite:nil
                                                                 target:self selector:@selector(onClickPhotoSelection)];
    CCMenu *emptyMenu = [CCMenu menuWithItems:itemMenu, nil];
    emptyMenu.anchorPoint = ccp(0,0);
    emptyMenu.position = ccp(screenSize.width/2 , screenSize.height/2 );
    [self addChild:emptyMenu z:40 tag:40];    
    [prevButton setIsEnabled:NO];
    [nextButton setIsEnabled:NO];
}

-(void) loadPuzzleImages {
    if(puzzleGrid){
        [self removeChild:puzzleGrid cleanup:YES];
        puzzleGrid = nil;
    }
    NSDictionary* puzzlesInfo = [GameHelper getPlist:@"puzzles"];
    NSMutableArray *arrayNames = [[NSMutableArray alloc] 
                                  initWithArray:[puzzlesInfo objectForKey:@"puzzles"]];
    NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:arrayNames.count];
    for (int i=0; i<arrayNames.count; i++) {
        CCSprite* bg = [[CCSprite alloc] initWithFile:@"photobg.png"];
        CCSprite* img = [CCSprite spriteWithFile:[arrayNames objectAtIndex:i]];
        img.anchorPoint = ccp(0,0);
        img.position = ccp(23,22);
        [img setScale:0.8];
        [bg addChild:img];
        CCMenuItemSprite* item = [[CCMenuItemSprite alloc] initWithNormalSprite:bg
                                                                 selectedSprite:nil
                                                                 disabledSprite:nil
                                                                         target:self
                                                                       selector:@selector(updateSelectedImage:)];
        item.userData = [arrayNames objectAtIndex:i];
        [items addObject:item];
    }
    puzzleGrid = [[PuzzleGrid alloc] initWithArray:items
                                           position:ccp(screenSize.width/2, screenSize.height/2)
                                            padding:CGPointZero];
    [puzzleGrid setSwipeInMenu:YES];
    [puzzleGrid setDelegate:self];
    [puzzleGrid gotoPage:[GameManager sharedGameManager].currentPage];
    if(puzzleGrid.totalPages == 0){
        [self showEmptyBox];
    }
    [self addChild:puzzleGrid z:2 tag:2];
}
-(void) showPhotoLibrary
{
	if (_picker) {
		[_picker dismissModalViewControllerAnimated:NO];
		[_picker.view removeFromSuperview];
		[_picker release];
	}
	if (_popover) {
		[_popover dismissPopoverAnimated:NO];
		[_popover release];
	}
    CCDirector * director =[CCDirector sharedDirector];
	[director stopAnimation];
	_picker = [[[UIImagePickerController alloc] init] retain];
	_picker.delegate = self;
	_picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	_picker.wantsFullScreenLayout = NO;
    _picker.allowsEditing = NO;
	_popover = [[[UIPopoverController alloc] initWithContentViewController:_picker] retain];
    _popover.delegate = self;
	CGRect r = CGRectMake(screenSize.width/2,0,10,10);
	r.origin = [director convertToGL:r.origin];
	[_popover presentPopoverFromRect:r inView:[director view]
            permittedArrowDirections:0 animated:YES];
    _popover.popoverContentSize = CGSizeMake(320, screenSize.width);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[_picker dismissModalViewControllerAnimated:NO];
	[_picker.view removeFromSuperview];
	[_picker release];
	_picker = nil;
	[_popover dismissPopoverAnimated:NO];
	[_popover release];
    _popover = nil;
	[[CCDirector sharedDirector] startAnimation];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self imagePickerControllerDidCancel:nil];
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    CGSize imageSize = CGSizeMake(693, 480);
    if([GameHelper isRetinaIpad]){
        imageSize.width = imageSize.width * 2;
        imageSize.height = imageSize.height * 2;
    }
    UIImage *originalImage;
    originalImage = (UIImage *) [info objectForKey: UIImagePickerControllerOriginalImage];
    originalImage = [ImageHelper cropImage:originalImage toSize:imageSize];
    [[CCDirector sharedDirector] purgeCachedData];
    [picker dismissModalViewControllerAnimated: YES];
    [picker release];
    [_popover dismissPopoverAnimated:YES];
	[[CCDirector sharedDirector] startAnimation];
    [ImageHelper saveImageFromLibraryIntoPuzzlePlist:originalImage];
    [self loadPuzzleImages];
    [puzzleGrid gotoPage:puzzleGrid.totalPages-1];
}

-(void) onEnter{
	[super onEnter];
    screenSize = [[CCDirector sharedDirector] winSize];
    [CCSpriteFrameCache sharedSpriteFrameCache];
    [self loadPlistLevel];
    [self initBackground];
    [self initStartGameButtons];
    [self initNavigationButtons];
    [self initPhotoButton];
    [self loadPuzzleImages];
}

-(void)dealloc {
    [self removeAllChildrenWithCleanup:TRUE];
    [super dealloc];
}

@end
