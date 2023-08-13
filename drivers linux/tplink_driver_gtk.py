#!/usr/bin/env python3
import os
import subprocess
import gi

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk

class TPLinkDriverInstaller(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="Instalar Driver TP-Link AC-1300")
        self.set_default_size(400, 200)

        self.clone_button = Gtk.Button(label="Clonar Repositorio")
        self.clone_button.connect("clicked", self.on_clone_button_clicked)

        self.install_button = Gtk.Button(label="Instalar Controlador")
        self.install_button.connect("clicked", self.on_install_button_clicked)

        self.reinstall_button = Gtk.Button(label="Reinstalar para nuevo kernel")
        self.reinstall_button.connect("clicked", self.on_reinstall_button_clicked)

        self.progress_bar = Gtk.ProgressBar()
        self.progress_bar.set_fraction(0.0)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        vbox.set_homogeneous(False)
        vbox.set_margin_top(20)
        vbox.set_margin_bottom(20)
        vbox.set_margin_start(20)
        vbox.set_margin_end(20)
        vbox.pack_start(self.clone_button, True, True, 0)
        vbox.pack_start(self.install_button, True, True, 0)
        vbox.pack_start(self.reinstall_button, True, True, 0)
        vbox.pack_start(self.progress_bar, True, True, 0)

        self.add(vbox)

    def on_clone_button_clicked(self, widget):
        self.run_command("git clone https://github.com/cilynx/rtl88x2bu.git")

    def on_install_button_clicked(self, widget):
        self.run_command("cd rtl88x2bu && "
                         "VER=$(sed -n 's/\\PACKAGE_VERSION=\"\\(.*\\)\"/\\1/p' dkms.conf) && "
                         "sudo rsync -rvhP ./ /usr/src/rtl88x2bu-${VER} && "
                         "sudo dkms add -m rtl88x2bu -v ${VER} && "
                         "sudo dkms build -m rtl88x2bu -v ${VER} && "
                         "sudo dkms install -m rtl88x2bu -v ${VER} && "
                         "sudo modprobe 88x2bu")

    def on_reinstall_button_clicked(self, widget):
        self.run_command("VER=$(sed -n 's/\\PACKAGE_VERSION=\"\\(.*\\)\"/\\1/p' dkms.conf) && "
                         "sudo dkms install -m rtl88x2bu -v ${VER}")

    def run_command(self, command):
        process = subprocess.Popen(
            command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        while True:
            self.progress_bar.pulse()
            Gtk.main_iteration_do(False)
            if process.poll() is not None:
                self.progress_bar.set_fraction(1.0)
                break

        output, error = process.communicate()
        if output:
            print(output.decode())
        if error:
            print(error.decode())

if __name__ == "__main__":
    win = TPLinkDriverInstaller()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()

