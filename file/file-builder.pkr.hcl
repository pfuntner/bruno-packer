variables {
  line = "default line from builder file"
  xline = "bogus variable just so we can pass in a slightly different variable"
  conditional = true
}

source "file" "file-builder" {
  content = "Hello, world\nLine: ${ var.line }\n${var.conditional ? "true!" : "false!"}\n"
  target = "file-builder.txt"
}

build {
  sources = ["source.file.file-builder"]
}
