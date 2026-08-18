# Habit Tracker App — Plan

## Overview

A simple habit tracker for iOS. The home screen splits the day into **Morning /
Afternoon / Evening / Night** blocks, each habit is checked off once per day,
and streaks are tracked for motivation. Data syncs via email login so the app
works across devices. Ships with a home-screen widget, and iOS is the only
target for v1.

## Decisions locked in

- **Stack:** Native Swift + SwiftUI (Xcode) for the app, Supabase (Postgres,
  via the `supabase-swift` SDK) for auth + data sync, email OTP (6-digit
  code) for login.
  - Rationale: single stack, no bridge layer — the app, the widget
    (WidgetKit), and later HealthKit are all plain Swift/SwiftUI, which is
    the most natural fit for all three. Fully free to build and test on your
    own device with a personal Apple ID (only publishing to TestFlight/App
    Store needs the $99/year Apple Developer Program). Backend (Supabase)
    stays framework-agnostic, so it's still reusable if a website is ever
    built later — just not the UI code, which is iOS-only.
  - Trade-off accepted: this replaces the earlier Expo/React Native plan.
    The app's UI code will *not* carry over to a future website (that would
    be a separate build against the same Supabase backend), and it's
    Swift-only rather than JS/TS.
- **Habit scheduling:** one habit belongs to exactly one time block
  (Morning/Afternoon/Evening/Night) — no duplicates across blocks.
- **Habit type (v1):** simple done/not-done check-off only. No quantified
  goals (steps, minutes, reps) in v1.
- **Streak rule:** daily check-off, with **2 grace days per week** — a week
  (Mon–Sun) still "counts" toward the streak as long as at most 2 days in it
  are missed.
- **Habit styling:** user picks an emoji and a color per habit at creation
  (curated preset pickers, not full custom hex/emoji search).
- **Views:**
  - The app itself shows **only the Today view**, with a date strip to
    navigate between days.
  - The **weekly grid view** (habit rows × Mon–Sun dot columns) lives in the
    **widget**, not in the app.
- **Gamification:** skip badges/achievements (e.g. "PERFECT" week) for v1.
- **Un-checking a habit** deletes that day's log row rather than storing a
  false/undone state — keeps the data model simple.
- **No limit** on number of habits per time block.
- **Scope:** this is a real build (not a throwaway prototype) — intended for
  daily personal use once done. No hard deadline; take the time needed to do
  it right.
- **Distribution: free Apple ID only, no paid Developer Program** — the app
  is for personal use on one phone, not public App Store distribution.
  Deployed by running from Xcode onto the phone directly. Consequence: the
  install expires every 7 days and must be re-run from Xcode to keep
  working (a free-tier limitation, not a bug). HealthKit (Phase 3, below)
  is permanently unavailable unless this decision is revisited later.

## Fast-follow features (not v1, planned for later)

- **Home-screen widget** showing the weekly dot-grid view.
- **Apple HealthKit integration** — auto-mark habits done based on Health
  data (e.g. sleep goal, step count) instead of manual check-off.
  - Straightforward to add in native Swift (`import HealthKit`), same
    project, no new tooling.
  - **On hold indefinitely** — requires a paid Apple Developer Program
    account, and the decision (see above) is to stay on the free tier.
    Revisit only if that decision changes.
  - iOS only — would not carry over to Android/web if built later.

## Screens (v1)

1. **Sign in** — email input → 6-digit OTP input. Session persisted on-device
   (iOS Keychain) so sign-in isn't required every launch.
2. **Home / Today**
   - 7-day date strip at the top to navigate between days; today highlighted.
   - Four sections — Morning / Afternoon / Evening / Night — each with a
     header and a **+** to add a habit into that block.
   - Each habit renders as a colored row: emoji · name · streak flame + count
     · checkmark to toggle done for the selected date.
   - Empty block: just the **+**, no placeholder clutter.
3. **Add/Edit Habit** (modal/sheet) — name, emoji picker (curated preset
   grid, or system emoji keyboard), color picker (preset swatches), time
   block assignment. Also handles archive/delete.
4. **Widget** (fast-follow) — weekly dot-grid view (habit rows × Mon–Sun
   columns, colored dots per completed day), current week at a glance.

## Data model (Supabase / Postgres)

- **`habits`**
  `id, user_id, name, emoji, color, time_block (morning|afternoon|evening|night), sort_order, archived_at, created_at`
- **`habit_logs`**
  `id, habit_id, user_id, log_date, completed_at`
  One row per habit per day it was completed. Un-checking deletes the row for
  that day.
- **`profiles`** (optional, likely skippable for v1) — mirrors `auth.users`,
  would hold display name/avatar if ever needed.
- Row-Level Security on every table: `user_id = auth.uid()`.

Streaks are **computed on read** from `habit_logs` (not stored as a mutable
column) — avoids drift between a cached number and reality; cheap to compute
at this data scale (single user, few habits).

## Streak calculation

Walk backward week by week (Mon–Sun) from the current date:

1. Within a week, count missed days (no log row, excluding future days).
2. If misses ≤ 2 → the week counts; continue walking into the prior week.
3. If misses > 2 → streak stops there.

Current streak = consecutive days credited up to today under this rule. Day
boundary uses the device's local timezone (midnight-to-midnight).

## Auth & sync

Supabase Auth, email OTP. On sign-in, fetch all habits + recent logs once
into local state. Every toggle writes to Supabase immediately (optimistic UI
update, rollback on failure). No realtime subscription needed for a single
user — fetch-on-load/fetch-on-resume is sufficient.

## Widget architecture (fast-follow)

- WidgetKit extension target added directly in Xcode (File → New → Target →
  Widget Extension), built with SwiftUI like the main app — no bridge
  tooling needed.
- Data sharing: main app writes the current week's completion grid into a
  shared **App Group** container (UserDefaults or a small shared
  SwiftData/CoreData store) whenever a habit is toggled; the widget reads
  from that shared container — no network call from the widget itself, so
  it stays fast and works offline. App Groups work fine on a free personal
  Apple ID for local testing, no paid account needed for this part.
- Widget requests a timeline reload whenever the shared data changes.

## Build order

1. Project scaffold — Xcode project (App template, SwiftUI + Swift), add
   `supabase-swift` package, Supabase project + schema + RLS policies.
2. Auth — email OTP sign-in/out, session persistence via Keychain.
3. Core Today screen — time blocks, add/edit habit, check-off, streak
   calculation.
4. Date navigation — 7-day strip, viewing/editing past days.
5. Polish pass — empty states, color/emoji picker UX, loading/offline
   handling.
6. Run on personal device via Xcode (free, own Apple ID) — this **is** the
   deployment method for this app (see "Distribution" decision above).
   Re-run from Xcode every 7 days to renew the install.
7. Widget (fast-follow phase) — add Widget Extension target, App Groups.
   Works fine on the free tier.
8. ~~HealthKit auto check-off~~ — on hold indefinitely, requires paid
   Developer Program account (see "Distribution" decision above).
9. ~~TestFlight / App Store submission~~ — not planned; would require the
   paid Developer Program account. Revisit only if the distribution
   decision changes.
