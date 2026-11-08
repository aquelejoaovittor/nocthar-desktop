#!/usr/bin/env python3
import gi
import os
import subprocess
import threading

gi.require_version("Gtk", "3.0")
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import Gtk, Gdk, GLib, GdkPixbuf

# Garante que as pastas XDG do usuário existam, independente de onde o app foi instalado
os.makedirs(os.path.expanduser("~/.config/nocthar/logs"), exist_ok=True)
os.makedirs(os.path.expanduser("~/.local/share/nocthar/backups"), exist_ok=True)
os.makedirs(os.path.expanduser("~/.local/share/nocthar/state"), exist_ok=True)
os.makedirs(os.path.expanduser("~/.local/share/nocthar/cache"), exist_ok=True)

class NoctharApp(Gtk.Window):
    def __init__(self):
        super().__init__(title="NOCTHAR DESKTOP")
        self.set_default_size(1000, 700)
        self.set_border_width(0)

        # Detecta se está rodando da pasta do projeto ou de /usr/share/nocthar
        current_dir = os.path.dirname(os.path.abspath(__file__))
        if current_dir.startswith("/usr/share/nocthar"):
            self.project_root = "/usr/share/nocthar"
        else:
            self.project_root = os.path.dirname(current_dir)

        self.wallpaper_dir = os.path.join(self.project_root, "assets", "wallpapers")
        self.backup_dir = os.path.join(os.path.expanduser("~"), ".local", "share", "nocthar", "backups")

        # Carregar CSS
        css_provider = Gtk.CssProvider()
        css_path = os.path.join(os.path.dirname(__file__), "style.css")
        if os.path.exists(css_path):
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
        
        menu_items = ["Perfis", "Wallpapers", "Aparência", "Sistema", "Backup"]
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

        self.build_profiles_tab()
        self.build_wallpapers_tab()
        self.build_appearance_tab()
        self.build_system_tab()
        self.build_backup_tab()

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
        subprocess.run(["bash", os.path.join(self.project_root, "desktop", "configure-wallpapers.sh")], check=False)
        if os.path.exists(self.wallpaper_dir):
            for file in os.listdir(self.wallpaper_dir):
                if file.endswith((".png", ".jpg", ".svg")):
                    img_path = os.path.join(self.wallpaper_dir, file)
                    btn = Gtk.Button()
                    btn.get_style_context().add_class("profile-btn")
                    try:
                        pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(img_path, 300, 200, True)
                        img = Gtk.Image.new_from_pixbuf(pixbuf)
                    except Exception:
                        img = Gtk.Image.new_from_icon_name("image-x-generic", Gtk.IconSize.DIALOG)
                    btn.set_image(img)
                    btn.set_always_show_image(True)
                    btn.connect("clicked", self.on_wallpaper_clicked, img_path)
                    flowbox.add(btn)
        scroll = Gtk.ScrolledWindow()
        scroll.add(flowbox)
        vbox.pack_start(scroll, True, True, 0)
        self.notebook.append_page(vbox, Gtk.Label(label="Wallpapers"))

    def build_appearance_tab(self):
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=15)
        vbox.set_border_width(15)
        title = Gtk.Label()
        title.set_markup("<span size='x-large' weight='bold' color='#00D2FF'>Fontes e Cursores</span>")
        title.set_xalign(0)
        vbox.pack_start(title, False, False, 0)
        lbl_font = Gtk.Label(label="Selecione a Fonte do Sistema:")
        lbl_font.set_xalign(0)
        vbox.pack_start(lbl_font, False, False, 0)
        self.font_combo = Gtk.ComboBoxText()
        self.load_system_fonts()
        vbox.pack_start(self.font_combo, False, False, 0)
        btn_apply_font = Gtk.Button(label="Aplicar Fonte")
        btn_apply_font.get_style_context().add_class("profile-btn")
        btn_apply_font.connect("clicked", self.on_apply_font)
        vbox.pack_start(btn_apply_font, False, False, 10)
        lbl_cursor = Gtk.Label(label="Selecione o Cursor:")
        lbl_cursor.set_xalign(0)
        vbox.pack_start(lbl_cursor, False, False, 10)
        self.cursor_combo = Gtk.ComboBoxText()
        self.load_system_cursors()
        vbox.pack_start(self.cursor_combo, False, False, 0)
        btn_apply_cursor = Gtk.Button(label="Aplicar Cursor")
        btn_apply_cursor.get_style_context().add_class("profile-btn")
        btn_apply_cursor.get_style_context().add_class("profile-btn-abyss")
        btn_apply_cursor.connect("clicked", self.on_apply_cursor)
        vbox.pack_start(btn_apply_cursor, False, False, 10)
        self.notebook.append_page(vbox, Gtk.Label(label="Aparência"))

    def build_system_tab(self):
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=20)
        vbox.set_border_width(15)
        title = Gtk.Label()
        title.set_markup("<span size='x-large' weight='bold' color='#00D2FF'>Sistema: Caja e Terminal</span>")
        title.set_xalign(0)
        vbox.pack_start(title, False, False, 0)
        lbl_caja = Gtk.Label()
        lbl_caja.set_markup("<b>Caja (Gerenciador de Arquivos)</b>")
        lbl_caja.set_xalign(0)
        vbox.pack_start(lbl_caja, False, False, 0)
        self.check_hidden = Gtk.CheckButton(label="Mostrar arquivos ocultos")
        vbox.pack_start(self.check_hidden, False, False, 0)
        box_caja_view = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        box_caja_view.pack_start(Gtk.Label(label="Modo de Visualização Padrão:"), False, False, 0)
        self.caja_view_combo = Gtk.ComboBoxText()
        self.caja_view_combo.append_text("icon-view")
        self.caja_view_combo.append_text("list-view")
        self.caja_view_combo.set_active(0)
        box_caja_view.pack_start(self.caja_view_combo, False, False, 0)
        vbox.pack_start(box_caja_view, False, False, 0)
        btn_apply_caja = Gtk.Button(label="Aplicar Configurações do Caja")
        btn_apply_caja.get_style_context().add_class("profile-btn")
        btn_apply_caja.connect("clicked", self.on_apply_caja)
        vbox.pack_start(btn_apply_caja, False, False, 10)
        lbl_term = Gtk.Label()
        lbl_term.set_markup("<b>Terminal (Transparência)</b>")
        lbl_term.set_xalign(0)
        vbox.pack_start(lbl_term, False, False, 10)
        box_term = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        box_term.pack_start(Gtk.Label(label="Transparência (0% a 50%):"), False, False, 0)
        self.opacity_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 50, 1)
        self.opacity_scale.set_value(10)
        self.opacity_scale.set_draw_value(True)
        self.opacity_scale.set_value_pos(Gtk.PositionType.RIGHT)
        box_term.pack_start(self.opacity_scale, True, True, 0)
        vbox.pack_start(box_term, False, False, 0)
        btn_apply_term = Gtk.Button(label="Aplicar Transparência do Terminal")
        btn_apply_term.get_style_context().add_class("profile-btn")
        btn_apply_term.get_style_context().add_class("profile-btn-abyss")
        btn_apply_term.connect("clicked", self.on_apply_term_opacity)
        vbox.pack_start(btn_apply_term, False, False, 10)
        self.notebook.append_page(vbox, Gtk.Label(label="Sistema"))

    def build_backup_tab(self):
        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=15)
        vbox.set_border_width(15)
        title = Gtk.Label()
        title.set_markup("<span size='x-large' weight='bold' color='#00D2FF'>Gerenciador de Backup</span>")
        title.set_xalign(0)
        vbox.pack_start(title, False, False, 0)
        btn_create = Gtk.Button(label="Criar Novo Backup do Sistema")
        btn_create.get_style_context().add_class("profile-btn")
        btn_create.connect("clicked", self.on_create_backup)
        vbox.pack_start(btn_create, False, False, 0)
        list_label = Gtk.Label(label="Backups Disponíveis:")
        list_label.set_xalign(0)
        vbox.pack_start(list_label, False, False, 10)
        self.backup_listbox = Gtk.ListBox()
        self.backup_listbox.set_selection_mode(Gtk.SelectionMode.SINGLE)
        scroll = Gtk.ScrolledWindow()
        scroll.set_vexpand(True)
        scroll.add(self.backup_listbox)
        vbox.pack_start(scroll, True, True, 0)
        btn_restore = Gtk.Button(label="Restaurar Backup Selecionado")
        btn_restore.get_style_context().add_class("profile-btn")
        btn_restore.get_style_context().add_class("profile-btn-abyss")
        btn_restore.connect("clicked", self.on_restore_backup)
        vbox.pack_start(btn_restore, False, False, 0)
        self.refresh_backup_list()
        self.notebook.append_page(vbox, Gtk.Label(label="Backup"))

    def load_system_fonts(self):
        try:
            out = subprocess.check_output(["fc-list", ":family"], text=True)
            fonts = sorted(list(set([line.split(',')[0].strip() for line in out.splitlines()])))
            for f in fonts[:50]:
                self.font_combo.append_text(f)
            self.font_combo.set_active(0)
        except Exception:
            self.font_combo.append_text("Erro ao carregar fontes")

    def load_system_cursors(self):
        cursors = set()
        dirs = [os.path.expanduser("~/.icons"), "/usr/share/icons"]
        for d in dirs:
            if os.path.exists(d):
                for item in os.listdir(d):
                    if os.path.isdir(os.path.join(d, item, "cursors")):
                        cursors.add(item)
        for c in sorted(cursors):
            self.cursor_combo.append_text(c)
        self.cursor_combo.set_active(0)

    def refresh_backup_list(self):
        for row in self.backup_listbox.get_children():
            self.backup_listbox.remove(row)
        if os.path.exists(self.backup_dir):
            files = sorted([f for f in os.listdir(self.backup_dir) if f.endswith(".tar.gz")], reverse=True)
            for f in files:
                row = Gtk.ListBoxRow()
                lbl = Gtk.Label(label=f.replace(".tar.gz", ""))
                lbl.set_xalign(0)
                lbl.set_margin_top(10)
                lbl.set_margin_bottom(10)
                lbl.set_margin_start(10)
                row.add(lbl)
                row.backup_file = os.path.join(self.backup_dir, f)
                self.backup_listbox.add(row)
        self.backup_listbox.show_all()

    def on_apply_font(self, widget):
        font = self.font_combo.get_active_text()
        if font:
            self.log(f"\n--- Aplicando Fonte: {font} ---")
            threading.Thread(target=self.run_bash, args=("desktop/apply-font.sh", f"{font} 10"), daemon=True).start()

    def on_apply_cursor(self, widget):
        cursor = self.cursor_combo.get_active_text()
        if cursor:
            self.log(f"\n--- Aplicando Cursor: {cursor} ---")
            threading.Thread(target=self.run_bash, args=("desktop/apply-cursor.sh", cursor), daemon=True).start()

    def on_apply_caja(self, widget):
        hidden = "true" if self.check_hidden.get_active() else "false"
        view_mode = self.caja_view_combo.get_active_text()
        self.log(f"\n--- Configurando Caja (Ocultos: {hidden}, Modo: {view_mode}) ---")
        threading.Thread(target=self.run_bash, args=("desktop/configure-caja.sh", hidden, view_mode), daemon=True).start()

    def on_apply_term_opacity(self, widget):
        opacity = int(self.opacity_scale.get_value())
        self.log(f"\n--- Configurando Transparência do Terminal: {opacity}% ---")
        threading.Thread(target=self.run_bash, args=("desktop/configure-terminal-opacity.sh", str(opacity)), daemon=True).start()

    def on_create_backup(self, widget):
        self.log("\n--- Criando Backup ---")
        threading.Thread(target=self.run_bash, args=("backup.sh",), daemon=True).start()
        GLib.timeout_add(2000, self.refresh_backup_list)

    def on_restore_backup(self, widget):
        selected = self.backup_listbox.get_selected_row()
        if not selected:
            self.log("AVISO: Selecione um backup na lista primeiro.")
            return
        self.log(f"\n--- Restaurando: {os.path.basename(selected.backup_file)} ---")
        threading.Thread(target=self.run_bash, args=("restore.sh", selected.backup_file), daemon=True).start()

    def on_profile_clicked(self, widget, profile_name):
        self.log(f"\n--- Aplicando perfil: {profile_name.upper()} ---")
        threading.Thread(target=self.run_bash, args=("core/profiles.sh", "--apply", f"{self.project_root}/config/{profile_name}.json"), daemon=True).start()

    def on_wallpaper_clicked(self, widget, img_path):
        self.log(f"\n--- Aplicando wallpaper: {os.path.basename(img_path)} ---")
        threading.Thread(target=self.run_bash, args=("desktop/configure-wallpapers.sh", img_path), daemon=True).start()

    def log(self, message):
        buffer = self.log_view.get_buffer()
        end_iter = buffer.get_end_iter()
        buffer.insert(end_iter, f"{message}\n")
        self.log_view.scroll_to_iter(buffer.get_end_iter(), 0.0, False, 0.0, 0.0)

    def run_bash(self, script, *args):
        script_path = os.path.join(self.project_root, script)
        cmd = ["bash", script_path] + list(args)
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
