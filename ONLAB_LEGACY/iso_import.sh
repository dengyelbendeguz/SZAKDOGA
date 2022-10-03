#! /bin/bash



linux1() {

echo "Is the .iso mounted in VMRC? If yes, press ENTER"
read

mkdir /home/linux1/mount
mkdir /home/linux1/scripts
mount /dev/sr0 /home/linux1/mount
cp -r /home/linux1/mount /home/linux1/scripts
umount -f /dev/sr0

echo "==========================================="
echo "To run .sh file use the following commands:"
echo "chmod +x filename.sh"
echo "sed -i -e 's/\r$//' filename.sh"
echo "==========================================="
}

linux2() {

echo "Is the .iso mounted in VMRC? If yes, press ENTER"
read

mkdir /home/linux2/mount
mkdir /home/linux2/scripts
mount /dev/sr0 /home/linux2/mount
cp -r /home/linux2/mount /home/linux2/scripts
umount -f /dev/sr0

echo "==========================================="
echo "To run .sh file use the following commands:"
echo "chmod +x filename.sh"
echo "sed -i -e 's/\r$//' filename.sh"
echo "==========================================="
}

case $1 in
	"linux1")
		shift
		linux1
		exit 0
		;;
	"linux2")
		shift
		linux2
		exit 0
		;;	
    *)
        echo >&2 "$UTIL: unknown command \"$1\" (possible arguments: linux1, linux2)"
        exit 1
        ;;
esac