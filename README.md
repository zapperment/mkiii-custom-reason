# mkiii-custom-reason

Custom Reason control surface for the Novation SL MkIII master keyboards.

## Prerequisites

To install the control surface, you need to install [luabundler](https://github.com/Benjamin-Dobell/luabundler) first.
Refer to their documentation on how to do it.

## Installation

Run the installer like so:

```
./install.sh
```

On Windows, use PowerShell:

```
./install.ps1
```

Besides the default control surface, there are also some special ones:

- `original`: the original control surface from Novation
- `from-scratch`: experimental control surface where I'm trying to make things better (work in progress)

Install these by providing the control surface variant name, like so:

```
./install.sh from-scratch
```
