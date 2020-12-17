//
//  GameScene.swift
//  IOSProject
//
//  Created by Todd, Winship Merritt on 12/2/20.
//

import SpriteKit
import GameplayKit

enum CollisionType: UInt32 {
    case player = 1
    case playerWeapon = 2
    case enemy = 4
    case strongEnemy = 8
    case fastEnemy = 16
    case asteroid = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var startTouch = CGPoint()
    var playerPosition = CGPoint()
    
    var shotTimer: Timer? = nil
    var shotCooldown = 0.5
    
    var enemyTimer: Timer? = nil
    var enemySpawnTime = 3
    
    var asteroidTimer: Timer? = nil
    var asteriodSpawnTime = 6
    
    var playerHealth = 200
    var playerShotDamage = 30
    var playerShotSpeed = 3
    let player = SKSpriteNode(imageNamed: "player")
    
    var background = SKSpriteNode()
    var play = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        print("Frame width: \(self.frame.width) Frame height: \(self.frame.height)")
        print("minX: \(self.frame.minX) maxX: \(self.frame.maxX)")
        print("miny: \(self.frame.minY) maxY: \(self.frame.maxY)")
        
        

        startGame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isPaused == true {
            startGame()
        } else {
        //gather touch location for player movement
            let touch = touches.first
            if let location = touch?.location(in: self) {
                startTouch = location
                playerPosition = player.position
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Move player character along the x axis
        let touch = touches.first
        if let location = touch?.location(in: self) {
            player.run(SKAction.move(to: CGPoint(x:  playerPosition.x + location.x - startTouch.x, y: player.position.y), duration: 0.1))
        }
    }
    
    //Detect Collisions
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        let enemy: Enemy
        let fastEnemy: FastEnemy
        let strongEnemy: StrongEnemy
        
        //enemy has been contacted
        if contact.bodyA.categoryBitMask == CollisionType.enemy.rawValue || contact.bodyB.categoryBitMask == CollisionType.enemy.rawValue {
            
            if contact.bodyA.categoryBitMask == CollisionType.enemy.rawValue {
                enemy = contact.bodyA.node as! Enemy
            } else if contact.bodyB.categoryBitMask == CollisionType.enemy.rawValue {
                enemy = contact.bodyB.node as! Enemy
            } else {
                return
            }
            
            print("enemy hit")
            
            enemy.health -= playerShotDamage
            if enemy.health <= 0 {
                //enemy health = 0 and both enemy and player shot is destroyed
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
                
                
                //update score
                score += enemy.score
            } else {
                //enemy is still alive and only the shot is destroyed
                contact.bodyA.categoryBitMask == CollisionType.playerWeapon.rawValue ? contact.bodyA.node?.removeFromParent() : contact.bodyB.node?.removeFromParent()
            }
        }
        
        if (contact.bodyA.categoryBitMask == CollisionType.fastEnemy.rawValue && contact.bodyB.categoryBitMask == CollisionType.playerWeapon.rawValue) || (contact.bodyB.categoryBitMask == CollisionType.fastEnemy.rawValue && contact.bodyA.categoryBitMask == CollisionType.playerWeapon.rawValue) {
            
            if contact.bodyA.categoryBitMask == CollisionType.enemy.rawValue {
                fastEnemy = contact.bodyA.node as! FastEnemy
            } else if contact.bodyB.categoryBitMask == CollisionType.enemy.rawValue {
                fastEnemy = contact.bodyB.node as! FastEnemy
            } else {
                return
            }
            
            print("enemy hit")
            
            fastEnemy.health -= playerShotDamage
            if fastEnemy.health <= 0 {
                //enemy health = 0 and both enemy and player shot is destroyed
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
                
                
                //update score
                score += fastEnemy.score
            } else {
                //enemy is still alive and only the shot is destroyed
                contact.bodyA.categoryBitMask == CollisionType.playerWeapon.rawValue ? contact.bodyA.node?.removeFromParent() : contact.bodyB.node?.removeFromParent()
            }
        }
        
        if (contact.bodyA.categoryBitMask == CollisionType.strongEnemy.rawValue && contact.bodyB.categoryBitMask == CollisionType.playerWeapon.rawValue) || (contact.bodyB.categoryBitMask == CollisionType.strongEnemy.rawValue && contact.bodyA.categoryBitMask == CollisionType.playerWeapon.rawValue) {
            
            if contact.bodyA.categoryBitMask == CollisionType.strongEnemy.rawValue {
                strongEnemy = contact.bodyA.node as! StrongEnemy
            } else if contact.bodyB.categoryBitMask == CollisionType.enemy.rawValue {
                strongEnemy = contact.bodyB.node as! StrongEnemy
            } else {
                return
            }
            
            print("enemy hit")
            
            strongEnemy.health -= playerShotDamage
            if strongEnemy.health <= 0 {
                //enemy health = 0 and both enemy and player shot is destroyed
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
                
                
                //update score
                score += strongEnemy.score
            } else {
                //enemy is still alive and only the shot is destroyed
                contact.bodyA.categoryBitMask == CollisionType.playerWeapon.rawValue ? contact.bodyA.node?.removeFromParent() : contact.bodyB.node?.removeFromParent()
            }
        }
        
        //player colliddes with something
        if contact.bodyA.categoryBitMask == CollisionType.player.rawValue || contact.bodyB.categoryBitMask == CollisionType.player.rawValue {

            //if anything enemy or asteroid
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            gameOver()
        }
    }
    
    func playerShotTimerSetup() {
        shotTimer = Timer.scheduledTimer(withTimeInterval: shotCooldown, repeats: true, block: { (shotTimer) in
            let shot = SKSpriteNode(imageNamed: "laser-bullet")
            shot.name = "laser-bullet"
            shot.position.x = self.player.position.x
            shot.position.y = self.player.position.y
            //shot.zPosition = 1
            
            
            shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
            shot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
            shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.fastEnemy.rawValue | CollisionType.strongEnemy.rawValue
            shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.fastEnemy.rawValue | CollisionType.strongEnemy.rawValue
            shot.physicsBody?.affectedByGravity = false
            self.addChild(shot)
            
            let movement = SKAction.move(to: CGPoint(x: shot.position.x, y: self.frame.maxY + self.player.size.height / 2), duration: TimeInterval(self.playerShotSpeed))
            let sequence = SKAction.sequence([movement, .removeFromParent()])
            shot.run(sequence)
        })
    }
    
    func enemySpawnTimer() {
        enemyTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(enemySpawnTime), repeats: true, block: { (enemySpawnTime) in
            
            let randNum = Int.random(in: 1...3)
            
            
            if randNum == 1 {
                let enemy = Enemy(health: 100, damage: 20)
                
                let minRandX = Int(self.frame.minX + enemy.size.width)
                let maxRandX = Int(self.frame.maxX - enemy.size.width)
                let randX = CGFloat(Int.random(in: minRandX...maxRandX))
                
                enemy.position = CGPoint(x: randX, y: self.frame.maxY + enemy.size.height)
        //        //enemy.zPosition = 1
                enemy.zRotation = .pi
                self.addChild(enemy)
                
                let movement = SKAction.move(to: CGPoint(x: enemy.position.x, y: self.frame.minY - enemy.size.height / 2), duration: TimeInterval(enemy.enemySpeed))
                let sequence = SKAction.sequence([movement, .removeFromParent()])
                enemy.run(sequence)
            } else if randNum == 2 {
                let enemy = FastEnemy(health: 60, damage: 15)
                
                let minRandX = Int(self.frame.minX + enemy.size.width)
                let maxRandX = Int(self.frame.maxX - enemy.size.width)
                let randX = CGFloat(Int.random(in: minRandX...maxRandX))
                
                enemy.position = CGPoint(x: randX, y: self.frame.maxY + enemy.size.height)
        //        //enemy.zPosition = 1
                enemy.zRotation = .pi
                self.addChild(enemy)
                
                let movement = SKAction.move(to: CGPoint(x: enemy.position.x, y: self.frame.minY - enemy.size.height / 2), duration: TimeInterval(enemy.enemySpeed))
                let sequence = SKAction.sequence([movement, .removeFromParent()])
                enemy.run(sequence)
            } else {
                let enemy = StrongEnemy(health: 200, damage: 35)
                
                let minRandX = Int(self.frame.minX + enemy.size.width)
                let maxRandX = Int(self.frame.maxX - enemy.size.width)
                let randX = CGFloat(Int.random(in: minRandX...maxRandX))
                
                enemy.position = CGPoint(x: randX, y: self.frame.maxY + enemy.size.height)
        //        //enemy.zPosition = 1
                enemy.zRotation = .pi
                self.addChild(enemy)
                
                let movement = SKAction.move(to: CGPoint(x: enemy.position.x, y: self.frame.minY - enemy.size.height / 2), duration: TimeInterval(enemy.enemySpeed))
                let sequence = SKAction.sequence([movement, .removeFromParent()])
                enemy.run(sequence)
            }
        })
    }
    
    func asteroidSpawnTimer() {
            asteroidTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(asteriodSpawnTime), repeats: true, block: { (asteroidSpawnTime) in
            
                let asteroid = SKSpriteNode(imageNamed: "asteroid")
                
                asteroid.name = "asteroid"
                asteroid.size = CGSize(width: 75, height: 75)
                asteroid.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(asteroid.size.height / 2))
                asteroid.physicsBody?.categoryBitMask = CollisionType.asteroid.rawValue
                asteroid.physicsBody?.collisionBitMask = CollisionType.player.rawValue
                asteroid.physicsBody?.contactTestBitMask = CollisionType.player.rawValue
                asteroid.physicsBody?.isDynamic = false
                
                let minRandX = Int(self.frame.minX - asteroid.size.width)
                let maxRandX = Int(self.frame.maxX + asteroid.size.width)
                var randX = CGFloat(Int.random(in: minRandX...maxRandX))
                
                asteroid.position = CGPoint(x: randX, y: self.frame.maxY + asteroid.size.height)
                self.addChild(asteroid)
                
                randX = CGFloat(Int.random(in: minRandX...maxRandX))
                let movement = SKAction.move(to: CGPoint(x: randX, y: self.frame.minY - asteroid.size.height / 2), duration: TimeInterval(4))
                let sequence = SKAction.sequence([movement, .removeFromParent()])
                asteroid.run(sequence)
        })
    }
    
    func startGame() {
        self.removeAllChildren()
        //Add player
        player.position = CGPoint(x: frame.midX, y: frame.minY + 200)
        player.name = "player"
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: (player.texture?.size())!)
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.fastEnemy.rawValue | CollisionType.strongEnemy.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.fastEnemy.rawValue | CollisionType.strongEnemy.rawValue
        player.physicsBody?.affectedByGravity = false
        addChild(player)
        
        //add score
        scoreLabel.fontSize = 30
        scoreLabel.position = CGPoint(x: frame.minX + 150, y: frame.maxY - 80)
        score = 0
        addChild(scoreLabel)
        
        //add background
        background = SKSpriteNode(imageNamed: "space bg")
        background.zPosition = -1
        addChild(background)
        
        play = SKSpriteNode(imageNamed: "play")
        play.size = CGSize(width: 200, height: 100)
        play.zPosition = 1
        play.isHidden = true
        addChild(play)
        
        self.isPaused = false
        
        playerShotTimerSetup()
        enemySpawnTimer()
        asteroidSpawnTimer()
    }
    
    func gameOver() {
        self.isPaused = true
        shotTimer?.invalidate()
        shotTimer = nil
        enemyTimer?.invalidate()
        enemyTimer = nil
        asteroidTimer?.invalidate()
        asteroidTimer = nil
        play.isHidden = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
}
