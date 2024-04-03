//
//  GameScene.swift
//  Mastermind - Secret Code Shared
//
//  Created by Gyöngyösi Máté on 13/03/2024.
//

import SpriteKit

class GameScene: SKScene {
    
    
    fileprivate var label : SKLabelNode?
    fileprivate var spinnyNode : SKShapeNode?

    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        self.backgroundColor = .lightGray
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 4.0
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        let solutionCover = SKSpriteNode(imageNamed: "solution_cover")
        solutionCover.position = CGPoint(x: 0, y: 1000)
        self.addChild(solutionCover)
        
        let doneButtonBg = SKSpriteNode(imageNamed: "done_button_bg")
        let doneButton = SKSpriteNode(imageNamed: "done_button")
        doneButtonBg.position = CGPoint(x: 460, y: -740)
        doneButton.position = CGPoint(x: 460, y: -740)
        doneButtonBg.zPosition = 5
        doneButton.zPosition = 6
        self.addChild(doneButtonBg)
        self.addChild(doneButton)
        doneButton.alpha = 0.75
        
        let highlighterCircle = SKSpriteNode(imageNamed: "hole_selected")
        highlighterCircle.position = CGPoint(x: -270, y: -740)
        self.addChild(highlighterCircle)
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    func makeSpinny(at pos: CGPoint, color: SKColor) {
        if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
            spinny.position = pos
            spinny.strokeColor = color
            self.addChild(spinny)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

enum usedColors: String {
    case red = "red"
    case green = "green"
    case orange = "orange"
    case blue = "blue"
    case yellow = "yellow"
    case purple = "purple"
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.green)
            
            let location = t.location(in: self)
            let touchedNode = nodes(at: location)[1]
            if touchedNode.name != nil && (usedColors(rawValue: touchedNode.name!) != nil) {
                let newCircle = SKSpriteNode(imageNamed: "circle_\(touchedNode.name!)")
                newCircle.position = CGPoint(x: -270, y: -740)
                newCircle.zPosition = 10
                self.addChild(newCircle)
                
//                highlight
            } else {
                break
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        self.makeSpinny(at: event.location(in: self), color: SKColor.green)
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.red)
    }

}
#endif

