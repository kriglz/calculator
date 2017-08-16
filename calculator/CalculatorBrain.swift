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
    private var descriptionArray: [String] = []
    var description: String {
        get {
            var entireString = ""
            for element in descriptionArray {
                entireString.append(element)
            }
            return entireString
        }
    }
    

    //set operand for ViewController
    mutating func setOperand (_ operand: Double){
        descriptionArray.append(String(operand))
    }
    mutating func setOperand (variable named: String){
        descriptionArray.append(named)
    }
    
    
    private enum Operation{
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
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
    ]
 
    
    
    //calculating CalculatorBrain result by substituting values for those variables found in a supplied Dictionary
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String)
    {
        var evaluateResult: Double?
        if let dictionaryVariables = variables {
            for k in dictionaryVariables.keys {
                switch k {
                case "M":
                    evaluateResult = variables!["M"]
                    break
                default:
                    evaluateResult = performOperation()
                }
            }
        } else {
            evaluateResult = performOperation()
        }


        return (result: evaluateResult, isPending: false, description: description)
    }
    
    
    //performOperations for ViewCOntroller
    func performOperation() -> Double? {
        
        var accumulation: Double?
        
        //data structure for BinaryOperartion calculation
        struct PerformBinaryOperation {
            let function: (Double, Double) -> Double
            let firstOperand: Double
            func perform (with secondOperand: Double) -> Double {
                return function(firstOperand, secondOperand)
            }
        }
        //perform BinaryOperation
        var pendingBindingOperation: PerformBinaryOperation?
        func performPendingBinaryOperation() {
            if pendingBindingOperation != nil {
                accumulation = pendingBindingOperation!.perform(with: accumulation ?? 0)
                pendingBindingOperation = nil
            }
        }
        
        for element in descriptionArray {
            if Double(element) != nil {
                accumulation = Double(element)!
            } else {
                
                if let operation = operations[element]{
                    switch operation {
                        
                    case .constant(let value):
                        accumulation = value
                        
                    case .unaryOperation (let function):
                        accumulation = function(accumulation ?? 0)
                        
                    case .binaryOperation(let function):
                        pendingBindingOperation = PerformBinaryOperation(function: function, firstOperand: accumulation ?? 0)
                        
                    case .equals():
                        performPendingBinaryOperation()
                    }
                }
            }
        }
       
        return accumulation
    }
    
    

    
    //undo previous operation
    mutating func undoPreviousOperation() {
        if !descriptionArray.isEmpty {
            descriptionArray.removeLast()
        }
    }
    
    //clearAll description array and reset all instances
    mutating func clearAll() {
        descriptionArray = [""]
//        pendingBindingOperation = nil
    }
}
