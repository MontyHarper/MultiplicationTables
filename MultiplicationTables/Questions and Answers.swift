//
//  Questions and Answers.swift
//  MultiplicationTables
//
//  Created by Monty Harper on 8/8/23.
//

import Foundation
import SwiftUI



struct QView: View {
    @State private var x:Int
    @State private var y:Int
  
    init(max: Int) {
        x = Int.random(in: 1...max)
        y = Int.random(in: 1...max)
    }
    
    var answer:Int {
        return x * y
    }
    
    var body: some View {
        VStack {
            Text("Find")
            Text("\(x) X \(y)")
        }.fontWeight(.heavy)
            .dynamicTypeSize(.xxxLarge)
            .frame(width:100, height:75)
            .background(.green)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width:10, height:10)))
    }
}

struct AView: View {
    @State var answer:Int
    var id = UUID()
    
    var body: some View {
 
            Text("\(answer)")
                .fontWeight(.heavy)
                .dynamicTypeSize(.xxxLarge)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(.blue)
                .clipShape(Circle())
    }
}

func generateQuestions(number:Int, max:Int) -> [QView] {
    var array = [QView]()
    for _ in 1...number {
        array.append(QView(max:max))
    }
    return array
}

func generateAnswers(answer:Int, max:Int) -> [AView] {
    var array = [AView]()
    array.append(AView(answer: answer))
    for _ in 1...4 {
        
        array.append(AView(answer: Int.random(in:1...max) * Int.random(in:1...max)))
    }
    array.shuffle()
    return array
}
