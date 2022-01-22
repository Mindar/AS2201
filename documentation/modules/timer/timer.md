# Timer
Variable bit-width timer with several counting modes. Can count up, down or up and down.

## Usage
- `count_mode` defines which mode is used (reset at end or flip direction)
- `count_dir` defines in which direction the counter is counting, if `count_mode` is 1, this is ignored
- `pulse` increments or decrements the timer at every rising edge