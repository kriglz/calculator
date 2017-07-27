//
//  CalculatorBrain.swift
//  calculator
//
//  Created by Kristina Gelzinyte on 5/23/17.
//
//

import Foundation

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
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "exp": Operation.unaryOperation(exp),
        "1/x": Operation.unaryOperation({ 1 / $0 }),
        "ln": Operation.unaryOperation(log),
        "±": Operation.unaryOperation({ -$0}),
        "×": Operation.binaryOperation({ $0 * $1}),
        "÷": Operation.binaryOperation({ $0 / $1}),
        "+": Operation.binaryOperation({ $0 + $1}),
        "-": Operation.binaryOperation({ $0 - $1}),
        "=": Operation.equals,
        "AC": Operation.clearAll,
        "M": Operation.clearAll
    ]

    private var accumulation: Double?
    
    
    
//    var resultIsPending = false
 
    //calculating CalculatorBrain result by substituting values for those variables found in a supplied Dictionary
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String)
    {

        
        //set result
        let result: Double = accumulation!
        
        //Result is pending only during binary operation
        if lastOperation == .binaryOperation {
            return (result: result, isPending: true, description: description)
        }
        
        return (result: result, isPending: false, description: description)
    }
//    //set result for ViewController
//    var result: Double? {
//        get {
//            return accumulation
//        }
//    }
//        
    
    
    
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
                    case "1/x":
                        wrapSymbol = "1/"
                    case "±":
                        if accumulation! > 0 {
                            wrapSymbol = "-"
                        } else {
                            wrapSymbol = ""
                        }
                    default:
                        wrapSymbol = symbol
                    }
                    
                    accumulation = function(accumulation ?? 0)
                    
                    if symbol == "±" && lastOperation != .equals {
                        descriptionArray.insert(wrapSymbol, at: descriptionArray.startIndex)
                    } else {
                        if lastOperation == .unaryOperation {
                            performOperation("=")
                        }
                        unaryOperationWrapping(wrapSymbol)
                    }
                    lastOperation = .unaryOperation
                }
                
            case .binaryOperation(let function):
                if lastOperation == .binaryOperation {
                    descriptionArray.removeLast(1)
                }
                if accumulation != nil {
                    pendingBindingOperation = PerformBinaryOperation(function: function, firstOperand: accumulation!)
   //                 resultIsPending = true
                    appendToArray(symbol)
                    lastOperation = .binaryOperation
                    evaluate()
                }

            case .equals():
                performPendingBinaryOperation()
                lastOperation = .equals
//                resultIsPending = false
                
            case .clearAll():
                clearAll()
                lastOperation = .clearAll
            }
        }
    }
    
//set operand for ViewController
    mutating func setOperand (_ operand: Double){
        if lastOperation == .constant || lastOperation == .equals || lastOperation == .unaryOperation {
            descriptionArray = []
        }
        accumulation = nil
        accumulation = operand
        if accumulation != nil {
            appendToArray(String(accumulation!))
        }
        lastOperation = .setOperand
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
//        resultIsPending = false
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
            descriptionArray.insert(wrapSymbol + "(", at: descriptionArray.startIndex)
        } else {
            descriptionArray.insert(wrapSymbol + "(", at: descriptionArray.index(before: descriptionArray.endIndex))
        }
        descriptionArray.append(")")
    }
}
