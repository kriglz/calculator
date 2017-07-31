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
        memory.storage.removeAll()
        memory.storage["M"] = displayValue
//        print(memory.storage)

        display.text! = String(brain.evaluate(using:memory.storage).result!)
        print(displayValue)

    }
    
    @IBAction func getMemory(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        
//        if memory.storage != nil
//        {
            if let result = brain.evaluate(using: memory.storage).result {
                displayValue = result //display.text!
                print(result)
//            }
            
        } else {
            displayValue = brain.evaluate(using: ["M": 0]).result!
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
                    memory.storage.removeAll()
                }
            }
        }
//get result
        if let result = brain.evaluate().result {
            displayValue = result
        }
    }
}

