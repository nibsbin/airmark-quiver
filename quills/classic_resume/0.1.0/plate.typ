#import "@local/quillmark-helper:0.1.0": data
#import "@local/ttq-classic-resume:0.2.0": *

#show: resume

// String passthrough: empty/missing -> none, otherwise the string itself.
// Field values render as plain text; inline markdown and Typst markup are
// not evaluated. Use the card body for prose.
#let render(v) = {
  if v == none or v == "" { none }
  else { v }
}

// Auto-link http(s):// and mailto: contacts. Everything else is plain text.
#let render-contact(s) = {
  if type(s) != str { return s }
  if s.starts-with("http://") or s.starts-with("https://") {
    let display = s.replace(regex("^https?://"), "").trim("/", at: end)
    link(s)[#display]
  } else if s.starts-with("mailto:") {
    link(s)[#s.slice(7)]
  } else {
    s
  }
}

// Quillmark sets BODY to the empty string when there's no markdown body and
// to rendered content otherwise. Coerce to none / content for component use.
#let card-body(card) = {
  let b = card.at("BODY", default: "")
  if type(b) == str { none } else { b }
}

#header(
  name: render(data.at("name", default: none)),
  contacts: data.at("contacts", default: ()).map(render-contact),
)

// Document body becomes the summary paragraph.
#let main-body = data.at("BODY", default: none)
#if main-body != none and type(main-body) != str { summary(main-body) }

#for card in data.at("CARDS", default: ()) {
  // Optional per-card section header. Renders nothing when blank.
  let h = card.at("header", default: "")
  if h != "" { section(h) }

  let t = card.CARD
  if t == "certifications" {
    skills(
      card.at("items", default: ()),
      columns: card.at("columns", default: 2),
    )
  } else if t == "skills" {
    skills(
      card.at("items", default: ()),
      columns: card.at("columns", default: 2),
    )
  } else if t == "experience" {
    entry(
      heading-left: render(card.at("role", default: none)),
      heading-right: render(card.at("dates", default: none)),
      subheading-left: render(card.at("organization", default: none)),
      subheading-right: render(card.at("location", default: none)),
      body: card-body(card),
    )
  } else if t == "education" {
    entry(
      heading-left: render(card.at("degree", default: none)),
      heading-right: render(card.at("dates", default: none)),
      subheading-left: render(card.at("school", default: none)),
      subheading-right: render(card.at("location", default: none)),
      body: card-body(card),
    )
  } else if t == "competition" {
    entry(
      heading-left: render(card.at("title", default: none)),
      body: card-body(card),
    )
  } else if t == "project" {
    let url = card.at("url", default: "")
    entry(
      heading-left: render(card.at("name", default: none)),
      heading-right: if url != "" { monolink(url) } else { none },
      body: card-body(card),
    )
  } else if t == "award" {
    let issuer = card.at("issuer", default: "")
    let title-bold = [*#render(card.at("title", default: none))*]
    let left = if issuer != "" {
      [#title-bold — #issuer]
    } else {
      title-bold
    }
    compact-entry(left, right: render(card.at("date", default: none)))
  }
}
