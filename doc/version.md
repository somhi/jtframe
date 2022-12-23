# Version History

Version encoding consists of the letter _v_ followed by a three-digit code:

1. Versions that break compatibility with previous versions and will require changes in cores. For instance, adding a new input port to the game module without gating it with a JTFRAME_ macro
2. New functionality that does not break compatibility
3. Patches

New versions are elaborated in a separate branch, typically _wip_, and then merged into the master branch and assign a number and a git tag. When the branch is ready, use `jtmerge` to merge it into master and advance the version number.

Version coding started almost three years after the first JTFRAME commit with version 1.0.0, used in the [JTKARNOV](https://github.com/jotego/jtcop) beta.
