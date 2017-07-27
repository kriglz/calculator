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
    
    
    @IBAction func setMemory(_ sender: UIButton) {
        display.text! = String(brain.evaluate(using: [sender.currentTitle!: displayValue]).result!)

    }
    
    
    
    
    
//
//using/doiong operartion
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
                descriptionDisplay.text! = brain.description + "..."
            } else {
                if mathematicalSymbol != "AC" {
                    descriptionDisplay.text! = brain.description + "="
                } else {
                    descriptionDisplay.text! = brain.description
                }
            }
        }
//get result
        if let result = brain.evaluate().result {
            displayValue = result
        }
    }
}

