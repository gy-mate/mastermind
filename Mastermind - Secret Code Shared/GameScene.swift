//
//  GameScene.swift
//  Mastermind - Secret Code Shared
//
//  Created by Gyöngyösi Máté on 13/03/2024.
//

import SpriteKit

enum usedColors: String, CaseIterable {
    case red = "red"
    case green = "green"
    case orange = "orange"
    case blue = "blue"
    case yellow = "yellow"
    case purple = "purple"
}

class GameScene: SKScene {
    
    let doneButtonBg = SKSpriteNode(imageNamed: "done_button_bg")
    let doneButton = SKSpriteNode(imageNamed: "done_button")
    
    let xValuesOfRow : [Int] = [
        -270,
         -90,
         90,
         270,
    ]
    var yValuesOfRows : [Int] = []
    let highlighterCircle = SKSpriteNode(imageNamed: "hole_selected")
    var currentRowPins : [SKNode?] = []
    
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
    
    func getFourRandomItems(from enumType: usedColors.Type) -> [usedColors] {
        var randomItems: [usedColors] = []
        for _ in 1...4 {
            let randomIndex = Int.random(in: 0..<6)
            randomItems.append(enumType.allCases[randomIndex])
        }
        return randomItems
      }
    
    func setUpScene() {
        self.backgroundColor = .lightGray
        
        let solutions = self.getFourRandomItems(from: usedColors.self)
        let solutionLineY = 790 + 200
        let solutionPositions = [
            CGPoint(x: -270, y: solutionLineY),
            CGPoint(x: -90, y: solutionLineY),
            CGPoint(x: 90, y: solutionLineY),
            CGPoint(x: 270, y: solutionLineY)
        ]
        for (i, solution) in solutions.enumerated() {
            let solutionPin = SKSpriteNode(imageNamed: "circle_\(solution)")
            solutionPin.position = solutionPositions[i]
            self.addChild(solutionPin)
        }
        
        let solutionCover = SKSpriteNode(imageNamed: "solution_cover")
        solutionCover.position = CGPoint(x: 0, y: 1000)
        solutionCover.zPosition = 2
        self.addChild(solutionCover)
        
        doneButtonBg.position = CGPoint(x: 460, y: -740)
        doneButton.position = CGPoint(x: 460, y: -740)
        doneButtonBg.zPosition = 5
        doneButton.zPosition = 6
        self.addChild(doneButtonBg)
        self.addChild(doneButton)
        doneButton.alpha = 0.75
        
        highlighterCircle.position = CGPoint(x: -270, y: -740)
        self.addChild(highlighterCircle)
        
        for i in 0..<10 {
            self.yValuesOfRows.append(-740 + 170 * i)
        }
        
        self.currentRowPins = [SKSpriteNode?](repeating: nil, count: 4)
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    
    fileprivate func createPin(_ name: String) -> SKSpriteNode {
        let newPin = SKSpriteNode(imageNamed: "circle_\(name)")
        newPin.name = name
        return newPin
    }
    
    func insertPin(_ newPinName: String) {
        for (i, hole) in self.currentRowPins.enumerated() {
            if hole == nil {
                let addedPin = createPin(newPinName)
                currentRowPins[i] = addedPin
                addedPin.position = CGPoint(x: xValuesOfRow[i], y: yValuesOfRows[0])
                addedPin.zPosition = 2
                self.addChild(addedPin)
                updateHighlighterCircle()
                break
            }
        }
    }
    
    fileprivate func updateHighlighterCircle() {
        for (i, hole) in self.currentRowPins.enumerated() {
            if (hole == nil && i < 4) {
                highlighterCircle.position = CGPoint(x: xValuesOfRow[i], y: yValuesOfRows[0])
                doneButton.alpha = 0.75
                return
            }
        }
        highlighterCircle.position = CGPoint(x: 460, y: yValuesOfRows[0])
        doneButton.alpha = 1
    }
    
    func removePin(_ pinToRemove: SKNode) {
        pinToRemove.removeFromParent()
        currentRowPins[currentRowPins.firstIndex(of: pinToRemove)!] = nil
        updateHighlighterCircle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        let touchedNodes = nodes(at: location)
        let rowOfPin = touchedNodes.first(where: {$0.name == "colors"})
        let touchedPin = touchedNodes.first(where: {usedColors(rawValue: $0.name!) != nil})
        if touchedPin != nil {
            if (rowOfPin != nil && rowOfPin!.position.y == -1000) {
                insertPin(touchedPin!.name!)
            } else {
                if Int(touchedPin!.position.y) == yValuesOfRows[0] {
                    removePin(touchedPin!)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
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
