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
    
    let xValuesOfColumns = [
        -270,
         -90,
          90,
         270,
    ]
    var yValuesOfRows: [Int] = []
    
    var rowNumbers: [SKLabelNode] = []
    
    let evaluatorOffsets = [
        [-30, 35],
        [30, 35],
        [-30, -35],
        [30, -35]
    ]
    var currentRow = 0
    let highlighterCircle = SKSpriteNode(imageNamed: "hole_selected")
    var guesses: [SKNode?] = []
    var solutions: [usedColors] = []
    let solutionCover = SKSpriteNode(imageNamed: "solution_cover")
    var currentRowEvaluators: [SKNode?] = []
    
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
        
        for i in 0..<10 {
            self.yValuesOfRows.append(-740 + 170 * i)
        }
        
        solutions = self.getFourRandomItems(from: usedColors.self)
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
        
        solutionCover.position = CGPoint(x: 0, y: 1000)
        solutionCover.zPosition = 2
        solutionCover.alpha = 0.5
        self.addChild(solutionCover)
        
        for i in 1...10 {
            let rowNumber = SKLabelNode(text: "\(i)")
            rowNumber.position = CGPoint(x: -450, y: yValuesOfRows[i-1])
            self.rowNumbers.append(rowNumber)
        }
        
        doneButtonBg.position = CGPoint(x: 460, y: -740)
        doneButton.position = CGPoint(x: 460, y: -740)
        doneButtonBg.zPosition = 5
        doneButton.zPosition = 6
        doneButton.name = "done"
        self.addChild(doneButtonBg)
        self.addChild(doneButton)
        doneButton.alpha = 0.75
        
        resetHighlighterCircle()
        self.addChild(highlighterCircle)
        
        resetGuesses()
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
    
    func addGuess(_ newPinName: String) {
        for (i, hole) in self.guesses.enumerated() {
            if hole == nil {
                let addedPin = createPin(newPinName)
                guesses[i] = addedPin
                addedPin.position = CGPoint(x: xValuesOfColumns[i], y: yValuesOfRows[currentRow])
                addedPin.zPosition = 2
                self.addChild(addedPin)
                updateHighlighterCircle()
                break
            }
        }
    }
    
    fileprivate func updateHighlighterCircle() {
        for (i, hole) in self.guesses.enumerated() {
            if (hole == nil && i < 4) {
                highlighterCircle.position = CGPoint(x: xValuesOfColumns[i], y: yValuesOfRows[currentRow])
                doneButton.alpha = 0.75
                return
            }
        }
        highlighterCircle.position = CGPoint(x: 460, y: yValuesOfRows[currentRow])
        doneButton.alpha = 1
    }
    
    func evaluateGuesses() {
        for (pin_i, pin) in guesses.enumerated() {
            if pin!.name! == self.solutions[pin_i].rawValue {
                let evaluatorPin = SKSpriteNode(imageNamed: "pin_black")
                evaluatorPin.name = "black"
                self.currentRowEvaluators.insert(evaluatorPin, at: 0)
                continue
            }
            for solution in self.solutions {
                if solution.rawValue == pin!.name! {
                    let evaluatorPin = SKSpriteNode(imageNamed: "pin_white")
                    evaluatorPin.name = "white"
                    self.currentRowEvaluators.append(evaluatorPin)
                    break
                }
            }
        }
        
        for (i, evaluator) in self.currentRowEvaluators.enumerated() {
            evaluator?.position = CGPoint(x: 481 + self.evaluatorOffsets[i][0], y: 7 + self.yValuesOfRows[currentRow] + self.evaluatorOffsets[i][1])
            self.addChild(evaluator!)
        }
    }
    
    func checkGameOver() {
        var numOfBlackEvaluators = 0
        for evaluator in self.currentRowEvaluators {
            if evaluator!.name == "black" {
                numOfBlackEvaluators += 1
            }
        }
        if self.currentRow == 10 - 1 || numOfBlackEvaluators == 4 {
            self.removeChildren(in: [self.highlighterCircle, self.doneButton, self.doneButtonBg])
            self.solutionCover.position.x += 900
        }
    }
    
    func removePin(_ pinToRemove: SKNode) {
        pinToRemove.removeFromParent()
        guesses[guesses.firstIndex(of: pinToRemove)!] = nil
        updateHighlighterCircle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        let touchedNodes = nodes(at: location)
        let rowOfPin = touchedNodes.first(where: {$0.name == "colors"})
        if touchedNodes.count > 0 && touchedNodes[0].name != nil {
            if touchedNodes[0].name != "done" {
                let touchedPin = touchedNodes.first(where: {usedColors(rawValue: $0.name!) != nil})
                if touchedPin != nil {
                    if (rowOfPin != nil && rowOfPin!.position.y == -1000) {
                        addGuess(touchedPin!.name!)
                    } else {
                        if Int(touchedPin!.position.y) == yValuesOfRows[0] {
                            removePin(touchedPin!)
                        }
                    }
                } else {
                    if touchedNodes.count > 0 && touchedNodes[0].name == "reset" {
                        self.removeAllChildren()
                        for var pin in guesses {
                            pin = nil;
                        }
                        solutions = self.getFourRandomItems(from: usedColors.self)
                        
                        let scene = GameScene.newGameScene()
                        let skView = self.view!
                        skView.presentScene(scene)
                    }
                }
            } else {
                if touchedNodes[0].name == "done" && touchedNodes[0].alpha == 1 {
                        evaluateGuesses()
                        checkGameOver()
                        moveToNextRow()
                }
            }
        }
    }
    
    func moveToNextRow() {
        self.currentRow += 1
        resetHighlighterCircle()
        resetGuesses()
        resetEvaluators()
        moveDoneButtonUp()
    }
    
    func resetHighlighterCircle() {
        highlighterCircle.position = CGPoint(x: -270, y: -740 + 170 * currentRow)
    }
    
    func resetEvaluators() {
        self.currentRowEvaluators = []
    }
    
    func moveDoneButtonUp() {
        doneButtonBg.position.y += 170
        doneButton.position.y += 170
        doneButton.alpha = 0.75
    }
    
    func resetGuesses() {
        self.guesses = [SKSpriteNode?](repeating: nil, count: 4)
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
