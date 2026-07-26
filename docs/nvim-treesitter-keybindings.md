# Neovim Tree-sitter keybindings

These text objects work in visual and operator-pending mode. Prefix one with an
operator such as `d`, `c`, or `y`; for example, `dif` deletes inside a function
and `dap` deletes around a parameter. They use the same suffixes as the VS Code
Text Objects extension.

| Inside | Around | Object |
| --- | --- | --- |
| `if` | `af` | Function |
| `il` | `al` | Loop |
| `io` | `ao` | Object |
| `ia` | `aa` | Array |
| `im` | `am` | Function call |
| `ik` | `ak` | Class |
| `ic` | `ac` | Comment |
| `ip` | `ap` | Parameter |
| `ii` | `ai` | Conditional |
| `is` | `as` | String |
| `it` | `at` | Type |
| `in` | `an` | Tree-sitter node |
| `iv` | `av` | Variable |
| `ir` | `ar` | Assignment right-hand side |
| `ih` | `ah` | Assignment left-hand side |

Support varies by language parser. Functions, loops, calls, classes, comments,
parameters, conditionals, and assignments use `nvim-treesitter-textobjects`
queries and can look ahead to the next match. The remaining objects select the
matching Tree-sitter node containing the cursor.
