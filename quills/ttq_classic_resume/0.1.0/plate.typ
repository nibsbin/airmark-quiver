#import "@local/quillmark-helper:0.1.0": data
#import "@local/ttq-classic-resume:0.2.0": *

#show: resume

// Render an optional string field as Typst markup. Lets users write *bold*,
// _italic_, and #link(...) in any string-typed field. Non-strings (e.g. an
// already-rendered content value) pass through; missing/empty values become
// `none` so the components can short-circuit.
#let render(v) = {
  if v == none { none }
  else if type(v) == str {
    if v == "" { none } else { eval(v, mode: "markup") }
  }
  else { v }
}

// Auto-link http(s):// and mailto: contacts. Everything else is Typst markup.
#let render-contact(s) = {
  if type(s) != str { return render(s) }
  if s.starts-with("http://") or s.starts-with("https://") {
    let display = s.replace(regex("^https?://"), "").trim("/", at: end)
    link(s)[#display]
  } else if s.starts-with("mailto:") {
    link(s)[#s.slice(7)]
  } else {
    eval(s, mode: "markup")
  }
}

// Build a bulleted list from an array of strings; `none` if empty.
#let bullets-body(items) = {
  if items == none or items.len() == 0 { return none }
  list(..items.map(b => render(b)))
}

#header(
  name: render(data.at("name", default: none)),
  contacts: data.at("contacts", default: ()).map(render-contact),
)

// Document body becomes the summary paragraph.
#let body = data.at("BODY", default: none)
#if body != none and type(body) != str { summary(body) }

#let xp = data.at("experience", default: ())
#if xp.len() > 0 {
  section[Experience]
  for e in xp {
    entry(
      heading-left: render(e.at("role", default: none)),
      heading-right: render(e.at("dates", default: none)),
      subheading-left: render(e.at("organization", default: none)),
      subheading-right: render(e.at("location", default: none)),
      body: bullets-body(e.at("bullets", default: none)),
    )
  }
}

#let edu = data.at("education", default: ())
#if edu.len() > 0 {
  section[Education]
  for e in edu {
    entry(
      heading-left: render(e.at("degree", default: none)),
      heading-right: render(e.at("dates", default: none)),
      subheading-left: render(e.at("school", default: none)),
      subheading-right: render(e.at("location", default: none)),
      body: bullets-body(e.at("bullets", default: none)),
    )
  }
}

#let projs = data.at("projects", default: ())
#if projs.len() > 0 {
  section[Projects]
  for p in projs {
    let url = p.at("url", default: "")
    entry(
      heading-left: render(p.at("name", default: none)),
      heading-right: if url != "" { monolink(url) } else { none },
      body: bullets-body(p.at("bullets", default: none)),
    )
  }
}

#let sk = data.at("skills", default: none)
#if sk != none {
  let items = sk.at("items", default: ())
  if items.len() > 0 {
    section[Skills]
    skills(
      items.map(it => (
        category: render(it.category),
        text: render(it.text),
      )),
      columns: sk.at("columns", default: 2),
    )
  }
}

#let aws = data.at("awards", default: ())
#if aws.len() > 0 {
  section[Awards]
  for a in aws {
    let issuer = a.at("issuer", default: "")
    let title = [*#render(a.at("title", default: none))*]
    let left = if issuer != "" {
      [#title — #render(issuer)]
    } else {
      title
    }
    compact-entry(left, right: render(a.at("date", default: none)))
  }
}
