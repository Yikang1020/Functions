#!/bin/bash

# Delete all files whose names begin with "._", including those in subdirectories.
find . -type f -name "._*" -exec rm -f {} +

echo "All files beginning with '._' have been removed."


