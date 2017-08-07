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
            
//            if lastOperation == .equals {
//                let n = descriptionArray.count - 2
//                for i in 0...n {
//                    entireString.append(descriptionArray[i])
//                }
//            } else {
//                for element in descriptionArray {
//                    entireString.append(element)
//                }
//            }
            for element in descriptionArray {
                entireString.append(element)
            }
            return entireString
        }
    }
    
    private var descriptionArray: [String] = []
    private var result: Double?
    
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
                switch k {
                case "M":
                    evaluateResult = variables!["M"]
                    break
                default:
                    evaluateResult = 0
                }
            }
        } else {
            evaluateResult = result
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
        if lastOperation != .setVariableOperand {
            appendToArray(String(operand))
        }
        result = operand
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
                appendToArray(symbol)
                lastOperation = .constant
                
            case .unaryOperation (let function):
                if descriptionArray.isEmpty {
                    setOperand(0)
                }
//                unaryOperationWrapping(symbol)
//                result = function(Double(descriptionArray[descriptionArray.index(before: descriptionArray.endIndex)])!)

                result = function(result!)
                descriptionArray.append(symbol)

                lastOperation = .unaryOperation
                
            case .binaryOperation(let function):
                //prevents from clicking symbols lots of times
                if lastOperation == .binaryOperation {
                    descriptionArray.removeLast(1)
                }
                //perform multiple operations
                if lastOperation == .setOperand && pendingBindingOperation != nil || lastOperation == .equals {
                    performPendingBinaryOperation()
                    pendingBindingOperation = PerformBinaryOperation(function: function, firstOperand: result ?? 0)
                } else {
                    pendingBindingOperation = PerformBinaryOperation(function: function, firstOperand: Double(descriptionArray[descriptionArray.index(before: descriptionArray.endIndex)]) ?? 0)
                }
                appendToArray(symbol)
                lastOperation = .binaryOperation
                
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
        if pendingBindingOperation != nil {
//            result = pendingBindingOperation!.perform(with: Double(
//                descriptionArray[descriptionArray.index(before: descriptionArray.endIndex)]) ?? 0)
            result = pendingBindingOperation!.perform(with: result ?? 0)
            pendingBindingOperation = nil
        }
    }
    
    //undo previous operation
    mutating func undoPreviousOperation() {
        if !descriptionArray.isEmpty {
            descriptionArray.removeLast()
        }
    }
    
    //clearAll description array and reset all instances
    mutating private func clearAll() {
        descriptionArray = [""]
        pendingBindingOperation = nil
        result = nil
        lastOperation = .clearAll
    }
    
    //append to array new elements
    mutating private func appendToArray(_ element: String) {
        if lastOperation == .clearAll && evaluate().isPending == false {
            descriptionArray.removeAll()
        }
        descriptionArray.append(element)
    }
    private var wasMinus = false

    //wraping before unitaryOperation
    mutating private func unaryOperationWrapping(_ wrapSymbol: String) {
        var symbol = ""
        switch wrapSymbol {
        case "±":
            if Double(descriptionArray.endIndex) > 0 {
//            if accumulation! > 0 {

                symbol = "-"
                if lastOperation == .unaryOperation {
                    performOperation("=")
                }
                if lastOperation == .equals {
                    descriptionArray.insert(symbol + "(", at: descriptionArray.startIndex)
                    descriptionArray.append(")")
                    wasMinus = true
                }
                else {
                    descriptionArray.insert(symbol, at: descriptionArray.index(before: descriptionArray.endIndex))
                }
            } else {
//                if accumulation! < 0 {
                if   Double(descriptionArray.endIndex) < 0 {
                    if wasMinus && lastOperation == .unaryOperation {
                        descriptionArray.removeFirst()
                        descriptionArray.removeLast()
                        wasMinus = false
                    } else {
                        if lastOperation == .unaryOperation {
                            descriptionArray.remove(at: descriptionArray.startIndex)
                        }
                        if lastOperation == .equals {
                            descriptionArray.insert("-" + "(", at: descriptionArray.startIndex)
                            descriptionArray.append(")")
                        }
                    
                    }
                }
            }
        
        case "x⁻¹":
            symbol = "⁻¹"
            if lastOperation == .unaryOperation {
                performOperation("=")
            }
            if lastOperation == .equals {
                descriptionArray.insert("(", at: descriptionArray.startIndex)
                descriptionArray.append(")" + "⁻¹")
            } else {
                descriptionArray.insert("(", at: descriptionArray.index(before: descriptionArray.endIndex))
                descriptionArray.append(")" + "⁻¹")
            }
        
        default:
            symbol = wrapSymbol
            if lastOperation == .unaryOperation {
                performOperation("=")
            }
            if lastOperation == .equals {
                descriptionArray.insert(symbol + "(", at: descriptionArray.startIndex)
                descriptionArray.append(")")
            }
            else {
                descriptionArray.insert(symbol + "(", at: descriptionArray.index(before: descriptionArray.endIndex))
                descriptionArray.append(")")
            }
        }
    }
}
