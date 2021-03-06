//
//  FastEnemy.swift
//  IOSProject
//
//  Created by Todd, Winship Merritt on 12/17/20.
//

import SpriteKit

class FastEnemy: SKSpriteNode {
    
    var health: Int
    var damage: Int
    var enemySpeed = 6
    var score = 35
    
    init(health: Int, damage: Int) {
        self.health = health
        self.damage = damage
        
        let texture = SKTexture(imageNamed: "enemy2")
        super.init(texture: texture, color: .white, size: texture.size())
        name = "enemy2"
        physicsBody = SKPhysicsBody(texture: texture, size: (texture.size()))
        physicsBody?.categoryBitMask = CollisionType.fastEnemy.rawValue
        physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        physicsBody?.isDynamic = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
