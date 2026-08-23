//
//  Card.swift
//  HackingWithSwift-FlashZilla
//
//  Created by Michael Jones on 15/08/2026.
//

import Foundation

struct Card: Codable {
    var prompt: String
    var answer: String
    
    /// Static constant on the Card struct.
    static let example = Card(prompt: "What is 2 + 2?", answer: "4")
}
