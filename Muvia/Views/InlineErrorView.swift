//
//  InlineErrorView.swift
//  Muvia
//
//  Created by Alexander Bralnin on 15.04.2025.
//

import SwiftUI

struct InlineErrorView: View {
    let message: String

    var body: some View {
        Text(message)
            .foregroundColor(.red)
            .font(.footnote)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .transition(.opacity)
    }
}
