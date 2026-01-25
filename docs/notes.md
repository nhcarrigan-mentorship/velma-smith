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

Following the System V ABI, which is required on Linux and other Unices for system calls,
invoking a system call requires us to put the system call code in the register rax,
the parameters to the syscall (up to 6) in the registers rdi, rsi, rdx, rcx, r8, r9, and additional parameters,
if any, on the stack (which will not happen in this program so we can forget about it).
We then use the instruction syscall and check rax for the return value, 0 usually meaning: no error.

[source](https://gaultier.github.io/blog/x11_x64.html)

![a table representing the various registers for arguments for syscalls](./img/syscallargs.png)

[source](https://youtu.be/BWRR3Hecjao?si=jU0myc7HmExQ24Xj)

[a good searchable table that leads back to the documentation](https://filippo.io/linux-syscall-table/)

## Instructions and Other Documentation

[https://web.stanford.edu/class/cs107/guide/x86-64.html](https://web.stanford.edu/class/cs107/guide/x86-64.html)
