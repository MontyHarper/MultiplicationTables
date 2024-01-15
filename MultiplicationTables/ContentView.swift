//
//  ContentView.swift
//  MultiplicationTables
//
//  Created by Monty Harper on 8/8/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var qanda = QAndAService()
    @State var gameState = GameState.preGame
    @State private var score = 0
    @State private var numberOfQuestions = 5
    @State private var questionNumber = 0
    
    @State private var startTime = 0.0
    @State private var time = 0.0
    @State var newRecordTime = false
    
    @State private var rotate = 0.0
    
    private var gameKey: String {
        String(numberOfQuestions) + Array(qanda.tables).sorted().map({"*" + String($0)}).joined()
    }
    
    private var repeatAnimation: Animation {
        .linear
        .speed(0.009)
        .repeatForever()
    }
    
    private var tablesFormatted: String {
        let names = Array(qanda.tables).sorted(by: {$1 < $0}).map({String($0)+"\'s "})
        var response = names.count > 1 ? "tables" : "table"
        
        for index in 0..<names.count {
            if index == 0 && names.count > 1 {
                response = "and " + names[index] + response
            } else if names.count > 1 {
                response = names[index] + (index == 1 ? ", " : " ") + response
            } else {
                response = names[index] + response
            }
        }
        return response
    }
    
    var body: some View {
        
        // MARK: - Pregame setup screen
        
        if gameState == .preGame {
            
            // Note: I don't know why, but a ForEach inside an HStack inside a Form does not seem to work. If I arrange my buttons that way they all fire at once, any time you press a button. So I can't use form here; that's why it's a VStack.
 
            ScrollView {
                
                VStack {
                    
                    Spacer()
                    
                    Text("Multiplication Practice")
                        .dynamicTypeSize(.xxxLarge)
                        .fontWeight(.black)
                    
                    
                    Group {
                        
                        Text("Tap a times table to add it to the game...")
                            .dynamicTypeSize(.xxLarge)
                        VStack {
                            HStack(spacing: 0) {
                                ForEach(0..<7) {number in
                                    NumberButton(number: number, tables: $qanda.tables, showBG: qanda.tables.contains(number))
                                }
                            }
                            
                            HStack(spacing: 0) {
                                ForEach(7..<13) {number in
                                    NumberButton(number: number, tables: $qanda.tables, showBG: qanda.tables.contains(number))
                                }
                            }
                            
                        }
                    }
                    
                    
                    Group {
                        Text("How many questions do you want?")
                            .dynamicTypeSize(.xxLarge)
                        
                        Picker("How many questions do you want?", selection:$numberOfQuestions) {
                            ForEach([5,10,20], id: \.self) {
                                Text($0, format: .number)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Spacer()
                    
                    
                    VStack {
                        
                        Text("Ready?")
                            .dynamicTypeSize(.xxLarge)
                            .fontWeight(.black)
                            .padding(10)
                        
                        
                        Text("For \(numberOfQuestions) questions from the \(tablesFormatted)...")
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Can you beat \(timeToBeat().oneDecimalString()) seconds?")
                            .dynamicTypeSize(.xxxLarge)
                            .fontWeight(.black)
                            .multilineTextAlignment(.center)
                        
                        Button("Let's Go!") {
                            startGame()
                        }
                        .modifier(BigButton())
                    }
                    .padding(20)
                    
                    Spacer()
                    
                } // End of VStack
            } // End of ScrollView
        
            
            // MARK: - Game On screen
            
        } else if gameState == .gameOn {
            
            VStack {
                Spacer()
                QuestionView(question: qanda.questions[questionNumber - 1])
                Spacer()
                Text("Score: \(score)/\(numberOfQuestions)")
                    .dynamicTypeSize(.xxLarge)
                Spacer()
                HStack {
                    ForEach (qanda.answers) {answer in
                        AnswerView(answer: answer)
                            .onTapGesture {
                                processAnswer(answer)
                            }
                    }
                }
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
            
            // MARK: - Postgame results screen
            
        } else {
            
            VStack {
                Text("Game Over")
                    .dynamicTypeSize(.xxLarge)
                    .fontWeight(.black)
                
                Text(score == numberOfQuestions ? "You answered all \(numberOfQuestions) questions correctly in \(time.oneDecimalString()) seconds!" : "You answered \(score) out of \(numberOfQuestions) questions correctly in \(time.oneDecimalString()) seconds.")
                
                Spacer()
                
                if newRecordTime {
                    GeometryReader { geo in
                        
                        let base = min(geo.size.width * 0.75, geo.size.height * 0.75)
                        let height = base * sqrt(3)/2
                        
                        ZStack {
                            
                            ForEach(0..<10) {n in
                                Triangle()
                                    .fill(Palette.shared.colors[n])
                                    .opacity(0.5)
                                    .rotationEffect(Angle(degrees: Double(36 * n)), anchor: UnitPoint(x: 0.5, y: 0.6666666))
                            }
                            .offset(x: 0.0, y: ((1/2 - 2/3) * height))
                            .rotationEffect(Angle(radians: rotate))
                            
                            .onAppear() {
                                withAnimation(repeatAnimation) {
                                    rotate += 360
                                }
                            }
                        }
                        .frame(width: base, height: height)
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
                        .overlay {
                            Text("New Fastest Time!\n\(time.oneDecimalString())")
                                .font(.system(size: 24, weight: .black))
                                .multilineTextAlignment(.center)
                        }
                        
                    }
                }
                
                Button("Let's Go Again!") {
                    startGame()
                }
                .modifier(BigButton())
                
                Button("Change Settings") {
                    gameState = .preGame
                }
                .modifier(BigButton(color: .blue))
                
                Spacer()
                Spacer()
                
            }
        }
    } // End of body.
    
    
    // MARK: - Functions and such
    
    func buttonTapped(_ number: Int) {
        print("number is: ", number)
    }
    
    struct BigButton: ViewModifier {
        
        var color: Color = .green
        
        func body(content: Content) -> some View {
            
            content
                .buttonStyle(.bordered)
                .dynamicTypeSize(.xxLarge)
                .background(color)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .frame(maxWidth:.infinity)
        }
    }
    
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: rect.midX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            }
        }
    }
    
    func startGame() {
        qanda.generateQuestions(quantity: numberOfQuestions)
        questionNumber = 1
        gameState = .gameOn
        score = 0
        newQuestion()
        startTime = Date().timeIntervalSince1970
    }
    
    func processAnswer(_ answer: Answer) {
        
        if answer.answer == qanda.questions[questionNumber - 1].answer {
            score += 1
        }
        
        questionNumber += 1
        
        if questionNumber > numberOfQuestions {
            gameState = .gameOver
            time = Date().timeIntervalSince1970 - startTime
            if time < timeToBeat() && score == numberOfQuestions {
                UserDefaults.standard.set(time, forKey: gameKey)
                newRecordTime = true
            } else {
                newRecordTime = false
            }
        } else {
            newQuestion()
        }
    }
    
    func newQuestion() {
        qanda.generateAnswers(including: qanda.questions[questionNumber - 1].answer)
    }
    
    // MARK: Number Button
    
    struct NumberButton: View {
        
        var number: Int
        @Binding var tables: Set<Int>
        var showBG: Bool
        
        var body: some View {
            
            Button("x" + String(number)){
                if tables.contains(number) && tables.count > 1 {
                    tables.remove(number)
                } else {
                    tables.insert(number)
                }

            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .fontWeight(.black)
            .foregroundColor(Palette.shared.colors[number % 11])
            .background(Palette.shared.complimentary[number % 11])
            .clipShape(Circle())
            .background(Palette.shared.colors[number % 11].opacity(showBG ? 1.0 : 0.0))
        }
    }
    
    func timeToBeat() -> Double {
        
        if let time = UserDefaults.standard.object(forKey: gameKey) as? Double {
            return time
        } else {
            return 10.0 * Double(numberOfQuestions)
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(gameState: .gameOver, newRecordTime: true)
    }
}
