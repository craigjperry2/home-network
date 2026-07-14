# Neovim Tree-sitter keybindings

These text objects work in visual and operator-pending mode. Prefix one with an
operator such as `d`, `c`, or `y`; for example, `dif` deletes inside a function
and `daa` deletes around a parameter. Support varies by language parser.

| Inside | Around | Object |
| --- | --- | --- |
| `ia` | `aa` | Parameter |
| `if` | `af` | Function |
| `ic` | `ac` | Class |
| `ib` | `ab` | Block |
| `ii` | `ai` | Conditional |
| `il` | `al` | Loop |
| `i/` | `a/` | Comment |
| `iq` | `aq` | Function call |
| `iA` | `aA` | Assignment |
| `ir` | `ar` | Return |
| `ix` | `ax` | Regular expression |

Additional one-sided objects:

- `iH`: assignment left-hand side
- `iL`: assignment right-hand side
- `in`: number
- `aS`: statement

Mappings select the next matching object when the cursor is not already inside
one. The complete language support matrix is in the
[nvim-treesitter-textobjects documentation](https://github.com/nvim-treesitter/nvim-treesitter-textobjects/blob/main/BUILTIN_TEXTOBJECTS.md).
