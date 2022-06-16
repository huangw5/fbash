# Usage

Source `fbash.h` in your bash scripts and use `DEFINE_` to define your flags:

```
#!/bin/bash

source fbash.sh

DEFINE_string name --required "" "Your name"
DEFINE_int age 1 "Your age"

fbash::init "$@"

echo "Hello, $FLAGS_name! Your age is $FLAGS_age"
echo "Non-flag arguments: ${FBASH_ARGV[@]}"
```

Save this as `example.sh` and run

```
$ ./example.sh --help
Flags from example.sh
  --help (Print help information) type: string default: ""
  --age (Your age) type: int default: 1
  --name (Your name) type: string default: ""
```

```
$ ./example
Required flag not set: --name
```

```
$ ./example --name World
Hello, Wolrd! Your age is 1
Non-flag arguments:
```

