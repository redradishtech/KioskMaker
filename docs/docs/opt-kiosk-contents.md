---
hide:
  - navigation
---

# `/opt/kiosk` Contents

Files in /opt/kiosk/ were used to 'kioskify' AlmaLinux, i.e. make it automatically boot in
graphical mode to a locked-down session displaying a website. Its main component is the
/opt/kiosk/kioskify script, which does all the work, including copying `/opt/kiosk/template/`
files to /. 

/opt/kiosk/ is not needed once the kiosk is up and running, and can be removed, but it is
harmless and is a primitive form of documentation.

/opt/kiosk contains:

Script that turns an fresh AlmaLinux 'minimal' install into a KioskMaker.

```bash
├── kioskify
```
`/opt/kiosk/template/` contains:

Hardcoded Chrome installed by kioskify. See README
```
├── tmp
│   └── chrome
│       ├── fetch-chrome
│       ├── google-chrome-stable_current_x86_64.rpm
│       ├── install
│       ├── linux_signing_key.pub
│       ├── README
│       └── update-chrome

```

Grub boot loader entries. Unlike most files in `/opt/kiosk/template/` these can't just be copied across, but contain a
`${KERNEL_EXPECTED_VERSION}` variable that must be sustituted for the real kernel version in the final
`/boot/loader/entries/` file. This substitution is done by `/opt/kiosk/kioskify`.

```
    ├── boot
    │   └── loader
    │       └── entries
    │           ├── README.KIOSK
    │           ├── ro.conf.template
    │           └── rw.conf.template
```

`/etc/kiosk/` contains kiosk-release and packages-on-install informational files added by kioskify. It is not really used.
```
├── etc
│   ├── kiosk
│   │   ├── kiosk-account-settings -> ../../var/lib/AccountsService/users/kiosk
│   │   └── kiosk-release
```
Set the kiosk internal hostname (not used anywhere)
```
├── etc
│   ├── hostname
```
Tell GDM to automatically log in as `kiosk`
```
├── etc
│   ├── gdm
│   │   └── custom.conf
```

Sample NetworkManager network configurations
```
    │   ├── NetworkManager
    │   │   └── system-connections
    │   │       ├── enp0s3.nmconnection
    │   │       ├── eth0.nmconnection
    │   │       ├── eth1.nmconnection
    │   │       ├── eth2.nmconnection
    │   │       ├── eth3.nmconnection
    │   │       └── eth4.nmconnection
```

Extra CAs, activated (when present) by kioskify#update_ca
```
    ├── etc
    │   ├── pki
    │   │   └── ca-trust
    │   │       └── source
    │   │           └── anchors
    │   │               └── *.pem
```


When the filesystem is ro, rwtab.d/* indicates which directories should get a tempfs mirror. E.g. 'kiosk-home' makes /home/kiosk/ into an in-memory copy of /home/kiosk/ on disk.  Chrome can then write changes all it likes, but they will be lost on next reboot
```
    │   ├── rwtab.d
    │   │   ├── dnf
    │   │   ├── kiosk-home
    │   │   ├── rsyslog
    │   │   └── tpm
```


Reconfigures SSH (vs. how the installer left it) to allow only root login via the public key in /root/.ssh/authorized_keys
```
├── etc
│   ├── ssh
│   │   └── sshd_config.d
│   │       └── 01-permitrootlogin.conf

```


kiosk-updater.service runs /usr/local/bin/kiosk-updater on startup, before gdm.service, toggling ro/rw status. See /usr/local/bin/kiosk-updater for docs. fwupd-refresh.timer is disabled (we don't want firmware update checks).
```
├── etc
│   └── systemd
│       └── system
│           ├── fwupd-refresh.timer -> /dev/null
│           ├── gdm.service.d
│           │   └── after_kiosk-updater.conf
│           ├── kiosk-updater.service
│           └── multi-user.target.wants
│               └── kiosk-updater.service -> ../kiosk-updater.service
```


/home/kiosk is the homedir for our auto-logged-in `kiosk` user.
```
    ├── home
    │   └── kiosk
```

~kiosk/.config/autostart symlinks fire in rw mode only, and launch the docs (chrome-kiosk) and `url.txt` in a text editor.
``` 
    │       ├── .config
    │       │   ├── autostart
    │       │   │   ├── chrome-kiosk.desktop -> /usr/share/applications/chrome-kiosk.desktop
    │       │   │   └── edit-url.desktop -> /usr/share/applications/edit-url.desktop
```


`~kiosk/.config/dconf/user` contains all the Gnome Shell configuration, notably those set by kioskify#setbackground, plus the 'Favourites' choices made manually. It can be dumped to text to see what's going on, with `XDG_CONFIG_HOME=/home/kiosk/.config dconf dump /`. The `02_kioskif-vm` script modifies `dconf/user` to set the background, before it is copied into the VM.
```
    │       │   ├── dconf
    │       │   │   └── user
```

In amongst the mass of Gnome config, this file prevents the setup wizard loading.
```
    │       │   ├── gnome-initial-setup-done
```

~kiosk/.local/bin/gnome-kiosk-script is invoked in ro mode. See the README.
```
    │       ├── .local
    │       │   ├── bin
    │       │   │   ├── gnome-kiosk-script -> /usr/local/bin/gnome-kiosk-script
    │       │   │   └── README
```

kioskmaker.png is set as the Gnome Shell desktop background (in `~/.config/dconf/user`). It is derived from kioskmaker.xcf Gimp file, included for reference. 1800x1440 is a good choice of dimensions.
```
    │       ├── .local
    │       │   ├── share
    │       │   │   ├── backgrounds
    │       │   │   │   ├── kioskmaker.xcf
    │       │   │   │   └── kioskmaker.png
```

Contains the URL that /usr/local/bin/chrome-kiosk defaults to.
```
    │       └── url.txt
```

Edit authorized_keys to set the SSH key you want to use to log in to the kiosk

```
    ├── root
    │   └── .ssh
    │       └── authorized_keys
```

Our scripts. See the header in each one for detailed documentation.
```
    ├── usr
    │   ├── local
    │   │   └── bin
```

Launches Chrome in kiosk mode pointing to `url.txt`
```
    │   │       ├── chrome-kiosk
```

Bash utility library
```
    │   │       ├── cmdline.sh
```

Defines what happens in kiosk mode. Symlinked to ~kiosk/.local/bin/gnome-kiosk-script. See inline comments.
```
    │   │       ├── gnome-kiosk-script
```

Helper script, used by kiosk-updater, that displays or changes the Gnome 'session'.
```
    │   │       ├── kiosksession
```

Helper script, used by kiosk-updater, that makes the OS read-write or read-only.
```
    │   │       └── kioskwritable
```

kiosk-updater, invoked by kiosk-updater.service, is our workhorse that detects the 'kioskmode' kernel param on boot, and makes the OS read-only or read-write in response.

```
    │   │       ├── kiosk-updater
```


Define the 'applications' in the Gnome Shell favourites bar and symlinked to ~kiosk/.config/autostart
```
    │   └── share
    │       └── applications
    │           ├── chrome-kiosk.desktop
    │           ├── chrome-kiosk-documentation.desktop
    │           └── edit-url.desktop
```


Kiosk documentation, served in-kiosk at `file:///var/www/kiosk/docs/index.html`
```
    └── var
        └── www
            └── kiosk
                └── docs
```
