from std/os import commandLineParams
import std/strformat

when isMainModule:
  var args = commandLineParams()
  if args.len() != 1:
    writeLine(stderr, "Expected one file path!");
    quit(1)

  var file = readFile(args[0])
  var ch_ptr = 0
  var mem: array[0..30_000, uint8]
  var p = 0
  var loop_starts: seq[int]

  while ch_ptr < file.len():
    case file[ch_ptr]
    of '>': p += 1
    of '<':
      if p > 0: p -= 1
    of '+':
      if mem[p] < 254: mem[p] += 1
      else: mem[p] = 0
    of '-':
      if mem[p] > 0: mem[p] -= 1
      else: mem[p] = 255
    of '.': discard writeBytes(stdout, mem, p, 1)
    of ',': discard readBytes(stdin, mem, p, 1)
    of '[':
      loop_starts.add(ch_ptr)
      if mem[p] == 0:
        var loop_depth = 1
        while ch_ptr < file.len() and loop_depth > 0:
          ch_ptr += 1
          if ch_ptr < file.len():
            case file[ch_ptr]
            of '[': loop_depth += 1
            of ']': loop_depth -= 1
            else: discard

        if file[ch_ptr] != ']':
          ch_ptr = loop_starts.pop()
          writeLine(stderr, &"Unclosed loop at {ch_ptr} index!");
          quit(1)
        ch_ptr -= 1
    of ']':
      if loop_starts.len() == 0:
        writeLine(stderr, &"No matching loop at {ch_ptr} index!");
        quit(1)
      var loop_start = loop_starts.pop();
      if mem[p] != 0:
        ch_ptr = loop_start - 1
    else: discard
    
    ch_ptr += 1
    p = clamp(p, 0, 30_000 - 1)

