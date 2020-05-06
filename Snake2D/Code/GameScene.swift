//
//  GameScene.swift
//  Snake2D
//
//  Created by admin on 05/05/2020.
//  Copyright © 2020 DenysPashkov. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
/// Menu element
	var gameLogo: SKLabelNode!
	var bestScore: SKLabelNode!
	var easyDifficultyButton: SKShapeNode!
	var hardDifficultyButton: SKShapeNode!
	
	var currentScore: SKLabelNode!
	var playerPositions: [(Int, Int)] = []
	var gameBG: SKShapeNode!
	var gameArray: [(node: SKShapeNode, x: Int, y: Int)] = []
	var scorePos: CGPoint?
	
///	Game element
	private var game: GameManager!
	
    override func sceneDidLoad() {
///		called when scene load
		initializeMenu()
		
		game = GameManager(scene: self, isEasyDifficulty: true)
		initializeGameView()
    }
	
//	MARK: INITIALIZE MENU BY CODE
	private func initializeMenu() {
		
		//Create game title
		gameLogo = SKLabelNode(fontNamed: "ArialRoundedMTBold")
		gameLogo.zPosition = 1
		gameLogo.position = CGPoint(x: 0, y: (frame.size.height / 2) - 200)
		gameLogo.fontSize = 60
		gameLogo.text = "SNAKE"
		gameLogo.fontColor = SKColor.red
		self.addChild(gameLogo)
		
		//Create best score label
		bestScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
		bestScore.zPosition = 1
		bestScore.position = CGPoint(x: 0, y: gameLogo.position.y - 50)
		bestScore.fontSize = 40
		bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
		bestScore.fontColor = SKColor.white
		self.addChild(bestScore)
		
		//Create play button
		easyDifficultyButton = SKShapeNode()
		easyDifficultyButton.name = "easy_button"
		easyDifficultyButton.zPosition = 1
		easyDifficultyButton.position = CGPoint(x: -125, y: (frame.size.height / -2) + 400)
		easyDifficultyButton.fillColor = SKColor.cyan
		
		//Create play button
		hardDifficultyButton = SKShapeNode()
		hardDifficultyButton.name = "hard_button"
		hardDifficultyButton.zPosition = 1
		hardDifficultyButton.position = CGPoint(x: 125, y: (frame.size.height / -2) + 400)
		hardDifficultyButton.fillColor = SKColor.red
		
		let topCorner = CGPoint(x: -50, y: 50)
		let bottomCorner = CGPoint(x: -50, y: -50)
		let middle = CGPoint(x: 50, y: 0)
		let path = CGMutablePath()
		path.addLine(to: topCorner)
		path.addLines(between: [topCorner, bottomCorner, middle])
		
		easyDifficultyButton.path = path
		self.addChild(easyDifficultyButton)
		
		hardDifficultyButton.path = path
		self.addChild(hardDifficultyButton)
	}
	
//	MARK: INITIALIZE GAME VIEW BY CODE
	private func initializeGameView() {

		currentScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
		currentScore.zPosition = 1
		currentScore.position = CGPoint(x: 0, y: (frame.size.height / -2) + 60)
		currentScore.fontSize = 40
		currentScore.isHidden = true
		currentScore.text = "Score: 0"
		currentScore.fontColor = SKColor.white
		self.addChild(currentScore)
		
		let width = frame.size.width - 200
		let height = frame.size.height - 300
		let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
		gameBG = SKShapeNode(rect: rect, cornerRadius: 0.02)
		gameBG.fillColor = SKColor.darkGray
		gameBG.zPosition = 2
		gameBG.isHidden = true
		self.addChild(gameBG)
		
		createGameBoard(width: Int(width), height: Int(height))
	}
	
//	MARK: MOVEMENT MANAGMENT
	
	private func initializeMovement(){
		let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeR))
		swipeRight.direction = .right
		view!.addGestureRecognizer(swipeRight)
		
		let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeL))
		swipeLeft.direction = .left
		view!.addGestureRecognizer(swipeLeft)
		
		let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeU))
		swipeUp.direction = .up
		view!.addGestureRecognizer(swipeUp)
		
		let swipeDown:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeD))
		swipeDown.direction = .down
		view!.addGestureRecognizer(swipeDown)
		print("Movement Implemented")
	}
	
	@objc func swipeR() { game.changeDirection(newDirection: .right) }
	@objc func swipeL() { game.changeDirection(newDirection: .left) }
	@objc func swipeU() { game.changeDirection(newDirection: .up) }
	@objc func swipeD() { game.changeDirection(newDirection: .down) }
	
//	MARK: TOUCH START BUTTON
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for touch in touches {
			let location = touch.location(in: self)
			let touchedNode = self.nodes(at: location)
			for node in touchedNode {
				if node.name == "easy_button" {
					game.isEasyDifficulty = true
					startGame()
				} else if node.name == "hard_button" {
					game.isEasyDifficulty = false
					startGame()
				}
			}
		}
	}
	
//	MARK: START GAME FUNCTION
	private func startGame() {
		print("start game")
		
		gameLogo.run(SKAction.move(by: CGVector(dx: -50, dy: 600), duration: 0.5)) {
		self.gameLogo.isHidden = true
		}
		
		easyDifficultyButton.run(SKAction.scale(to: 0, duration: 0.3)) {
			self.easyDifficultyButton.isHidden = true
			self.hardDifficultyButton.isHidden = true
		}
		
		let bottomCorner = CGPoint(x: 0, y: (frame.size.height / -2) + 20)
		bestScore.run(SKAction.move(to: bottomCorner, duration: 0.4))
		
		bestScore.run(SKAction.move(to: bottomCorner, duration: 0.4)) {
			self.gameBG.setScale(0)
			self.currentScore.setScale(0)
			self.gameBG.isHidden = false
			self.currentScore.isHidden = false
			self.gameBG.run(SKAction.scale(to: 1, duration: 0.4))
			self.currentScore.run(SKAction.scale(to: 1, duration: 0.4))
			self.game.initGame()
			self.initializeMovement()
		}
		
	}
	
//	MARK: BOARD OF GAME
	private func createGameBoard(width: Int, height: Int) {
		print("game board")
		let cellWidth: CGFloat = 27.5
		let numRows = 37
		let numCols = 20
		var x = CGFloat(width / -2) + (cellWidth / 2)
		var y = CGFloat(height / 2) - (cellWidth / 2)
///		loop through rows and columns, create cells
		for i in 0...numRows - 1 {
			for j in 0...numCols - 1 {
				let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellWidth))
				cellNode.strokeColor = SKColor.black
				cellNode.zPosition = 2
				cellNode.position = CGPoint(x: x, y: y)
///				add to array of cells -- then add to game board
				gameArray.append((node: cellNode, x: i, y: j))
				gameBG.addChild(cellNode)
///				iterate x
				x += cellWidth
			}
///			reset x, iterate y
			x = CGFloat(width / -2) + (cellWidth / 2)
			y -= cellWidth
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
///		Called every frame
		game.update(time: currentTime)
	}
}
