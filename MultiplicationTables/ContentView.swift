//
//  ContentView.swift
//  MultiplicationTables
//
//  Created by Monty Harper on 8/8/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var gameOn = false
    @State private var score = 0
    @State private var correct = true
    @State private var maxOperand:Int = 10
    @State private var numberOfQuestions = 5
    @State private var questionNumber = 0
    @State private var answers = [AView]()
    @State private var questions = [QView]()
    
    var body: some View {
        
        if !gameOn {
            
                
                VStack {
                    
                    Spacer()
                    
                    Form {
                        
                        Text("Multiplication Practice")
                            .dynamicTypeSize(.xxxLarge)
                            .frame(maxWidth:.infinity)
                            .multilineTextAlignment(.center)
                        
                        
                        
                        Section {
                            
                            Text("I can multiply numbers as big as...")
                                .dynamicTypeSize(.xxLarge)
                            
                            Picker("I can multiply numbers as big as...", selection:$maxOperand) {
                                ForEach(2...12, id: \.self) {
                                    Text($0, format: .number)
                                }
                            } .pickerStyle(.segmented)
                            
                        }
                        
                        Section {
                            
                            Text("I can answer this many questions...")
                                .dynamicTypeSize(.xxLarge)
                            
                            Picker("I can answer this many questions...", selection:$numberOfQuestions) {
                                ForEach([5,10,20], id: \.self) {
                                    Text($0, format: .number)
                                }
                            } .pickerStyle(.segmented)
                        }
                        
                        Button("Start Game") {
                            startGame()
                        }
                        .buttonStyle(.bordered)
                        .dynamicTypeSize(.xxLarge)
                        .background(.green)
                        .foregroundColor(.white)
                        .frame(maxWidth:.infinity)
                        
                        
                        
                    }
                
                
            }
        } else {
            
            GeometryReader { geo in
                
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        questions[questionNumber].body
                            .onTapGesture {
                                newQuestion()
                            }
                        Spacer()
                        
                        
                            Text("Score: \(score)/\(numberOfQuestions)")
                                .dynamicTypeSize(.xxLarge)
                        
                        
                        Spacer()
                        HStack {
                            ForEach (answers, id: \.id) {answer in
                                answer
                                    .onTapGesture {
                                        processAnswer(answer)
                                    }
                                    
                            }
                        }
                        Spacer()
                        Spacer()
                    }
                    Spacer()
                    
                }
            }
        }
    }
    
    
    func newQuestion() {
        questionNumber += 1
        if questionNumber >= numberOfQuestions {
            gameOn = false
            return
        }
        answers = generateAnswers(answer: questions[questionNumber].answer, max: maxOperand)
    }
    
    func startGame() {
        questions = generateQuestions(number:numberOfQuestions, max:maxOperand)
        questionNumber = -1
        gameOn = true
        score = 0
        newQuestion()
    }
    
    func processAnswer(_ answer:AView) {
        if answer.answer == questions[questionNumber].answer {
            print("yes")
            score += 1
            correct = true
        } else {
            print("no")
            correct = false
        }
        newQuestion()
    }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
