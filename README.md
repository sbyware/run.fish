# run.fish

Easy script management using fish shell

## Description

`run.fish` is a powerful script management tool that streamlines the execution and organization of scripts in a designated directory. The main command is `run`, and additional functionalities are accessed using dot-notation, such as `run.[cmd]`. Here's a breakdown of the key functionalities:

## Basic Usage

```fish
run <script_name> [...args]
```
- **Description:** Runs the corresponding script in the specified directory.
- **Example:** `run test_script arg1 arg2`

## Additional Commands

### `run.rm`

```fish
run.rm <script_name>
```
- **Description:** Removes a script from the specified directory.
- **Example:** `run.rm old_script`

### `run.ln`
```fish
run.ln <script_path> [<script_alias>]
```
- **Description:** Creates a symbolic link to an existing script in the directory.
- **Example:** `run.ln /path/to/script.sh my_script`

### `run.history`
```fish
run.history
```
- **Description:** Lists the history of scripts executed with `run`.
- **Example:** `run.history`

### `run.log`
```fish
run.log
```
- **Description:** Displays the run log file.
- **Example:** `run.log`

### `run.ls`
```fish
run.ls
```
- **Description:** Lists all scripts in the specified directory.
- **Example:** `run.ls`

### `run.edit`
```fish
run.edit <script_name>
```
- **Description:** Opens the specified script in the default editor.
- **Example:** `run.edit edit_script`

### `run.new`
```fish
run.new <script_name> <script_type>
```
- **Description:** Creates a new script in the directory with the specified type.
- **Example:** `run.new new_script bash`

## Examples
- Create a new Node.js script: `run.new my_node_script node`
- Run a script: `run existing_script arg1 arg2`
- List all scripts: `run.ls`
- Open a script for editing: `run.edit edit_script`

For detailed information and examples, use `run --help` or refer to the provided examples in the help message.