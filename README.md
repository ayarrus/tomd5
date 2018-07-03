# tomd5

As a challenge to myself I wanted to implement the [MD5 hashing algorithm](https://en.wikipedia.org/wiki/MD5) in batch.
The project is not finished and currently is not under active development.

## The code

### What was done

For the initial binary integer part of the sines of integers, witch would be something similar to:

```
for i from 0 to 63
    K[i] := floor(232 × abs(sin(i + 1)))
end for
```

I chose to precomputed and set the table.

This could have been done in batch, quite easelly actually, as there are many brave developers who tested their nervs and implemented all the necesary functions such as [sin(x)](https://www.dostips.com/forum/viewtopic.php?t=4896&start=15) and  [cos(x)](http://www.robvanderwoude.com/cosine.php) in batch.

Several helper functions where needed and implemented:
- a function that does unsigned right shift `rfrs`
- as batch currently works with 32 bits signed integers only, a function to cast a value to a signed C2 byte was needed `byte_cast`

Reading the content of a file as hex is done using [a trick](https://stackoverflow.com/questions/4648118/converting-a-binary-file-to-hex-representation-using-batch-file/4648636#4648636) with the [Windows FC tool](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/fc). Although this is not the chosen idiom of pure batch it is reasonably close enough.

Please remember, there are no arrays in batch. Arrays are mimicked using variables with array names. Example only the following variable declarations are fine `vector[0]` and `vectori[7]`. Think of them as declaring `vector_1` and `vector_7`.

### TODO
- the limitations regarding code blocks in parentheses `( )` have stopped me. I see the need for a double [EnableDelayedExpansion](https://stackoverflow.com/questions/6679907/how-do-setlocal-and-enabledelayedexpansion-work). This may be mitigated using batch calls to other functions where the operation occurs. Must experiment to verify.

- at this point the code sets up the initial variables needed and reads the file as bytes to the `message` variable.

## Resources

- [DOS batch file tips](http://www.chebucto.ns.ca/~ak621/DOS/Bat-Tips.html)

- [Arrays, linked lists and other data structures in cmd.exe (batch) script](http://stackoverflow.com/questions/10166386/arrays-linked-lists-and-other-data-structures-in-cmd-exe-batch-script)

- [DOS Batch - Functions](http://www.dostips.com/DtCodeCmdLib.php)

- [Stream-IO (reading a file byte by byte) in DOS batch?](http://www.dostips.com/forum/viewtopic.php?f=3&t=3089&p=14361#p14361)

- [pure batch hexDump](http://www.dostips.com/forum/viewtopic.php?t=5324)

- [converting a binary file to HEX representation using batch file](https://stackoverflow.com/questions/4648118/converting-a-binary-file-to-hex-representation-using-batch-file/4648636#4648636)

- [Batch "macros" with arguments](http://www.dostips.com/forum/viewtopic.php?f=3&t=1827)

- [CharLib :chr, :asc, :asciiMap](http://www.dostips.com/forum/viewtopic.php?p=6953#p6953)

- [Batch character escaping]( http://stackoverflow.com/questions/6828751/batch-character-escaping)

- [Decimal to hex conversion bat](https://www.dostips.com/forum/viewtopic.php?t=2261)

- a highly recommended [IDE for developing batch scripts](https://jpsoft.com/), haven't tried it but looks promising

