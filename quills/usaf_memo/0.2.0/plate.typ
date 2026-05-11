#import "@local/quillmark-helper:0.1.0": data, signature-field
#import "@local/tonguetoquill-usaf-memo:3.0.0": backmatter, frontmatter, indorsement, mainmatter

// Signature field builder: a thin stroke around the AcroForm signature widget,
// sized by `render-signature-block` to fill the 4-line gap above the signature.
#let signing-box(name) = (width, height) => box(
  width: width,
  height: height,
  stroke: 0.4pt + luma(60%),
  signature-field(name, width: width, height: height),
)

// Frontmatter configuration
#show: frontmatter.with(
  // Letterhead configuration
  letterhead_title: data.letterhead_title,
  letterhead_caption: data.letterhead_caption,
  letterhead_seal_subtitle: data.at("letterhead_seal_subtitle", default: none),
  letterhead_seal: image(
    if data.at("letterhead_seal", default: "dow") == "dod" {
      "assets/dod_seal.png"
    } else {
      "assets/dow_seal.png"
    }
  ),

  // Date
  date: data.at("date", default: none),

  // Receiver information
  memo_for: data.memo_for,

  // Sender information
  memo_from: data.memo_from,

  // Subject line
  subject: data.subject,

  // Optional references
  ..if "references" in data { (references: data.references) },

  // Optional footer tag line
  ..if "tag_line" in data { (footer_tag_line: data.tag_line) },

  // Optional classification level
  ..if "classification" in data { (classification_level: data.classification) },

  ..if "dissemination" in data { (dissemination: data.dissemination) },

  // USAF vs DAF memorandum style (date format, body indentation)
  memo_style: data.at("memo_style", default: "usaf"),

  // Font size
  font_size: data.at("font_size", default: 12) * 1pt,

  // List recipients in vertical list
  memo_for_cols: 1,
)

// Mainmatter configuration
#mainmatter[
  #data.BODY
]

// Backmatter
#backmatter(
  // Signature block
  signature_block: data.signature_block,

  // Visible AcroForm signature widget filling the 4-line gap above the block.
  signature_field: signing-box("primary_signature"),

  // Optional cc
  ..if "cc" in data { (cc: data.cc) },

  // Optional distribution
  ..if "distribution" in data { (distribution: data.distribution) },

  // Optional attachments
  ..if "attachments" in data { (attachments: data.attachments) },
)

// Indorsements - iterate through CARDS array and filter by CARD type
#{
  let ind_index = 0
  for card in data.CARDS {
    if card.CARD == "indorsement" {
      ind_index += 1
      // The quillmark helper leaves an unset/whitespace-only markdown body as
      // the empty string `""`; only non-empty bodies are eval'd into content.
      // Pass truly empty content (`[]`) in the empty case so indorsement can
      // collapse the body's surrounding spacing.
      let body = card.at("BODY", default: "")
      let body_content = if type(body) == str { [] } else { body }
      // Per AFH 33-337 Ch. 14, an indorsement is dated when the endorser signs
      // it (distinct from the originating memo's date). Default to today when
      // the card omits or leaves the date blank.
      let card_date = card.at("date", default: none)
      let resolved_date = if card_date == none or card_date == "" {
        datetime.today()
      } else {
        card_date
      }
      indorsement(
        from: card.at("from", default: ""),
        to: card.at("for", default: ""),
        signature_block: card.signature_block,
        // Field names must be unique across the document; encode the card's
        // 1-based position so each indorsement gets its own widget.
        signature_field: signing-box("indorsement_" + str(ind_index) + "_signature"),
        ..if "attachments" in card { (attachments: card.attachments) },
        ..if "cc" in card { (cc: card.cc) },
        format: card.at("format", default: "standard"),
        date: resolved_date,
        ..if "action" in card { (action: card.action) },
        body_content,
      )
    }
  }
}
