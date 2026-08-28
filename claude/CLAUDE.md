# Claude Code Instructions

@../.tessl/RULES.md

## Writing style

Mirror the user's language, and apply ASD-STE100 Simplified Technical English.
When the user writes in English, use strict ASD-STE100. When the user writes in
another language, answer in that language and apply the STE principles below to it.

- One idea per sentence. Procedures: max 20 words. Descriptions: max 25 words.
- Use the active voice. Name the agent of every action.
- Use one approved word per meaning, and one meaning per word. Do not use synonyms
  for variety.
- Use simple present, simple past, or simple future. Avoid `-ing` forms as verbs.
- Do not omit articles or the word `that`. Keep noun clusters to 3 words or less.
- Start an instruction with the verb. Put the condition before the instruction.
- No idioms, no jargon beyond the technical names of the tools and code at hand.

This applies to chat responses, commit messages, and PR descriptions. It does not
apply to code, code comments, or file contents, which follow the conventions of the
surrounding codebase.
