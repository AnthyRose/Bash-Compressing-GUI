#!/bin/bash
# $1 = File_Selection $2 = Saving_Location $3 = Archive_Name $4 = Compression_Method
Compress_Files(){
    case $4 in
        "7z")
            7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on "$2/$3.7z" $1
            ;;
        "tar.xz")
            tar -cJf -X FILE --best "$2/$3.tar.xz" $1
            ;;
        "zip")
            zip -9 -r "$2/$3.zip" $1
            ;;
        "rar")
            rar a -m5 -rr "$2/$3.rar" $1
            ;;
        "tar")
            tar -cf "$2/$3.tar" $1
            ;;
        "tar.gz")
            GZIP=-9 tar -czf "$2/$3.tar.gz" $1
            ;;
        "tar.bz2")
            tar cjvf "$2/$3.tar.bz2" $1
            ;;
    esac
    zenity --info --text="Compression complete. Archive saved at $2/$3.$4"
}

Compression_Options=("7z" "tar.xz" "zip" "rar" "tar" "tar.gz" "tar.bz2")

# Check what package manager is installed. This may not work on all systems depending on package
if [ -x "$(command -v apt-get)" ]; then
    sudo apt-get install zenity p7zip-full rar zip tar xz-utils -y
elif [ -x "$(command -v dnf)" ]; then
    sudo dnf install zenity p7zip rar zip tar xz -y
elif [ -x "$(command -v pacman)" ]; then
    sudo pacman -S zenity p7zip rar zip tar xz -y
elif [ -x "$(command -v zypper)" ]; then
    sudo zypper install zenity p7zip rar zip tar xz -y
elif [ -x "$(command -v portage)" ]; then
    sudo zypper install zenity p7zip rar zip tar xz -y
else
    echo "No package manager found. Please install the required packages manually."
fi
File_Selection=$(zenity --file-selection --multiple --separator=" " --title="Select files or folders to compress")
Saving_Location=$(zenity --file-selection --directory --title="Select a location to save the archive")
Archive_Name=$(zenity --entry --title="Enter a name for the archive")
# Remove the . and any text after it from the Archive_Name if it is present.
Archive_Name=${Archive_Name%%.*}
# Notice before selecting compression method.
zenity --text-info --title="Information" --width=400 --height=300 --ok-label="Close" --text="This prompt is here to help inform the user which method is the best for their needs.\n\n7z: Most effective at reducing file sizes, is less efficient with indiviudal files but better with groups of files. It is also applicable to all operating systems and is generic.\ntar.xz: Very slightly larger file size than .7z. It is better at compression with individual files over multiple and is targeted for Linux systems.\n\nzip: Most compatible. Very minimal compression and sometimes associated with Windows usage.\n\nrar: Good compression ratio and is intended for general use. However, it is not as effective as .7z and is not open.\n\ntar: No compression, is intended for Linux systems. Is the most efficient option for compression and decompression.\n\ntar.gz: Moderate compression ratio. Is a good balance between speed and compression ratio. Is targeted towards Linux systems.\n\ntar.bz2: Better compression ratio than tar.gz but less fast. Aimed at Linux."
Compression_Method=$(zenity --list --title="Select a compression method." --column="Options" "${Compression_Options[@]}")

#Selections are done. Now we make the file.
Compress_Files $File_Selection $Saving_Location $Archive_Name $Compression_Method