# #!/bin/bash
# a script to print the battery percent on macos
if pmset -g batt | head -n1 | grep -q AC; then
    ac=1
else
    ac=0
fi

percent=$(pmset -g batt | tail -n1 | grep -o [0-9]*%)
echo $percent
