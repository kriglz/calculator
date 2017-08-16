//
//  ViewController.swift
//  calculator
//
//  Created by Kristina Gelzinyte on 5/19/17.
//
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionDisplay: UILabel!
    @IBOutlet weak var memoryDisplay: UILabel!
    @IBAction func undoButton(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {          //undo characters
            if !(display.text?.characters.isEmpty)! {
                display.text!.characters.removeLast()
                if (display.text?.characters.isEmpty)! {
                    display.text! = "0.0"
                    userIsInTheMiddleOfTyping = false
                }
            }
            if (descriptionDisplay.text?.isEmpty)! {
                descriptionDisplay.text = " "
            }
        } else {                                //undo operations
            brain.undoPreviousOperation()
            displayDescription()
        }
    }
    @IBAction func allClearButton(_ sender: Any) {
        brain.clearAll()
        memory.storage = nil
        memoryDisplay.text! = " "
        displayDescription()
        userIsInTheMiddleOfTyping = false
    }
    var userIsInTheMiddleOfTyping = false

    
//
//typing numbers
//
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            if !display.text!.contains(".") || digit != "." {
                let textCurrentlyDisplayed = display.text!
                display.text! = textCurrentlyDisplayed + digit
            }
        } else {
            display.text! = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        } set {
            display.text = String(newValue)
        }
    }

    
    
//
//setting/getting memory
//
    
    private var memory = CalculatorMemory()
    @IBAction func setMemory(_ sender: UIButton) {
        memory.storage = ["M": displayValue]
        memoryDisplay.text! = "M → " + String(displayValue)
        display.text! = String(brain.evaluate(using: memory.storage).result!)
    }
    @IBAction func getMemory(_ sender: UIButton) {
        brain.setOperand(variable: "M")

        if memory.storage != nil {
            displayValue = brain.evaluate(using: memory.storage).result!
            brain.setOperand(displayValue)
        } else {
            displayValue = brain.evaluate(using: ["M": 0]).result!
            brain.setOperand(displayValue)
        }
    }
    
    
    
    
//
//using/doing operartion
//
    
    private var brain = CalculatorBrain()
    @IBAction func mathematicalSymbol(_ sender: UIButton) {
        //set operand
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        //set operation
        if let mathematicalSymbol = sender.currentTitle, sender.currentTitle != "=" {
            brain.setOperand(variable: mathematicalSymbol)
        }
        
        brain.performOperation(sender.currentTitle!)
        displayDescription()
        
        //get result
        if let result = brain.evaluate().result {
            displayValue = result
        }
    }
    
    //adding elipses or equal sign to the description label
    func displayDescription() {
        if brain.evaluate().isPending {
            descriptionDisplay.text! = brain.evaluate().description + "..."
        } else {
            if !brain.description.isEmpty {
                descriptionDisplay.text! = brain.evaluate().description + "="
            } else {
                displayValue = 0
                descriptionDisplay.text! = "0"
            }
        }
    }
}

