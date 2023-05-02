//
//  GameScene.swift
//  Project11
//
//  Created by Brandon Johns on 4/29/23.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate
{
    
    var scoreLabel: SKLabelNode!
    
    var score = 0
    {
        didSet
        {
            scoreLabel.text = "Score: \(score)"
        }//didSet
    }//score
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false
    {
        didSet
        {
            if editingMode
            {
                editLabel.text = "Done"
            }//if
            else
            {
                editLabel.text = "Edit"
            }//else
        }//didSet
    }//editMode
    
    override func didMove(to view: SKView)
    {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed:  "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)                                                //falling effect
        physicsWorld.contactDelegate = self
        
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
   
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}                                                   // find first touch on screen
        let location = touch.location(in: self)                                                         // find the touch
        
        
        let objects = nodes(at: location)                                                               // scene parent class
        
        
        if objects.contains(editLabel)                                                                  //tapeed edit
        {
            editingMode.toggle()                                                                        // True = false or False = true
        }// if
        else
        {
            if editingMode                                                                              //create box
            {
                let size = CGSize(width: Int.random(in: 16...128), height: 16)                          //size of box
                
                
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                                                                                                        // random color of box
                                                                                                        // using size created
                
                box.zRotation = CGFloat.random(in: 0...3)                                               // rotate boxes
                box.position = location                                                                 // place boxes where tapped
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)                                  // balls can bounce off box
                box.physicsBody?.isDynamic = false                                                      //boxes cannot move
                addChild(box)
                
            }// if editingMode
            else                                                                                        //create ball
            {
                let ball = SKSpriteNode(imageNamed: "ballRed")
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)                 // behaves as a ball
                ball.physicsBody?.restitution = 0.4                                                     // bouncyness
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0          // collisionBitMask == what nodes to bump into
                                                                                                        // contactTestBitMask == which collisions do we want to know about
                                                                                                        //                       default set to nothing
                ball.position = location
                ball.name = "ball"
                addChild(ball)
                
            } //else create ball
            
        }// else editing mode
        
    }//touchesBegan
    
    func makeBouncer(at position: CGPoint)
    {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false                                                          // true= object moves physics(gravity and simulation)
                                                                                                        // false object still collides but does not move
                                                                                                        // bouncer does not move as a result of the phyics
                                                                                                        // balls still move
        addChild(bouncer)
    }// makeBouncer
    
    func makeSlot(at position: CGPoint, isGood: Bool)
    {
        
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood
        {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        }// end if
        else
        {
            slotBase = SKSpriteNode(imageNamed:  "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }//end else
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false                                                         // doesnt move when hit
        
        
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
        
    }// makeSlot
   
                                                                                                    // SKNode is parent class of SKSpriteNode
    func collision(between ball: SKNode, object: SKNode)                                            // SKNode in this func doesnt care which kind of node
    {
        if object.name == "good"
        {
            destory(ball: ball)
            score += 1
        }//end if
        else if object.name == "bad"
        {
            destory(ball: ball)
            score -= 1
        } // end if else
        
        
    }//end collision
    
    func destory(ball: SKNode)
    {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles")                           // effects call the file name
        {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
            
        
        ball.removeFromParent()                                                                     // removes node from node tree
    
    }//end destory
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if contact.bodyA.node?.name == "ball"                                                       // first contact == ball
        {
            collision(between: contact.bodyA.node!, object: nodeB)                                  // bodyA = ball what it hits is bodyB
                                                                                                    // first time code is ran it force unwraps ball and removes it
        }//end if
        else if contact.bodyB.node?.name == "ball"
        {
            collision(between: contact.bodyB.node!, object: nodeA)                                  // bodyB = ball what it hits is bodyA
        }//end else if
    }//didBegin
    
}















/* falling red box
 override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
     guard let touch = touches.first else {return}                                                   // find first touch on screen
     let location = touch.location(in: self)                                                         // find the touch
     
     
     let box = SKSpriteNode(color: .red, size: CGSize(width: 64, height: 64))                        // creates box when tapped
     box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height:  64 ))                   // creates the falling box effect
     box.position = location                                                                         // location of box on screen
     addChild(box)
 }
 */
