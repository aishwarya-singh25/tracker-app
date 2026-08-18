//
//  SupabaseService.swift
//  TrackerApp
//
//  Single shared Supabase client for the app.
//

import Foundation
import Supabase

enum SupabaseService {
    static let client = SupabaseClient(
        supabaseURL: SupabaseConfig.url,
        supabaseKey: SupabaseConfig.anonKey
    )
}
