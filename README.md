## SemVer

https://semver.org/

Semantic versioning should be followed for all releases. The scripts contained
in this repo either generate semver values or assume semver values for other
tasks.

## Package Versioning

https://fedoraproject.org/wiki/Packaging:Versioning

Package versions should follow semver plus the addition of a RPM release
number. Spec files used to build RPMs contain both Version and Release fields.
Version should always follow semver. Release is purely used for RPMs and
nowhere else.

> Use a Release: tag starting with 1 (never 0). Append the Dist tag. Increment
> the release (by 1) for each update you make. Reset to 1 whenever you change
> Version:.

Metadata in the semver specification can also be included in RPM versions and
can be copied to the Release field following a valid release number.

## Style guide

Google bash style guide covers most things:
https://google.github.io/styleguide/shell.xml .
