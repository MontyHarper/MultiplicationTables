//
//  Questions and Answers.swift
//  MultiplicationTables
//
//  Created by Monty Harper on 8/8/23.
//
//  This file contains everything needed to generate and display questions and answers.
//

import Foundation
import SwiftUI

// These structs are so simple it feels like overkill, but I am practicing MVVM

// MARK: - View Models

struct Question: Identifiable {
    
    let id = UUID()
    let x: Int
    let y: Int
    let answer: Int
    
    init(max: Int) {
        x = Int.random(in: 1...max)
        y = Int.random(in: 1...max)
        answer = x * y
    }
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
        answer = x * y
    }
}
    
extension Question: Equatable {
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        (lhs.x == rhs.x &&
        lhs.y == rhs.y) ||
        (lhs.x == rhs.y &&
         lhs.y == rhs.x)
    }
}

extension Question: Hashable {
    
    func hash(into hasher: inout Hasher) {
        let min = min(x,y)
        let max = max(x,y)
        hasher.combine(min)
        hasher.combine(max)
    }
}


struct Answer: Identifiable {
    
    let id = UUID()
    let answer: Int
    
    init(max: Int) {
        let x = Int.random(in: 1...max)
        let y = Int.random(in: 1...max)
        answer = x * y
    }
    
    init(answer: Int) {
        self.answer = answer
    }
}


extension Answer: Equatable {
    
    static func == (lhs: Answer, rhs: Answer) -> Bool {
        lhs.answer == rhs.answer
    }
}


// MARK: - Views

struct QuestionView: View {
    
    let question: Question
  
    init(question: Question) {
        self.question = question
    }
    
    var body: some View {
        VStack {
            Text("Find")
            Text([0,1].randomElement() == 0 ? "\(question.x) X \(question.y)" : "\(question.y) X \(question.x)")
        }.fontWeight(.heavy)
            .dynamicTypeSize(.xxxLarge)
            .frame(width:100, height:75)
            .background(.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width:10, height:10)))
    }
}

struct AnswerView: View {

    let answer: Answer
    
    var body: some View {
 
        Text(String(answer.answer))
                .fontWeight(.heavy)
                .dynamicTypeSize(.xxxLarge)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(.blue)
                .clipShape(Circle())
    }
}

// MARK: - Business logic (Model)


class QAndAService: ObservableObject {
    
    @Published var questions = [Question]()
    @Published var answers = [Answer]()
    var tables = Set([2])
    
    private let maxY = 12 // Invariant
    
    
    
    func generateQuestions(quantity: Int) {
        
        // Two problems are considered the same if they have the same operands in either order.
        
        var possibleQuestions = Set<Question>()
                
        for x in tables {
            for y in 0...maxY {
                
                if !(possibleQuestions.contains(Question(x: x, y: y))) {
                    possibleQuestions.insert(Question(x: x, y: y))
                }
            }
        }
        
        questions = [Question]() // Reset the questions array.
        
        // Generate a new array with the required number of questions.
        
        var availableQuestions = Set<Question>()
        
        // Build our questions array by choosing from available questions until they are exhausted, then start over. That way we avoid repeating questions as much as possible.
        
        for _ in 1...quantity {
            
            if availableQuestions.count == 0 {
                availableQuestions = possibleQuestions
            }
            
            if let question = availableQuestions.randomElement() {
                questions.append(question)
                availableQuestions.remove(question)
            }
        }
    }
    
    func generateAnswers(including answer: Int) {
                
        // Create a set of five unique answers.
        var answerSet = Set<Int>()
        answerSet.insert(answer) // Include the actual answer.
        
        // Correct for the fact that if the only possible x is 0, we won't generate more than one answer!
        var possibleX = tables
        if possibleX == Set([0]) {
            possibleX = Set([1])
        }
        
        while answerSet.count < 5 {
            
            if let x = possibleX.randomElement() {
                let y = Int.random(in: 0...maxY)
                let answer = x * y
                if !answerSet.contains(answer) {
                    answerSet.insert(answer)
                }
            }
        }
        
        
        answers = answerSet.map({Answer(answer: $0)})
        
        answers.shuffle() // We need to shuffle the array or the correct answer will always be shown first.
    }
}
