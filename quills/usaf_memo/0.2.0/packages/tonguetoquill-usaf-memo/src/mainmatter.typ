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
/// - "A single paragraph is not numbered" (§2)
/// - First paragraph flush left, never indented
///
/// Numbering behavior is determined by `memo_style`:
/// - `"usaf"`: AFH 33-337 §2 — multiple top-level paragraphs numbered
///   `1.`, `2.`, …; a lone top-level paragraph renders flush left without
///   a number.
/// - `"daf"`: top-level paragraphs unnumbered with a fixed first-line
///   indent; nested items numbered.
///
/// Indorsements automatically opt out of the §2 single-paragraph
/// carve-out — `render-body` detects indorsement context by reading the
/// `counters.indorsement` value (which `indorsement.typ` steps before
/// rendering the body).
///
/// - content (content): The body content to render
/// -> content
#let mainmatter(it) = context {
  let config = query(metadata).last().value
  let memo-style = config.at("memo_style", default: "usaf")
  render-body(it, memo-style: memo-style)
}
