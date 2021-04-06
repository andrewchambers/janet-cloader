# janet-cloader

Load janet c extensions as if they were janet source code.

## Example

```
(use cloader)

# Load a c extension directly
(import ./example/hello)

# Call functions like a boss
(hello/myfun)
```

## How it works

It simply builds the cextension using jpm then loads it transparently.