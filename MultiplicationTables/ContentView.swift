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
    var body: some View {
        
        // MARK: - Pregame setup screen
        
        if gameState == .preGame {
            
            Form {
                
                Text("Multiplication Practice")
                    .dynamicTypeSize(.xxxLarge)
                    .frame(maxWidth:.infinity)
                
                
                Section {
                    Text("Tap a times table to add it to the game...")
                        .dynamicTypeSize(.xxLarge)
                    VStack {
                        //                        HStack(spacing: 0) {
                        //                            ForEach(0..<7) {number in
                        //                                NumberButton(number: number, tables: $qanda.tables)
                        //                                }
                        //                            }
                        //
                        //                        HStack(spacing: 0) {
                        //                            ForEach(7..<13) {number in
                        //                                NumberButton(number: number, tables: $qanda.tables)
                        //                            }
                        //                        }
                        HStack {
                            ForEach(0..<6) {number in
                                Button(String(number)) { [number] in
                                    self.buttonTapped(number)
                                }
                            }
                        }
                    }
                }
                
                Section {
                    
                    Text("How many questions do you want?")
                        .dynamicTypeSize(.xxLarge)
                    
                    Picker("I can answer this many questions...", selection:$numberOfQuestions) {
                        ForEach([5,10,20], id: \.self) {
                            Text($0, format: .number)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Text("Your time to beat is...")
                    Text("\(timeToBeat().oneDecimalString()) SECONDS")
                        .frame(maxWidth: .infinity)
                }
                
                
                Button("Let's Go!") {
                    startGame()
                }
                .modifier(BigButton())
                
            } // End of form
            
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
                        
                        let base = min(geo.size.width * 0.75, geo.size.height * 0.5)
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
                            
                            Text("New Fastest Time!\n\(time.oneDecimalString())")
                                .font(.system(size: 24, weight: .black))
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: base, height: height)
                        .position(x: geo.size.width * 0.5, y: geo.size.height * 0.5)
                        
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
            if time < timeToBeat() {
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
        
        var body: some View {
            
            Button("x" + String(number)){
                if tables.contains(number) {
                    tables.remove(number)
                } else {
                    tables.insert(number)
                }
                print("tables: ", tables)
                print("button pressed, number: ", number)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .fontWeight(.black)
            .foregroundColor(Palette.shared.colors[number % 11])
            .background(Palette.shared.complimentary[number % 11])
            .clipShape(Circle())
            .background(Palette.shared.colors[number % 11].opacity(tables.contains(number) ? 1.0 : 0.0))
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
        ContentView(gameState: .preGame, newRecordTime: true)
    }
}
