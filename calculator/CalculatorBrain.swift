//
//  CalculatorBrain.swift
//  calculator
//
//  Created by Kristina Gelzinyte on 5/23/17.
//
//

import Foundation

struct CalculatorMemory {
    var storage: Dictionary<String, Double>?
}


struct CalculatorBrain {
    
//Description string made out of description array
    var description: String {
        get {
            var entireString = ""
            for element in descriptionArray {
                entireString.append(element)
            }
            return entireString
        }
    }
    private var descriptionArray:[String] = []
    
    private enum Operation{
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clearAll
    }
    
    private var lastOperation: LastOperation = .equals
    private enum LastOperation{
        case constant
        case unaryOperation
        case binaryOperation
        case equals
        case clearAll
        case setOperand
        case setVariableOperand
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "exp": Operation.unaryOperation(exp),
        "x⁻¹": Operation.unaryOperation({ 1 / $0 }),
        "ln": Operation.unaryOperation(log),
        "±": Operation.unaryOperation({ -$0}),
        "×": Operation.binaryOperation({ $0 * $1}),
        "÷": Operation.binaryOperation({ $0 / $1}),
        "+": Operation.binaryOperation({ $0 + $1}),
        "-": Operation.binaryOperation({ $0 - $1}),
        "=": Operation.equals,
        "AC": Operation.clearAll,
    ]

    private var accumulation: Double?
 
    //calculating CalculatorBrain result by substituting values for those variables found in a supplied Dictionary
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String)
    {
        var evaluateResult: Double?

        if let dictionaryVariables = variables {
            for k in dictionaryVariables.keys {
                evaluateResult = dictionaryVariables[k]
            }
        } else {
            if accumulation != nil {
                evaluateResult = accumulation!
            } else {
                evaluateResult = 0
            }
        }
        
        //Result is pending only during binary operation
        if lastOperation == .binaryOperation {
            return (result: evaluateResult, isPending: true, description: description)
        }

        return (result: evaluateResult, isPending: false, description: description)
    }
    
    
    
    //set operand for ViewController
    mutating func setOperand (_ operand: Double){
        if lastOperation == .constant || lastOperation == .equals || lastOperation == .unaryOperation {
            descriptionArray = []
        }
        accumulation = nil
        accumulation = operand
        if lastOperation != .setVariableOperand {
            appendToArray(String(accumulation!))
        }
        lastOperation = .setOperand
    }
    

    mutating func setOperand (variable named: String){
        appendToArray(named)
        lastOperation = .setVariableOperand
    }
    
    
//performOperations for ViewCOntroller
    mutating func performOperation (_ symbol: String){
        if let operation = operations[symbol]{
            switch operation {
            
            case .constant(let value):
                if lastOperation != .binaryOperation {
                    clearAll()
                }
                accumulation = value
                appendToArray(symbol)
                lastOperation = .constant
                
            case .unaryOperation (let function):
                if accumulation != nil {
                    var wrapSymbol:String = ""
                    switch symbol {
                    case "x⁻¹":
                        wrapSymbol = "⁻¹"
                    case "±":
                        if accumulation! > 0 {
                            wrapSymbol = "-"
                        } else {
                            wrapSymbol = ""
                        }
                    default:
                        wrapSymbol = symbol
                    }
                    
                    accumulation = function(accumulation!)
                    
                    if symbol == "±" && lastOperation != .equals {
                        descriptionArray.insert(wrapSymbol, at: descriptionArray.startIndex)
                    } else {
                        //calculating result for unaryOperation
                        if lastOperation == .unaryOperation {
                            performOperation("=")
                        }
                        unaryOperationWrapping(wrapSymbol)
                    }
                    lastOperation = .unaryOperation
                } else {
                    accumulation = 0
                    accumulation = function(accumulation!)
                    setOperand(accumulation!)
                }
            
            case .binaryOperation(let function):
                //prevents from clicking symbols lots of times
                if lastOperation == .binaryOperation {
                    descriptionArray.removeLast(1)
                }
                //perform multiple operations
                if lastOperation == .setOperand && pendingBindingOperation != nil {
                    performPendingBinaryOperation()
                }
                if accumulation != nil {
                    pendingBindingOperation = PerformBinaryOperation(function: function, firstOperand: accumulation!)
                    appendToArray(symbol)
                    lastOperation = .binaryOperation
                }

            case .equals():
                performPendingBinaryOperation()
                lastOperation = .equals
                
            case .clearAll():
                clearAll()
                lastOperation = .clearAll
            }
        }
    }
    
    
    
    //data structure for BinaryOperartion calculation
    private struct PerformBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform (with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    //perform BinaryOperation
    private var pendingBindingOperation: PerformBinaryOperation?
    private mutating func performPendingBinaryOperation() {
        if pendingBindingOperation != nil && accumulation != nil {
            accumulation = pendingBindingOperation!.perform(with: accumulation!)
            pendingBindingOperation = nil
        }
    }
    
    
    //clearAll description array and reset all instances
    mutating private func clearAll() {
        accumulation = 0
        descriptionArray = ["0"]
        pendingBindingOperation = nil
        lastOperation = .clearAll
    }
    
    //append to array new elements
    mutating private func appendToArray(_ element: String) {
        if lastOperation == .clearAll && evaluate().isPending == false {
            descriptionArray.removeAll()
        }
        descriptionArray.append(element)
    }
    
    //wraping before unitaryOperation
    mutating private func unaryOperationWrapping(_ wrapSymbol: String) {
        if lastOperation == .equals {
            if wrapSymbol == "⁻¹" {
                descriptionArray.insert("(", at: descriptionArray.startIndex)
                descriptionArray.append(")" + "⁻¹")
            } else {
                descriptionArray.insert(wrapSymbol + "(", at: descriptionArray.startIndex)
                descriptionArray.append(")")
            }
        }
        else {
            if wrapSymbol == "⁻¹" {
                descriptionArray.insert("(", at: descriptionArray.index(before: descriptionArray.endIndex))
                descriptionArray.append(")" + "⁻¹")
            } else {
                descriptionArray.insert(wrapSymbol + "(", at: descriptionArray.index(before: descriptionArray.endIndex))
                descriptionArray.append(")")
            }
        }
    }
}
