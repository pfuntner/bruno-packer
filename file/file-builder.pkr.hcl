variables {
  line = "default line from builder file"
  xline = "bogus variable just so we can pass in a slightly different variable"
}

source "file" "file-builder" {
  content = "Hello, world\nLine: ${ var.line }\n"
  target = "file-builder.txt"
}

build {
  sources = ["source.file.file-builder"]
}
