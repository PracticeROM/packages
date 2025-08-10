# About
Practicerom development packages for Debian-based systems and Arch Linux.

# Packages
<details>
<summary>
List of upstream repositories and corresponding binary packages
</summary>

-   https://github.com/glankk/n64
    -   `mips64-ultra-elf-binutils`
    -   `mips64-ultra-elf-gcc`
    -   `mips64-ultra-elf-gcc-libs`
    -   `mips64-ultra-elf-newlib`
    -   `mips64-ultra-elf-gdb`
    -   `mips64-ultra-elf-practicerom-libs`
    -   `practicerom-tools`

-   https://github.com/PracticeROM/wii-toolchain
    -   `powerpc-eabi-binutils`
    -   `powerpc-eabi-gcc`
    -   `powerpc-eabi-gcc-libs`
    -   `powerpc-eabi-newlib`
    -   `powerpc-eabi-gdb`

-   https://github.com/PracticeROM/gzinject
    -   `gzinject`

-   https://github.com/PracticeROM/packages
    -   `practicerom-dev` (Debian)

-   https://github.com/glankk/libdmg-hfsplus
    -   `libdmg-hfsplus`
</details>

# Installation
*Piping downloaded scripts directly into a root shell is dangerous. To be safe,
download and inspect installation scripts from the scripts directory and then
run them manually.*

## Debian (Ubuntu, WSL)
1.  Run one of the following to install the package repository for your
    architecture (requires `curl`):
    -   amd64
        ```
        sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/PracticeROM/packages/HEAD/scripts/install-debian_amd64.sh)"
        ```
    -   arm64
        ```
        sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/PracticeROM/packages/HEAD/scripts/install-debian_arm64.sh)"
        ```
2.  Install individual packages by running e.g.
    `sudo apt install mips64-ultra-elf-gcc`, or install all practicerom
    development packages with the `practicerom-dev` metapackge:
    `sudo apt install practicerom-dev`.

## Arch Linux
1.  Run the following to install the package repository (requires `curl`):
    ```
    sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/PracticeROM/packages/HEAD/scripts/install-archlinux.sh)"
    ```

2.  Install individual packages with e.g. `sudo pacman -S mips64-ultra-elf-gcc`,
    or select practicerom development packages from the `practicerom-dev`
    group: `sudo pacman -S practicerom-dev`.
