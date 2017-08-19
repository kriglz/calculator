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
        "=": Operation.equals
    ]
 
    
    //set operand for ViewController
    mutating func setOperand (_ operand: Double){
        let valueToCheck = Value.numeric(operand)
        compareOldElement(with: valueToCheck)
        descriptionArray.append(String(operand))
    }
    mutating func setOperand (variable named: String){
        let valueToCheck = Value.nonNumeric(named)
        compareOldElement(with: valueToCheck)
        descriptionArray.append(named)
    }
    
    
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
                default:
                    break
                }
            }
        }
        evaluateResult = performOperation(ifMemorySet: evaluateResult).result
        let resultIsPendingResult = performOperation(ifMemorySet: evaluateResult).isPending

        return (result: evaluateResult, isPending: resultIsPendingResult, description: description)
    }
    
    
    //performOperations for ViewCOntroller
    func performOperation(ifMemorySet withValue: Double? = nil) -> (result: Double?, isPending: Bool) {
        
        var accumulation: Double?
        var resultIsPending = false
        
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
                
                if pendingBindingOperation != nil {
                    performPendingBinaryOperation()
                    pendingBindingOperation = nil
                }
                resultIsPending = false
                
            } else {
                if element == "M" {
                    if let value = withValue {
                        accumulation = value
                    }
                    else {
                        accumulation = 0
                    }
                    if pendingBindingOperation != nil {
                        performPendingBinaryOperation()
                        pendingBindingOperation = nil
                    }
                    resultIsPending = false
                }
                if let operation = operations[element]{
                    switch operation {
                        
                    case .constant(let value):
                        accumulation = value
                        if pendingBindingOperation == nil {
                            resultIsPending = false
                        }
                    
                    case .unaryOperation (let function):
                        accumulation = function(accumulation ?? 0)
                        resultIsPending = false
                        
                    case .binaryOperation(let function):
                        if pendingBindingOperation != nil {
                            performPendingBinaryOperation()
                            pendingBindingOperation = nil
                        }
                        pendingBindingOperation = PerformBinaryOperation(function: function, firstOperand: accumulation ?? 0)
                        resultIsPending = true
                        
                    case .equals:
                        if pendingBindingOperation != nil {
                            performPendingBinaryOperation()
                            pendingBindingOperation = nil
                        }
                        resultIsPending = false
                    }
                }
            }
        }
        return (accumulation, resultIsPending)
    }
    
    enum Value {
        case numeric(Double)
        case nonNumeric(String)
    }
    
    private mutating func compareOldElement(with newOne: Value) {
        switch newOne {
        case .numeric:
            if let lastElementIndex = descriptionArray.index(descriptionArray.endIndex, offsetBy: -1, limitedBy: descriptionArray.startIndex)
            {
                let lastElement = descriptionArray[lastElementIndex]
                let oldOperation = getOperationName(of: lastElement)
                
                if Double(lastElement) != nil || lastElement == "M" || oldOperation == "unaryOperation" || oldOperation == "constant" {
                    descriptionArray.removeAll()
                }
            }
        case .nonNumeric(let symbol):
            if let lastElementIndex = descriptionArray.index(descriptionArray.endIndex, offsetBy: -1, limitedBy: descriptionArray.startIndex) {
                let lastElement = descriptionArray[lastElementIndex]
                
                let newOperation = getOperationName(of: symbol)
                let oldOperation = getOperationName(of: lastElement)
                
                if newOperation == "constant" && (Double(lastElement) != nil || oldOperation == "constant" || oldOperation == "unaryOperation" || lastElement == "M") {
                    descriptionArray.removeAll()
                }
                if newOperation == "unaryOperation" && oldOperation == "binaryOperation" {
                    descriptionArray.removeLast()
                }
                if newOperation == "binaryOperation" && oldOperation == "binaryOperation" {
                    descriptionArray.removeLast()
                }
                if symbol == "M" && lastElement == "M" {
                    descriptionArray.removeLast()
                }
            }
        }
    }
    
    private func getOperationName(of operation: String) -> String {
        if let op = operations[operation]{
            switch op {
            case .constant:
                return "constant"
            case .unaryOperation:
                return "unaryOperation"
            case .binaryOperation:
                return "binaryOperation"
            case .equals:
                return "equals"
            }
        }
        return "Can't found"
    }

    
    //undo previous operation
    mutating func undoPreviousOperation() {
        if !descriptionArray.isEmpty {
            descriptionArray.removeLast()
        }
    }
    
    //clearAll description array and reset all instances
    mutating func clearAll() {
        descriptionArray.removeAll()
    }
}
