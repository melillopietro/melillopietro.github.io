---
layout: post
title: "Installing Windows Server 2022 on Proxmox VE: Step-by-Step Guide"
date: 2025-07-29 09:00:00 +0200
categories: [Guides, Virtualization]
tags: [proxmox, windows-server, virtualization, hypervisor, virtio]
---

## Introduction

This guide explains how to install **Microsoft Windows Server 2022** on **Proxmox VE**. It assumes that Proxmox is already installed and accessible through the web interface.

The objective is to create a Windows Server virtual machine with the correct disk, network, and VirtIO driver configuration.

---

## Step 1: Download the Windows Server 2022 ISO

1. Visit the Microsoft Evaluation Center:

   [https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022)

2. Select the ISO format and complete the required form.
3. Download the ISO to your local machine.

---

## Step 2: Upload the ISO to Proxmox

1. Log in to the Proxmox web interface:

   ```text
   https://<your-proxmox-ip>:8006
   ```

2. Select **Datacenter → Node → local → ISO Images**.
3. Click **Upload** and select the Windows Server 2022 ISO.

---

## Step 3: Create a New Virtual Machine

1. Click **Create VM**.
2. Define the VM ID and name, for example `windows2022`.
3. In the **OS** tab:
   - choose **Use CD/DVD disc image file**;
   - select the Windows Server 2022 ISO;
   - set the guest OS type to **Microsoft Windows**;
   - select version **2022**.
4. In the **System** tab:
   - set BIOS to **OVMF (UEFI)**;
   - enable **QEMU Guest Agent**;
   - use machine type `q35`.
5. In the **Hard Disk** tab:
   - select **VirtIO** as bus/device;
   - allocate at least 60 GB of disk space.
6. In the **CPU** tab:
   - assign at least 4 cores, depending on the host resources.
7. In the **Memory** tab:
   - assign at least 4096 MB of RAM.
8. In the **Network** tab:
   - choose **VirtIO (paravirtualized)** as the network model.

---

## Step 4: Add VirtIO Drivers

Windows Server may not detect the virtual disk or network adapter without VirtIO drivers.

1. Download the VirtIO Windows driver ISO:

   [https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/)

2. Upload `virtio-win.iso` to the ISO Images section in Proxmox.
3. Open the VM **Hardware** tab.
4. Add a second CD/DVD drive and mount the VirtIO ISO.

---

## Step 5: Start the VM and Install Windows

![Windows Server installation on Proxmox](/assets/images/blogs/Proxmox/proxmoxMSWS22.png)

1. Start the VM and open the console.
2. Follow the Windows installation wizard.
3. Choose **Custom: Install Windows only**.
4. If no disk is displayed, click **Load driver**.
5. Browse the VirtIO driver ISO and select the appropriate Windows Server 2022 storage driver.
6. Once the disk appears, continue the installation.

After installation, install the additional VirtIO components, including:

- NetKVM driver for networking;
- Balloon driver for memory management;
- QEMU Guest Agent.

---

## Step 6: Post-Installation Tasks

After the first boot:

- run Windows Update;
- install the QEMU Guest Agent service;
- configure static IP addressing if required;
- activate the license where applicable;
- apply security baselines;
- configure backup and snapshot policies in Proxmox.

---

## Final Recommendations

For lab environments, snapshots are useful before major configuration changes. For production workloads, snapshots should not replace a proper backup strategy.

It is also recommended to monitor CPU, memory, and disk usage from the Proxmox interface and to adjust resources according to the workload.

---

## Conclusion

Windows Server 2022 can run effectively on Proxmox VE when the virtual hardware and drivers are configured correctly. This setup is suitable for Active Directory labs, application testing, training environments, and selected production workloads.
