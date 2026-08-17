# Habit Tracker App — Plan

## Overview

A simple habit tracker for iOS. The home screen splits the day into **Morning /
Afternoon / Evening / Night** blocks, each habit is checked off once per day,
and streaks are tracked for motivation. Data syncs via email login so the app
works across devices. Ships with a home-screen widget, and iOS is the only
target for v1.

## Decisions locked in

- **Stack:** Expo (React Native + TypeScript) for the app, Supabase
  (Postgres) for auth + data sync, email OTP (6-digit code) for login.
  - Rationale: zero cost to start, easy to reason about as a first app,
    reusable toward a website later (React Native Web + same Supabase
    backend works well with Next.js), and easy to add more users later
    (schema is already multi-user-safe via Supabase Row-Level Security).
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

## Fast-follow features (not v1, planned for later)

- **Home-screen widget** showing the weekly dot-grid view.
- **Apple HealthKit integration** — auto-mark habits done based on Health
  data (e.g. sleep goal, step count) instead of manual check-off.
  - No stack change required; needs a custom native dev client (EAS Build,
    not plain Expo Go) since HealthKit is native-only — the same build setup
    the widget already requires.
  - Requires a **paid Apple Developer Program account** (HealthKit
    entitlements aren't available on free accounts) and a physical iPhone to
    test (simulator has no real Health data).
  - iOS only — would not carry over to Android/web if built later.

## Screens (v1)

1. **Sign in** — email input → 6-digit OTP input. Session persisted on-device
   (Expo SecureStore) so sign-in isn't required every launch.
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

- Native WidgetKit extension (Swift), added via an Expo config plugin /
  prebuild — this moves the project off plain "Expo Go" onto a custom dev
  client / EAS Build (needed for HealthKit too, later).
- Data sharing: main app writes the current week's completion grid into a
  shared **App Group** container (JSON file or shared UserDefaults) whenever
  a habit is toggled; the widget reads from that shared container — no
  network call from the widget itself, so it stays fast and works offline.
- Widget requests a timeline reload whenever the shared data changes.

## Build order

1. Project scaffold — Expo + TypeScript, navigation, Supabase project +
   schema + RLS policies.
2. Auth — email OTP sign-in/out, session persistence.
3. Core Today screen — time blocks, add/edit habit, check-off, streak
   calculation.
4. Date navigation — 7-day strip, viewing/editing past days.
5. Polish pass — empty states, color/emoji picker UX, loading/offline
   handling.
6. TestFlight — once the Apple Developer account is confirmed enrolled, get
   the app on-device for daily use.
7. Widget (fast-follow phase).
8. HealthKit auto check-off (fast-follow phase).
9. App Store submission — listing, screenshots, privacy nutrition label
   (relevant once HealthKit is added, since Apple requires disclosure of
   health-data usage).

## Open item to confirm before/during deployment

- **Apple Developer Program enrollment** ($99/year) — status unconfirmed as
  of this writing. Not required to start building or testing in a custom dev
  client, but required for TestFlight/App Store distribution and for
  HealthKit entitlements. Worth confirming/starting enrollment early since
  approval can take a day or two.
