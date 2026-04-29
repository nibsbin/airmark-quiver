// mainmatter.typ: Mainmatter show rule for USAF memorandum
//
// This module implements the mainmatter (body text) of a USAF memorandum per
// AFH 33-337 Chapter 14 "The Text of the Official Memorandum" (§1-12).

#import "body.typ": *

/// Mainmatter show rule for USAF memorandum body content.
///
/// AFH 33-337 "The Text of the Official Memorandum" §1-12 requirements:
/// - Begin text on second line below subject/references
/// - Single-space text, double-space between paragraphs
/// - Number and letter each paragraph/subparagraph
/// - First paragraph flush left, never indented
///
/// Numbering behavior is determined entirely by `memo_style`:
/// - `"usaf"`: every top-level paragraph numbered `1.`, `2.`, …; nested
///   items numbered hierarchically.
/// - `"daf"`: top-level paragraphs unnumbered with a fixed first-line
///   indent; nested items numbered.
///
/// AFH §2's "single paragraph is not numbered" carve-out is intentionally
/// not implemented — see `body.typ` for the rationale.
///
/// - content (content): The body content to render
/// -> content
#let mainmatter(it) = context {
  let config = query(metadata).last().value
  let memo-style = config.at("memo_style", default: "usaf")
  render-body(it, memo-style: memo-style)
}
