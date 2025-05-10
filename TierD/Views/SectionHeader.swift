//
//  SectionHeader.swift
//  TierD
//
//  Created by Pacholo Amit on 5/10/25.
//


import SwiftData
import SwiftUI

struct SectionHeader: View {
    let title: String
    let colorScheme: ColorScheme
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.8) : .secondary)
    }
}