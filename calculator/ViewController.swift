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
    
    private var memory = CalculatorMemory()
    
    @IBAction func setMemory(_ sender: UIButton) {
        //set operand
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
//        memory.storage?.removeAll()
        memory.storage = ["M": displayValue]
        display.text! = String(brain.evaluate(using:memory.storage).result!)
        memoryDisplay.text! = "M → " + display.text!
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
        
        //perform operation
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            
            //adding elipses or equal sign to the description label
            if brain.evaluate().isPending {
                descriptionDisplay.text! = brain.evaluate().description + "..."
            } else {
                if mathematicalSymbol != "AC" {
                    descriptionDisplay.text! = brain.evaluate().description + "="
                } else {
                    descriptionDisplay.text! = brain.evaluate().description
                    memory.storage?.removeAll()
                    memoryDisplay.text! = " "
                }
            }
        }
        //get result
        if let result = brain.evaluate().result {
            displayValue = result
        }
    }
}

