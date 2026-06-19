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
    -   `practicerom-repository`
    -   `practicerom-dev` (Debian)

-   https://github.com/glankk/libdmg-hfsplus
    -   `libdmg-hfsplus`

-   https://github.com/indygreg/apple-platform-rs
    -   `apple-codesign`
</details>

# Installation
## Debian (Ubuntu, WSL)
1.  Download and install the practicerom repository package for your
    architecture (requires `curl` if done with the scripts below):
    -   amd64 ([package link](https://practicerom.com/public/debian/dists/stable/practicerom-repository_latest_amd64.deb)):
        ```
        curl -O https://practicerom.com/public/debian/dists/stable/practicerom-repository_latest_amd64.deb
        sudo dpkg -i practicerom-repository_latest_amd64.deb
        sudo apt update
        ```
    -   arm64 ([package link](https://practicerom.com/public/debian/dists/stable/practicerom-repository_latest_arm64.deb)):
        ```
        curl -O https://practicerom.com/public/debian/dists/stable/practicerom-repository_latest_arm64.deb
        sudo dpkg -i practicerom-repository_latest_arm64.deb
        sudo apt update
        ```
2.  Install individual packages by running e.g.
    `sudo apt install mips64-ultra-elf-gcc`, or install all practicerom
    development packages with the `practicerom-dev` metapackge:
    `sudo apt install practicerom-dev`.

## Arch Linux
1.  Run the following to install the package repository:
    ```
    sudo pacman -U https://practicerom.com/public/packages/archlinux/practicerom-repository-latest-x86_64.pkg
    sudo pacman -Sy
    ```

2.  Install individual packages with e.g. `sudo pacman -S mips64-ultra-elf-gcc`,
    or select practicerom development packages from the `practicerom-dev`
    group: `sudo pacman -S practicerom-dev`.
