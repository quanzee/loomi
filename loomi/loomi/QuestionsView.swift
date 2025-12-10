//
//  QuestionsView.swift
//  loomi
//
//  Created by Janna Qian Zi Ng on 12/2/25.
//

import SwiftUI

struct QuestionsView: View {
    let questions: [String]
    
    @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationStack {
                List(questions, id: \.self) { question in
                    Text(question)
                }
                .navigationTitle("Conversation Starters")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
}
