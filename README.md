# runscript.fish

Simple script management using fish shell.

## Installation

```fish
fisher install sby051/runscript.fish
```

## Usage

```fish
runscript <script-name>
```

```fish
newscript <script-name> <script-executor (i.e. bash, node, python, bun etc)>
```

```fish
editscript <script-name>
```

```fish
delscript <script-name>
```

'runscript' will run the script with the given name (regardless of extension, script names are unique regardless of extension!). 'newscript' will create a new script with the given name and executor. 'editscript' will open the script with the given name in the default editor. 'delscript' will delete the script with the given name.

```fish
runscript -h
```

```fish
runscript -v
```

'runscript -h' will print the help message. 'runscript -v' will print the version.

## Example

```fish
runscript hello
```