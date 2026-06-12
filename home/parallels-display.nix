{ pkgs, ... }:

let
  python = pkgs.python3.withPackages (ps: [ ps.dbus-python ps.pygobject3 ]);

  script = pkgs.writeText "prl-display-sync.py" ''
    #!/usr/bin/env python3
    """
    Watches Mutter's MonitorsChanged signal and reapplies the virtio-gpu
    preferred mode (read from sysfs). Uses method=1 (temporary) so the
    result is never written back to monitors.xml, keeping it in effect
    across subsequent Parallels window resizes.
    """
    import sys
    import time
    import dbus
    import dbus.mainloop.glib
    from gi.repository import GLib

    MODES_FILE = "/sys/class/drm/card1-Virtual-1/modes"
    CONNECTOR   = "Virtual-1"
    DEBOUNCE_MS = 400

    _pending = None


    def get_preferred_size():
        try:
            with open(MODES_FILE) as f:
                line = f.readline().strip()
                if "x" in line:
                    w, h = map(int, line.split("x"))
                    return w, h
        except Exception as e:
            print(f"prl-display-sync: cannot read modes: {e}", file=sys.stderr)
        return None


    def do_apply(bus):
        global _pending
        _pending = None

        preferred = get_preferred_size()
        if not preferred:
            return False
        pref_w, pref_h = preferred

        try:
            proxy = bus.get_object("org.gnome.Mutter.DisplayConfig",
                                   "/org/gnome/Mutter/DisplayConfig")
            iface = dbus.Interface(proxy, "org.gnome.Mutter.DisplayConfig")
            state = iface.GetCurrentState()
        except Exception as e:
            print(f"prl-display-sync: GetCurrentState failed: {e}", file=sys.stderr)
            return False

        serial   = int(state[0])
        monitors = state[1]  # a( (ssss) a(siiddada{sv}) a{sv} )
        logical  = state[2]  # a( iidub a(ssss) a{sv} )

        # Skip if already at preferred mode to break the re-apply loop
        for lm in logical:
            for mon_spec in lm[5]:
                if str(mon_spec[0]) != CONNECTOR:
                    continue
                for monitor in monitors:
                    if str(monitor[0][0]) != CONNECTOR:
                        continue
                    for mode in monitor[1]:
                        mprops = mode[6] if len(mode) > 6 else {}
                        if mprops.get("is-current", False):
                            if int(mode[1]) == pref_w and int(mode[2]) == pref_h:
                                return False

        # Find the preferred mode entry (carries is-preferred: true in its props)
        target_id    = None
        target_scale = 1.0
        for monitor in monitors:
            if str(monitor[0][0]) != CONNECTOR:
                continue
            for mode in monitor[1]:
                if int(mode[1]) != pref_w or int(mode[2]) != pref_h:
                    continue
                mprops = mode[6] if len(mode) > 6 else {}
                if target_id is None or mprops.get("is-preferred", False):
                    target_id    = str(mode[0])
                    target_scale = float(mode[4])
                if mprops.get("is-preferred", False):
                    break

        if not target_id:
            print(f"prl-display-sync: no mode for {pref_w}x{pref_h}", file=sys.stderr)
            return False

        print(f"prl-display-sync: applying {pref_w}x{pref_h} (mode={target_id}, scale={target_scale})")
        try:
            iface.ApplyMonitorsConfig(
                dbus.UInt32(serial),
                dbus.UInt32(1),  # 1 = temporary: do NOT write to monitors.xml
                dbus.Array([
                    (dbus.Int32(0), dbus.Int32(0),
                     dbus.Double(target_scale),
                     dbus.UInt32(0), dbus.Boolean(True),
                     dbus.Array([
                         (dbus.String(CONNECTOR),
                          dbus.String(target_id),
                          dbus.Dictionary({}, signature="sv"))
                     ], signature="(ssa{sv})"))
                ], signature="(iiduba(ssa{sv}))"),
                dbus.Dictionary({}, signature="sv"),
            )
        except Exception as e:
            print(f"prl-display-sync: ApplyMonitorsConfig failed: {e}", file=sys.stderr)

        return False


    def schedule_apply(bus):
        global _pending
        if _pending:
            GLib.source_remove(_pending)
        _pending = GLib.timeout_add(DEBOUNCE_MS, do_apply, bus)


    def main():
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        time.sleep(2)  # wait for the GNOME session to settle

        try:
            bus = dbus.SessionBus()
        except Exception as e:
            print(f"prl-display-sync: session bus unavailable: {e}", file=sys.stderr)
            sys.exit(1)

        bus.add_signal_receiver(
            lambda *_: schedule_apply(bus),
            signal_name="MonitorsChanged",
            dbus_interface="org.gnome.Mutter.DisplayConfig",
            path="/org/gnome/Mutter/DisplayConfig",
        )

        print("prl-display-sync: ready")
        GLib.timeout_add(1000, do_apply, bus)
        GLib.MainLoop().run()


    if __name__ == "__main__":
        main()
  '';
in {
  systemd.user.services.prl-display-sync = {
    Unit = {
      Description = "Sync GNOME display to Parallels virtio-gpu preferred mode";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${python}/bin/python3 -u ${script}";
      Restart = "on-failure";
      RestartSec = "5";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
