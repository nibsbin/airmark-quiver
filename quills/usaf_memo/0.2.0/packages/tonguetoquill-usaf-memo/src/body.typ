// body.typ: Paragraph body rendering for USAF memorandum sections

#import "config.typ": *
#import "utils.typ": *
#import "primitives.typ": render-memo-table

#let get-paragraph-numbering-format(level) = {
  paragraph-config.numbering-formats.at(level, default: "i.")
}

#let calculate-indent-from-counts(level, level-counts) = {
  if level == 0 { return 0pt }
  let total-indent = 0pt
  for ancestor-level in range(level) {
    let ancestor-value = level-counts.at(str(ancestor-level), default: 1)
    let ancestor-format = get-paragraph-numbering-format(ancestor-level)
    let ancestor-number = numbering(ancestor-format, ancestor-value)
    total-indent += measure([#ancestor-number#"  "]).width
  }
  total-indent
}

#let calculate-daf-indent(level) = {
  if level <= 0 { return 0pt }
  daf-paragraph.nested-first-level-indent + (level - 1) * daf-paragraph.nested-step
}

#let reset-levels-from(level-counts, start, max-levels) = {
  for child in range(start, max-levels) {
    level-counts.insert(str(child), 1)
  }
  level-counts
}

#let format-par(body, level, level-counts, indent-fn, continuation: false) = {
  let indent-width = indent-fn(level, level-counts)
  let current-value = level-counts.at(str(level), default: 1)
  let number-text = numbering(get-paragraph-numbering-format(level), current-value)
  if continuation {
    [#h(indent-width + measure([#number-text#"  "]).width)#body]
  } else {
    [#h(indent-width)#number-text#"  "#body]
  }
}

#let render-body(content, memo-style: "usaf") = {
  let PAR_BUFFER = state("PAR_BUFFER")
  PAR_BUFFER.update(())
  let NEST_DOWN = counter("NEST_DOWN")
  NEST_DOWN.update(0)
  let NEST_UP = counter("NEST_UP")
  NEST_UP.update(0)
  let IS_HEADING = state("IS_HEADING")
  IS_HEADING.update(false)
  // Tracks whether the next paragraph is the first block in a list item.
  // Subsequent paragraphs within the same item are continuations (no new number).
  let ITEM_FIRST_PAR = state("ITEM_FIRST_PAR")
  ITEM_FIRST_PAR.update(false)

  let first_pass = {
    show par: p => context {
      let nest_level = NEST_DOWN.get().at(0) - NEST_UP.get().at(0)
      let is_heading = IS_HEADING.get()
      let is_first_par = ITEM_FIRST_PAR.get()
      let is_continuation = nest_level > 0 and not is_first_par

      PAR_BUFFER.update(pars => {
        pars.push((
          content: text([#p.body]),
          nest_level: nest_level,
          kind: if is_heading { "heading" } else if is_continuation { "continuation" } else { "par" },
        ))
        pars
      })

      if nest_level > 0 and is_first_par {
        ITEM_FIRST_PAR.update(false)
      }

      p
    }
    show table: t => context {
      PAR_BUFFER.update(pars => {
        pars.push((content: t, nest_level: -1, kind: "table"))
        pars
      })
      t
    }
    {
      show heading: h => {
        IS_HEADING.update(true)
        [#parbreak()#h.body#parbreak()]
        IS_HEADING.update(false)
      }

      // No context wrapper: state updates don't need it and context causes
      // layout convergence issues with many list items.
      let handle-list-item(it) = {
        NEST_DOWN.step()
        ITEM_FIRST_PAR.update(true)
        [#parbreak()#it.body#parbreak()]
        NEST_UP.step()
      }
      show enum.item: handle-list-item
      show list.item: handle-list-item

      {
        // `show par` won't collect wrappers without content outside the wrapper;
        // zero-width space ensures there's always something outside.
        show strong: it => [#it#sym.zws]
        show emph: it => [#it#sym.zws]
        show underline: it => [#it#sym.zws]
        show raw: it => [#it#sym.zws]
        [#content#parbreak()]
      }
    }
  }
  place(hide(first_pass))

  context {
    let heading_buffer = none
    // Tables are always kept; zero-width paragraphs (empty body string) are dropped.
    let items = PAR_BUFFER.get().filter(item =>
      item.kind == "table" or measure(item.content).width > 0pt
    )
    if items.len() == 0 { return }
    // AFH 33-337 §2: a single paragraph is not numbered.
    let par_count = items.filter(item => item.kind == "par").len()

    let max-levels = paragraph-config.numbering-formats.len()
    let level-counts = (:)
    for lvl in range(max-levels) {
      level-counts.insert(str(lvl), 1)
    }

    // Constant per call; hoisted to avoid recreating the closure every iteration.
    let indent-fn = if memo-style == "daf" {
      (level, _counts) => calculate-daf-indent(level)
    } else {
      (level, counts) => calculate-indent-from-counts(level, counts)
    }

    let i = 0
    let any_emitted = false
    for item in items {
      i += 1
      let kind = item.kind
      let item_content = item.content

      if kind == "heading" {
        heading_buffer = item_content
        continue
      }

      if heading_buffer != none {
        if kind == "table" {
          // Tables can't have inline text prepended; emit heading as a standalone line.
          blank-line()
          strong[#heading_buffer.]
          heading_buffer = none
        } else {
          item_content = [#strong[#heading_buffer.] #item_content]
          heading_buffer = none
        }
      }

      let nest_level = item.nest_level
      let level-key = str(nest_level)
      let final_par = {
        if kind == "table" {
          render-memo-table(item_content)
        } else if kind == "continuation" {
          if memo-style == "daf" and nest_level == 0 {
            item_content
          } else {
            format-par(item_content, nest_level, level-counts, indent-fn, continuation: true)
          }
        } else if memo-style == "daf" {
          if nest_level > 0 {
            let par = format-par(item_content, nest_level, level-counts, indent-fn)
            level-counts.insert(level-key, level-counts.at(level-key, default: 1) + 1)
            level-counts = reset-levels-from(level-counts, nest_level + 1, max-levels)
            par
          } else {
            // DAF top-level paragraphs are unnumbered with a first-line indent;
            // reset nested counters so children restart under each new top-level par.
            level-counts = reset-levels-from(level-counts, 0, max-levels)
            [#h(daf-paragraph.top-first-line-indent)#item_content]
          }
        } else if par_count > 1 {
          let par = format-par(item_content, nest_level, level-counts, indent-fn)
          level-counts.insert(level-key, level-counts.at(level-key) + 1)
          level-counts = reset-levels-from(level-counts, nest_level + 1, max-levels)
          par
        } else {
          item_content
        }
      }

      if any_emitted { blank-line() }
      any_emitted = true
      if i == items.len() {
        let available_width = page.width - spacing.margin * 2
        let line_height = {
          let cached = LINE_STRIDE.get()
          if cached != none { cached } else {
            let one-line = measure(par(spacing: 0pt)[x]).height
            measure(par(spacing: 0pt)[x#linebreak()x]).height - one-line
          }
        }
        let estimated_lines = calc.ceil(measure(final_par, width: available_width).height / line_height)
        // AFH 33-337 §11: keep short final paragraphs sticky so they don't orphan.
        if estimated_lines < 4 {
          block(sticky: true)[#final_par]
        } else {
          block(breakable: true)[#final_par]
        }
      } else {
        // block[] ensures `set block(above: spacing.line)` applies uniformly to
        // every paragraph, preventing the first/middle paragraphs from sitting
        // closer to their predecessor than the last paragraph does.
        block[#final_par]
      }
    }
  }
}
