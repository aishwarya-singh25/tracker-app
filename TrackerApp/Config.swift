//
//  Config.swift
//  TrackerApp
//
//  Supabase project config. The URL and anon key are meant to be public —
//  they're safe to ship in client code. Actual data access is protected by
//  Row Level Security policies (see supabase/schema.sql), not by hiding
//  these values.
//

import Foundation

enum SupabaseConfig {
    static let url = URL(string: "https://lfniyotdaosjybahmovy.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxmbml5b3RkYW9zanliYWhtb3Z5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODcwMDc1NzgsImV4cCI6MjEwMjU4MzU3OH0.rIuVR7xs06tB-PT4B2H-ArBWXBgnBxGGWVodSKXWrD4"
}
