# x86-64 ASM notes

```as
text db "Hello, World!",10
```

this is a name assigned to the address in memory that this data is located in

```as
text
```

define bytes

```as
db
```

the below is the bytes of data we are defining. The 10 is a newline character `\n`

```as
"Hello, World!",10
```

## available registers

![a table of registers available in x86-64 asm](./img/registers1.png)

[source](https://youtu.be/BWRR3Hecjao?si=jU0myc7HmExQ24Xj)

## syscalls

![a table representing the various registers for arguments for syscalls](./img/syscallargs.png)

[source](https://youtu.be/BWRR3Hecjao?si=jU0myc7HmExQ24Xj)

[a good searchable table that leads back to the documentation](https://filippo.io/linux-syscall-table/)

## Instructions and Other Documentation

[https://web.stanford.edu/class/cs107/guide/x86-64.html](https://web.stanford.edu/class/cs107/guide/x86-64.html)
