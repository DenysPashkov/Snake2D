//
//  GameManager.swift
//  Snake2D
//
//  Created by admin on 05/05/2020.
//  Copyright © 2020 DenysPashkov. All rights reserved.
//

import SpriteKit

enum PlayerDirection {
	case stop
	case up
	case down
	case right
	case left
}

class GameManager {
	
	var isEasyDifficulty : Bool
	
	private var scene: GameScene!
	private var nextTime: Double?
	private var timeExtension: Double = 0.4
	var currentScore: Int = 0
	
	private var playerDirection : PlayerDirection = .left
	private var futureDirection : PlayerDirection = .left
	
	init(scene: GameScene, isEasyDifficulty : Bool) {
		self.scene = scene
		self.isEasyDifficulty = isEasyDifficulty
	}
	
	func initGame() {
		//starting player position
		scene.playerPositions.append((10, 10))
		scene.playerPositions.append((10, 11))
		scene.playerPositions.append((10, 12))
		renderChange()
		generateNewPoint()
	}
	
//	MARK: MANAGE MOVEMENT
	
	func changeDirection(newDirection : PlayerDirection){
		if 	(playerDirection == .right && !(newDirection == .left)) ||
			(playerDirection == .left && !(newDirection == .right)) ||
			(playerDirection == .up && !(newDirection == .down)) ||
			(playerDirection == .down && !(newDirection == .up)) {
				futureDirection = newDirection
		}
	}
	
//	MARK: MOVEMENT RENDER
	
	private func renderChange() {
		for (node, x, y) in scene.gameArray {
			if contains(a: scene.playerPositions, v: (x,y)) {
				node.fillColor = SKColor.cyan
			} else {
				node.fillColor = SKColor.clear
				
				if scene.scorePos != nil {
					if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
						node.fillColor = SKColor.red
					}
				}
			}
		}
	}
	
	private func contains(a:[(Int, Int)], v:(Int,Int)) -> Bool {
		let (c1, c2) = v
		for (v1, v2) in a { if v1 == c1 && v2 == c2 { return true } }
		return false
	}
	
//	MARK: UPDATE
	
	func update(time: Double) {
		if nextTime == nil {
			nextTime = time + timeExtension
		} else {
			if time >= nextTime! {
				nextTime = time + timeExtension
				updatePlayerPosition()
				checkForScore()
				checkForDeath()
			}
		}
	}
	
//	MARK: Check Death
	
	private func checkForDeath() {
		if scene.playerPositions.count > 0 {
			var arrayOfPositions = scene.playerPositions
			let headOfSnake = arrayOfPositions[0]
			arrayOfPositions.remove(at: 0)
			if contains(a: arrayOfPositions, v: headOfSnake) {
				futureDirection = .stop
			}
			finishAnimation()
		}
	}
	
//	MARK: Check Score
	
	private func checkForScore() {
		if scene.scorePos != nil {
			let x = scene.playerPositions[0].0
			let y = scene.playerPositions[0].1
			if Int((scene.scorePos?.x)!) == y && Int((scene.scorePos?.y)!) == x {
				currentScore += 1
				scene.currentScore.text = "Score: \(currentScore)"
				generateNewPoint()
				scene.playerPositions.append(scene.playerPositions.last!)
			 }
		 }
	}
	
//	MARK: Fisnish animation
	
	private func finishAnimation() {
//		if playerDirection == .stop && scene.playerPositions.count > 0 {
			var hasFinished = true
			let headOfSnake = scene.playerPositions[0]
			for position in scene.playerPositions {
				if headOfSnake != position {
					hasFinished = false
				}
			 }
		 if hasFinished {
			
			updateScore()
			
			playerDirection = .left
			futureDirection = playerDirection
			//animation has completed
			scene.scorePos = nil
			scene.playerPositions.removeAll()
			renderChange()
			//return to menu
			
			scene.currentScore.run(SKAction.scale(by: 0, duration: 0.4)) {
				self.scene.currentScore.isHidden = true
			}
			
			scene.gameBG.run(SKAction.scale(to: 0, duration: 0.4)) {
				self.scene.gameBG.isHidden = true
				self.scene.gameLogo.isHidden = false
				self.scene.gameLogo.run(SKAction.move(to: CGPoint(x: 0, y: (self.scene.frame.size.height / 2) - 200), duration: 0.5)) {
					 self.scene.easyDifficultyButton.isHidden = false
					 self.scene.easyDifficultyButton.run(SKAction.scale(to: 1, duration: 0.3))
					 self.scene.easyDifficultyButton.run(SKAction.move(to: CGPoint(x: 0, y: self.scene.gameLogo.position.y - 50), duration: 0.3))
					
					self.scene.hardDifficultyButton.isHidden = false
					self.scene.hardDifficultyButton.run(SKAction.scale(to: 1, duration: 0.3))
					self.scene.hardDifficultyButton.run(SKAction.move(to: CGPoint(x: 0, y: self.scene.gameLogo.position.y - 50), duration: 0.3))
				   }
			  }
			  }
//		 }
	}
	
	
	private func updateScore() {
		 if currentScore > UserDefaults.standard.integer(forKey: "bestScore") {
			  UserDefaults.standard.set(currentScore, forKey: "bestScore")
		 }
		 currentScore = 0
		 scene.currentScore.text = "Score: 0"
		 scene.bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
	}
	
//	MARK: Generate point
	
	private func generateNewPoint() {
		var randomX = CGFloat(arc4random_uniform(19))
		var randomY = CGFloat(arc4random_uniform(36))
		
		
		while contains(a: scene.playerPositions, v: (Int(randomX), Int(randomY))) {
			randomX = CGFloat(arc4random_uniform(19))
			randomY = CGFloat(arc4random_uniform(36))
		}
		
		scene.scorePos = CGPoint(x: randomX, y: randomY)
		
	}
	
//	MARK: UPDATE POSITION
	
	private func updatePlayerPosition() {
    
    var xChange = -1
    var yChange = 0
    
		playerDirection = futureDirection
		
    switch playerDirection {
			case .left:
				
				xChange = -1
				yChange = 0
				break
			case .up:
				
				xChange = 0
				yChange = -1
				break
			case .right:
				
				xChange = 1
				yChange = 0
				break
			case .down:
				
				xChange = 0
				yChange = 1
				break
		case .stop:
			xChange = 0
			yChange = 0
			break
		}
		
		
		
		if scene.playerPositions.count > 0 {
				var start = scene.playerPositions.count - 1
				while start > 0 {
					scene.playerPositions[start] = scene.playerPositions[start - 1]
					start -= 1
				}
				scene.playerPositions[0] = (scene.playerPositions[0].0 + yChange, scene.playerPositions[0].1 + xChange)
			}
		
///		see the position changed for all
		
		if isEasyDifficulty {
			semplifiedVersion()
		} else {
			standardVersion()
		}
		
		renderChange()
	}
	
	private func standardVersion(){
		if scene.playerPositions.count > 0 {
			let x = scene.playerPositions[0].1
			let y = scene.playerPositions[0].0
			if y > 36 {
				futureDirection = .stop
				finishAnimation()
			} else if y < 0 {
				futureDirection = .stop
				finishAnimation()
			} else if x > 19 {
			   futureDirection = .stop
			   finishAnimation()
			} else if x < 0 {
				futureDirection = .stop
				finishAnimation()
			}
			
///			it give some problem for some reason
//			if 	y > 36 ||
//				y < 0 ||
//				x > 19 ||
//				x < 0{
//				futureDirection = .stop
//				finishAnimation()
//			}
		}
	}
	
	private func semplifiedVersion(){
		
		if scene.playerPositions.count > 0 {
			let x = scene.playerPositions[0].1
			let y = scene.playerPositions[0].0
			if y > 36 {
				scene.playerPositions[0].0 = 0
			} else if y < 0 {
				scene.playerPositions[0].0 = 36
			} else if x > 19 {
			   scene.playerPositions[0].1 = 0
			} else if x < 0 {
				scene.playerPositions[0].1 = 19
			}
		}
		
	}
	
}
