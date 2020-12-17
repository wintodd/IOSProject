//
//  StrongEnemy.swift
//  IOSProject
//
//  Created by Todd, Winship Merritt on 12/17/20.
//

import SpriteKit

class StrongEnemy: SKSpriteNode {
    
    var health: Int
    var damage: Int
    var enemySpeed = 13
    var score = 80
    
    init(health: Int, damage: Int) {
        self.health = health
        self.damage = damage
        
        let texture = SKTexture(imageNamed: "enemy3")
        super.init(texture: texture, color: .white, size: texture.size())
        name = "enemy3"
        physicsBody = SKPhysicsBody(texture: texture, size: (texture.size()))
        physicsBody?.categoryBitMask = CollisionType.strongEnemy.rawValue
        physicsBody?.collisionBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue | CollisionType.playerWeapon.rawValue
        physicsBody?.isDynamic = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
