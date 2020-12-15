//
//  PowerUp.swift
//  IOSProject
//
//  Created by Todd, Winship Merritt on 12/15/20.
//

import SpriteKit

class PowerUp: SKSpriteNode {
    let attackSpeendIncrease = Int(-0.2)
    
    init() {
        
        let texture = SKTexture(imageNamed: "powerUp")
        super.init(texture: texture, color: .white, size: texture.size())
        name = "powerUp"
        physicsBody = SKPhysicsBody(texture: texture, size: (texture.size()))
        physicsBody?.categoryBitMask = CollisionType.powerUp.rawValue
        physicsBody?.collisionBitMask = CollisionType.player.rawValue
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        physicsBody?.isDynamic = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
