#!/bin/bash
set -e

if [ -z "$1" ]; then
        echo "usage: $0 <VMID>"
        exit 1
fi

if ! [[ $1 =~ ^[0-9]+$ ]]; then
        echo "VMID is not an integer"
        exit 1
fi

VMID=$1

IMAGES_PATH="/var/lib/vz/images"

config=`qm config ${VMID}`

virtio=`echo $config | grep 'virtio[0-9]:' || true`

if [[ $virtio ]]; then
        echo "Virtio drive is still attached to VM. Switch to scsi"
        exit 1
fi

controller=`echo $config | grep 'scsihw: virtio-scsi-pci' || true`

if [[ -z $controller ]]; then
        echo "Controller not set to virtio-scsi-pci"
        exit 1
fi

scsi=`echo $config | grep 'scsi[0-9]:' || true`

if [[ -z $scsi ]]; then
        echo "No scsi disk found."
        exit 1
fi

discard=`echo $config | grep 'discard=on' || true`

if [[ -z $discard ]]; then
        echo "Discard not enabled."
        exit 1
fi

echo "Please trim the server now and/or install windows drivers if necessary."

read -p "Press enter to continue"

echo "Please enter the openstack credentials of the user (NOT ADMIN)"

source openrc-user.sh

read -p "Press enter to start the upload"

qcow_file="/var/lib/vz/images/${VMID}/vm-${VMID}-disk-1.qcow2"
qcow_temp="/root/${VMID}-disk-1-compressed.qcow2"

if [ ! -f $qcow_file ]; then
        echo "Error - VM Image does not exist"
        exit 1
fi

status=`qm status ${VMID}`
isStopped=`echo $status | grep 'status: stopped' || true`

if [[ -z $isStopped ]]; then
        echo "VM Not stopped"
        exit 1
fi

echo "Compressing Image"
qemu-img convert -O qcow2 -c $qcow_file $qcow_temp

echo "Uploading image to OpenStack"
openstack image create --disk-format qcow2 --container-format bare --property architecture=x86_64 --property hw_disk_bus=scsi --property hw_scsi_model=virtio-scsi "Import VM ${VMID}" < $qcow_temp

echo "Removing temporary image file"
rm $qcow_temp

echo "Successfully uploaded image. - Upload completed."

echo "Now rebuild the VM with the image and change the IP addresses if necessary."
