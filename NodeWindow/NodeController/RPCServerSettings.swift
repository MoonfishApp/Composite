//
//  RPCServerSettings.swift
//  Composite
//
//  Created by Ronald "Danger" Mannak on 3/15/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

struct RPCServerSettings {
    
    // what if we created a
    // keyword: "accounts"
    // value: "2"
    // flag: "-a"
    
    
    /// Specify the number of accounts to generate at startup
    let accounts: Int?
    
    /// Amount of coins (e.g. Ether) to assign each test account.
    let defaultBalance: Int64?
    
    /// Specify blockTime in seconds for automatic mining. If you don't specify this flag, ganache will instantly mine a new block for every transaction. Using the --blockTime flag is discouraged unless you have tests which require a specific mining interval.
    let blockTime: TimeInterval?
    
    /// Generate deterministic addresses based on a pre-defined mnemonic.
    let deterministic: Bool?
    
    /// Lock available accounts by default (good for third party transaction signing)
    let secure: Bool?
    
    /// Use a bip39 mnemonic phrase for generating a PRNG seed, which is in turn used for hierarchical deterministic (HD) account generation.
    let mnenomic: [String]?
    
    /// Port number to listen on. Defaults to 8545.
    let port: Int
    
    /// Hostname to listen on. Defaults to 127.0.0.1 (defaults to 0.0.0.0 for Docker instances of ganache-cli).
    let host: String
    
    /// Use arbitrary data to generate the HD wallet mnemonic to be used.
    let seed: String
}
