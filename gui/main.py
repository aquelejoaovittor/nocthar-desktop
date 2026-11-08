#!/usr/bin/env python3
import gi
import os
import subprocess
import threading

gi.require_version("Gtk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import Gtk, Gdk, GLib, GdkPixbuf

class NoctharApp(Gtk.Window):
    def __init__(self):
        super().__init__(title="NOCTHAR DESKTOP")
        self.set_default_size(1000, 700)
        self.set_border_width(0)

        self.project_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        self.wallpaper_dir = os.path.join(self.project_root, "assets", "wallpapers")

        # Carregar CSS
        css_provider = Gtk.CssProvider()
        css_path = os.path.join(os.path.dirname(__file__), "style.css")
        css_provider.load_from_path(css_path)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        # Layout Principal
        main_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        self.add(main_box)

        # Sidebar
        sidebar = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        sidebar.get_style_context().add_class("sidebar")
        sidebar.set_size_request(200, -1)
        
        menu_items = ["Dashboard", "Perfis Visuais", "Wallpapers", "Backup"]
        for item in menu_items:
            btn = Gtk.Button()
            btn.get_style_context().add_class("sidebar-button")
            lbl = Gtk.Label(label=item)
            lbl.set_xalign(0) 
            btn.add(lbl)
            sidebar.pack_start(btn, False, False, 0)
            
        main_box.pack_start(sidebar, False, False, 0)

        # Área de Conteúdo com Abas
        self.notebook = Gtk.Notebook()
        self.notebook.set_border_width(15)
        main_box.pack_start(self.notebook, True, True, 0)

        # Constrói as abas
        self.build_profiles_tab()
        self.build_wallpapers_tab()

        # Log console
        self.log_view = Gtk.TextView()
        self.log_view.set_editable(False)
        self.log_view.get_style_context().add_class("log-view")
        self.log_view.set_size_request(-1, 120)
        main_box.pack_end(self.log_view, False, False, 0)

        self.log("Interface gráfica NOCTHAR inicializada.")

    def build_profiles_tab(self):
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=15)
        vbox.set_border_width(15)

        title = Gtk.Label()
        title.set_markup("<span size='x-large' weight='bold' color='#00D2FF'>Gerenciador de Perfis</span>")
        title.set_xalign(0)
        vbox.pack_start(title, False, False, 0)

        profile_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        
        btn_core = Gtk.Button(label="Aplicar CORE")
        btn_core.get_style_context().add_class("profile-btn")
        btn_core.connect("clicked", self.on_profile_clicked, "core")
        
        btn_abyss = Gtk.Button(label="Aplicar ABYSS")
        btn_abyss.get_style_context().add_class("profile-btn")
        btn_abyss.get_style_context().add_class("profile-btn-abyss")
        btn_abyss.connect("clicked", self.on_profile_clicked, "abyss")
        
        btn_nexus = Gtk.Button(label="Aplicar NEXUS")
        btn_nexus.get_style_context().add_class("profile-btn")
        btn_nexus.connect("clicked", self.on_profile_clicked, "nexus")

        profile_box.pack_start(btn_core, True, True, 0)
        profile_box.pack_start(btn_abyss, True, True, 0)
        profile_box.pack_start(btn_nexus, True, True, 0)
        vbox.pack_start(profile_box, False, False, 0)

        self.notebook.append_page(vbox, Gtk.Label(label="Perfis"))

    def build_wallpapers_tab(self):
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=15)
        vbox.set_border_width(15)

        title = Gtk.Label()
        title.set_markup("<span size='x-large' weight='bold' color='#00D2FF'>Galeria de Wallpapers</span>")
        title.set_xalign(0)
        vbox.pack_start(title, False, False, 0)

        flowbox = Gtk.FlowBox()
        flowbox.set_valign(Gtk.Align.START)
        flowbox.set_max_children_per_line(3)
        flowbox.set_selection_mode(Gtk.SelectionMode.NONE)
        flowbox.set_homogeneous(True)

        # Gera os wallpapers antes de listar
        subprocess.run(["bash", os.path.join(self.project_root, "desktop", "configure-wallpapers.sh")], check=False)

        if os.path.exists(self.wallpaper_dir):
            for file in os.listdir(self.wallpaper_dir):
                if file.endswith((".png", ".jpg", ".svg")):
                    img_path = os.path.join(self.wallpaper_dir, file)
                    
                    btn = Gtk.Button()
                    btn.get_style_context().add_class("profile-btn")
                    
                    try:
                        # REDIMENSIONAMENTO AQUI: Força a imagem a ter 300x200 para caber no botão
                        pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
                            filename=img_path,
                            width=300,
                            height=200,
                            preserve_aspect_ratio=True
                        )
                        img = Gtk.Image.new_from_pixbuf(pixbuf)
                    except Exception as e:
                        img = Gtk.Image.new_from_icon_name("image-x-generic", Gtk.IconSize.DIALOG)
                    
                    btn.set_image(img)
                    btn.set_always_show_image(True)
                    btn.connect("clicked", self.on_wallpaper_clicked, img_path)
                    flowbox.add(btn)

        scroll = Gtk.ScrolledWindow()
        scroll.add(flowbox)
        vbox.pack_start(scroll, True, True, 0)

        self.notebook.append_page(vbox, Gtk.Label(label="Wallpapers"))

    def log(self, message):
        buffer = self.log_view.get_buffer()
        end_iter = buffer.get_end_iter()
        buffer.insert(end_iter, f"{message}\n")
        self.log_view.scroll_to_iter(buffer.get_end_iter(), 0.0, False, 0.0, 0.0)

    def on_profile_clicked(self, widget, profile_name):
        self.log(f"\n--- Aplicando perfil: {profile_name.upper()} ---")
        thread = threading.Thread(target=self.run_bash, args=("core/profiles.sh", "--apply", f"{self.project_root}/config/{profile_name}.json"))
        thread.daemon = True
        thread.start()

    def on_wallpaper_clicked(self, widget, img_path):
        self.log(f"\n--- Aplicando wallpaper: {os.path.basename(img_path)} ---")
        thread = threading.Thread(target=self.run_bash, args=("desktop/configure-wallpapers.sh", img_path))
        thread.daemon = True
        thread.start()

    def run_bash(self, script, arg1="", arg2=""):
        script_path = os.path.join(self.project_root, script)
        cmd = ["bash", script_path]
        if arg1: cmd.append(arg1)
        if arg2: cmd.append(arg2)

        try:
            process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
            for line in process.stdout:
                GLib.idle_add(self.log, line.strip())
            process.wait()
        except Exception as e:
            GLib.idle_add(self.log, f"ERRO: {str(e)}")

if __name__ == "__main__":
    app = NoctharApp()
    app.connect("destroy", Gtk.main_quit)
    app.show_all()
    Gtk.main()
