import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  // ─── Brand / Primary ───────────────────────────────────────────────
  static const Color navy = Color(
    0xFF002C5E,
  ); // Main brand — AppBar, buttons, active pills, primary text
  static const Color navyHover = Color(
    0xFF003875,
  ); // Pressed/hover state on navy buttons

  // ─── Blues (accents & containers) ─────────────────────────────────
  static const Color blue50 = Color(
    0xFFEFF6FF,
  ); // Budget card bg, expense icon bg (History), info banner bg
  static const Color blue100 = Color(
    0xFFDBEAFE,
  ); // Budget card border, focus ring color
  static const Color blue200 = Color(
    0xFFBFDBFE,
  ); // Selected category border, excluded-info border
  static const Color blue600 = Color(
    0xFF2563EB,
  ); // Checkmark circle bg, "Select All" link text
  static const Color blue700 = Color(
    0xFF1D4ED8,
  ); // Excluded-categories info text, "Select All" hover
  static const Color indigo50 = Color(
    0xFFEEF2FF,
  ); // Budget card gradient-end (from-blue-50 to-indigo-50)

  // ─── Surface / Background ─────────────────────────────────────────
  static const Color background = Color(
    0xFFF3F4F6,
  ); // gray-100 — scaffold bg, chart grid lines
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // Pure white — cards, bottom nav, inputs, progress track
  static const Color gray50 = Color(
    0xFFF9FAFB,
  ); // Row dividers, hover bg, tooltip cursor, input bg
  static const Color gray100 = Color(
    0xFFF3F4F6,
  ); // Card borders, category tag bg, preset btn bg, empty circle, progress track
  static const Color gray200 = Color(
    0xFFE5E7EB,
  ); // Pill container bg, input borders, nav border, slider track inactive

  // ─── Text / Icon Grays ────────────────────────────────────────────
  static const Color gray300 = Color(
    0xFFD1D5DB,
  ); // Chevron icons, disabled icons, excluded dot color, pipe separators
  static const Color gray400 = Color(
    0xFF9CA3AF,
  ); // Timestamps, "SEK" labels, search icon, nav inactive, chart axis ticks
  static const Color gray500 = Color(
    0xFF6B7280,
  ); // Section headers ("MY ACCOUNTS"), tooltip value, account numbers
  static const Color gray600 = Color(
    0xFF4B5563,
  ); // Inactive pill text, cancel btn text, tracked spending, preset text
  static const Color gray700 = Color(
    0xFF374151,
  ); // Category value amounts (non-excluded)

  // ─── Income / Success ─────────────────────────────────────────────
  static const Color green100 = Color(0xFFDCFCE7); // Income icon circle bg
  static const Color green600 = Color(
    0xFF16A34A,
  ); // Income amount text, income icon color

  // ─── Budget: On Track (Emerald) ───────────────────────────────────
  static const Color emerald100 = Color(0xFFD1FAE5); // "Current" badge bg
  static const Color emerald400 = Color(
    0xFF34D399,
  ); // On-track progress gradient start
  static const Color emerald500 = Color(
    0xFF10B981,
  ); // On-track progress gradient end
  static const Color emerald600 = Color(
    0xFF059669,
  ); // "On Track" icon & label text
  static const Color emerald700 = Color(0xFF047857); // "Current" badge text

  // ─── Budget: Warning (Amber) ──────────────────────────────────────
  static const Color amber400 = Color(
    0xFFFBBF24,
  ); // Warning progress gradient start
  static const Color amber500 = Color(
    0xFFF59E0B,
  ); // Warning progress gradient end
  static const Color amber600 = Color(
    0xFFD97706,
  ); // "Watch It" icon & label text

  // ─── Budget: Over / Error (Red) ───────────────────────────────────
  static const Color red50 = Color(
    0xFFFEF2F2,
  ); // Over-budget banner bg, error input bg
  static const Color red100 = Color(
    0xFFFEE2E2,
  ); // Over-budget banner border, expense icon bg (Home)
  static const Color red300 = Color(0xFFFCA5A5); // Error input border
  static const Color red500 = Color(0xFFEF4444); // Notification badge dot
  static const Color red600 = Color(
    0xFFDC2626,
  ); // "Over Budget" icon & label, error text, expense icon (Home)
  static const Color red700 = Color(
    0xFFB91C1C,
  ); // Over-budget detail message text

  // ─── White Overlays (on navy backgrounds) ─────────────────────────
  static const Color whiteOverlay5 = Color(
    0x0DFFFFFF,
  ); // Decorative blur circle on balance card
  static const Color whiteOverlay10 = Color(
    0x1AFFFFFF,
  ); // "Add Money" btn bg, AppBar icon hover bg
  static const Color whiteOverlay20 = Color(
    0x33FFFFFF,
  ); // "Add Money" btn border
  static const Color whiteOverlay70 = Color(
    0xB3FFFFFF,
  ); // "Total Balance" label text
  static const Color whiteOverlay80 = Color(
    0xCCFFFFFF,
  ); // "SEK" on balance card (opacity-80)

  // ─── Convenience Aliases ──────────────────────────────────────────
  static const Color textPrimary = navy; // Primary text is navy (NOT slate-900)
  static const Color textSecondary = gray400; // Timestamps, labels, muted text
  static const Color sectionHeader = gray500; // Uppercase section headers
  static const Color divider = gray50; // Transaction list row dividers
  static const Color borderDefault =
      gray200; // Default border for inputs, cards
  static const Color borderSubtle = gray100; // Subtle card borders
  static const Color income = green600; // Income amounts
  static const Color expense = navy; // Expense amounts (shown in navy)
  static const Color error = red600; // Error / destructive state
  static const Color softBlue = blue50; // Primary container background
}
