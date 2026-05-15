---
# Essential 
#===========
QUILL: usaf_memo@0.2.0
letterhead_title: DEPARTMENT OF THE AIR FORCE
letterhead_caption:
  - HEADQUARTERS YOUR UNIT NAME
date: 2504-10-05
memo_for:
  - ORG/SYMBOL  # Organization/office symbol in UPPERCASE
  # - DISTRIBUTION  # For numerous recipients, use 'DISTRIBUTION' and list them below
memo_from:
  - ORG/SYMBOL
  - Organization Name 
  - 123 Street Ave 
  - City ST 12345-6789
subject: Subject of the Memorandum 

# Optional
#===========
references:
  - AFM 33-326, 31 July 2019, Preparing Official Communications
cc:
  - ORG/SYMBOL
distribution:
  - 1st ORG/SYMBOL
attachments:
  - Attachment description, YYYY MMM DD
signature_block:
  - FIRST M. LAST, Rank, USAF
  - Duty Title
tag_line: Aim High
classification: UNCLASSIFIED
# cui_controlled_by: SAF/AA          # Required when classification is CUI (DoDM 5200.48)
# cui_category: Privacy/MED          # CUI category from the DoD CUI Registry
# cui_poc: Capt J. Smith, DSN 555-1234, john.smith@us.af.mil
---

The `usaf_memo` Quill package takes care of all 33-337 formatting details. Focus on the content.

**Numbering** Top-level paragraphs like this one are automatically numbered. NEVER manually number your paragraphs.

- Use bullets for hierarchical paragraph nesting. These are automatically numbered or lettered as well.
  - Up to five levels of paragraphs are supported

Do not include a complimentary close (e.g. "Respectfully,") in official memorandums.

---
KIND: indorsement
for: ORG/SYMBOL
format: standard
from: ORG/SYMBOL
action: undecided
signature_block:
  - FIRST M. LAST, Rank, USAF
  - Duty Title
---

This body and the metdata above are an indorsement card. Multiple or no indorsements leaves can be used.
