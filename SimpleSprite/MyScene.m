//
//  MyScene.m
//  SimpleSprite
//
//  Created by Ian Walker-Sperber on 2/14/14.
//  Copyright (c) 2014 Ian Walker-Sperber. All rights reserved.
//

@import CoreMotion;
#import "MyScene.h"
#import "FMMParallaxNode.h"

@implementation MyScene
{
    SKSpriteNode *_ship;
    CMMotionManager *_motionManager;
    FMMParallaxNode *_parallaxNodeBackgrounds;
    FMMParallaxNode *_parallaxSpaceDust;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        NSLog(@"SKScene:initWithSize %f x %f",size.width,size.height);
        
        self.backgroundColor = [SKColor blackColor];
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];

#pragma mark - TBD - Game Backgrounds
        
        // Back backgrounds
        
        NSArray *parallaxBackgroundNames = @[@"bg_galaxy.png",
                                             @"bg_planetsunrise.png",
                                             @"bg_spaciaanomaly2.png"];
        
        CGSize planetSizes = CGSizeMake(200.0, 200.0);
        
        _parallaxNodeBackgrounds = [[FMMParallaxNode alloc]
                                    initWithBackgrounds:parallaxBackgroundNames
                                    size:planetSizes pointsPerSecondSpeed:10.0];
        
        _parallaxNodeBackgrounds.position = CGPointMake(size.width/2.0,
                                                        size.height/2.0);
        
        [_parallaxNodeBackgrounds randomizeNodesPositions];
        
        [self addChild:_parallaxNodeBackgrounds];
        
        // Front backgrounds
        
        NSArray *parallaxBackground2Names = @[@"bg_front_spacedust.png", @"bg_front_spacedust.png"];
        
        _parallaxSpaceDust = [[FMMParallaxNode alloc] initWithBackgrounds:parallaxBackground2Names size:size pointsPerSecondSpeed:25.0];
        
        _parallaxSpaceDust.position = CGPointMake(0, 0);
        
        [self addChild:_parallaxSpaceDust];
        
#pragma mark - Setup Sprite for the ship
        //Create space sprite, setup position on left edge centered on the screen, and add to Scene
        
        _ship = [SKSpriteNode spriteNodeWithImageNamed:@"SpaceFlier_sm_1.png"];
        _ship.position = CGPointMake(self.frame.size.width * 0.1, CGRectGetMidY(self.frame));
        
        _ship.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_ship.frame.size];
        
        _ship.physicsBody.dynamic = YES;
        
        _ship.physicsBody.affectedByGravity = NO;
        
        _ship.physicsBody.mass = 0.02;
        
        [self addChild:_ship];
        
#pragma mark - TBD - Setup the asteroids
        
#pragma mark - TBD - Setup the lasers
        
#pragma mark - TBD - Setup the Accelerometer to move the ship
        
        _motionManager = [[CMMotionManager alloc] init];
        
#pragma mark - TBD - Setup the stars to appear as particles
        
        [self addChild:[self loadEmitterNode:@"stars1"]];
        [self addChild:[self loadEmitterNode:@"stars2"]];
        [self addChild:[self loadEmitterNode:@"stars3"]];
        
#pragma mark - TBD - Start the actual game
        
        [self startTheGame];
    }
    
    return self;
}

-(void)update:(CFTimeInterval)currentTime
{
    [_parallaxSpaceDust update:currentTime];
    [_parallaxNodeBackgrounds update:currentTime];
    
    [self updateShipPositionFromMotionManager];
}

- (void) startTheGame
{
    _ship.hidden = NO;
    
    _ship.position = CGPointMake(self.frame.size.width * 0.1, CGRectGetMidY(self.frame));
    
    [self startMonitoringAcceleration];
}

- (void) startMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable) {
        [_motionManager startAccelerometerUpdates];
        NSLog(@"Accelerometer updates on...");
    }
}

- (void) stopMonitoringAcceleration
{
    if (_motionManager.accelerometerAvailable
        && _motionManager.accelerometerActive) {
        [_motionManager startAccelerometerUpdates];
        NSLog(@"accelerometer updates off...");
    }
}

- (void) updateShipPositionFromMotionManager
{
    CMAccelerometerData *data = _motionManager.accelerometerData;
    if (fabs(data.acceleration.x) > 0.2) {
        [_ship.physicsBody applyForce:CGVectorMake(0.0, 40.0 * data.acceleration.x)];
    }
}

- (SKEmitterNode *)loadEmitterNode:(NSString *)emitterFileName
{
    NSString *emitterPath = [[NSBundle mainBundle] pathForResource:emitterFileName ofType:@"sks"];
    SKEmitterNode *emitterNode = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    
    // View tweaks
    
    emitterNode.particlePosition = CGPointMake(self.size.width/2.0, self.size.height/2.0);
    emitterNode.particlePositionRange = CGVectorMake(self.size.width + 100, self.size.height);
    [emitterNode setEmissionAngle:M_2_PI];
    
    return emitterNode;
}

@end
