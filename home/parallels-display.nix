{ pkgs, ... }:

# Preferred HiDPI scale. Applied when the mode supports it;
# if not (e.g. window too small), falls back to max supported scale.
let
  preferredScale = 2.0;

  python = pkgs.python3.withPackages (ps: [ ps.dbus-python ps.pygobject3 ]);

  script = pkgs.writeText "prl-display-sync.py" ''
    #!/usr/bin/env python3
    """
    Watches Mutter's MonitorsChanged signal and reapplies the virtio-gpu
    preferred mode when the sysfs preferred resolution changes (Parallels
    window resize). Uses method=2 (persistent) to keep monitors.xml in sync
    so reboots reload the correct config immediately.

    After the initial apply, further MonitorsChanged events are ignored as
    long as the sysfs preferred mode is unchanged, so manual scale changes
    made in GNOME Settings are preserved until the next Parallels resize.
    """
    import os
    import sys
    import time
    import dbus
    import dbus.mainloop.glib
    from gi.repository import GLib

    MODES_FILE     = "/sys/class/drm/card1-Virtual-1/modes"
    CONNECTOR      = "Virtual-1"
    DEBOUNCE_MS    = 400
    PREFERRED_SCALE = float(os.environ.get("PREFERRED_SCALE", "1.0"))

    _pending              = None
    _last_sysfs_preferred = None  # (w, h) last time we acted


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
        global _pending, _last_sysfs_preferred
        _pending = None

        preferred = get_preferred_size()
        if not preferred:
            return False

        # Only act when Parallels actually changed the window size.
        # Skipping when unchanged prevents overriding user scale adjustments.
        if preferred == _last_sysfs_preferred:
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
        monitors = state[1]
        logical  = state[2]

        # Locate the target mode (the one marked is-preferred by the kernel).
        target_id    = None
        target_scale = 1.0
        for monitor in monitors:
            if str(monitor[0][0]) != CONNECTOR:
                continue
            for mode in monitor[1]:
                if int(mode[1]) != pref_w or int(mode[2]) != pref_h:
                    continue
                mprops    = mode[6] if len(mode) > 6 else {}
                supported = [float(s) for s in mode[5]]
                if target_id is None or mprops.get("is-preferred", False):
                    target_id = str(mode[0])
                    target_scale = PREFERRED_SCALE if PREFERRED_SCALE in supported else max(supported)
                if mprops.get("is-preferred", False):
                    break

        if not target_id:
            print(f"prl-display-sync: no mode for {pref_w}x{pref_h}", file=sys.stderr)
            return False

        # Get current resolution and scale to avoid redundant applies.
        current_res   = None
        current_scale = 1.0
        for monitor in monitors:
            if str(monitor[0][0]) != CONNECTOR:
                continue
            for mode in monitor[1]:
                mprops = mode[6] if len(mode) > 6 else {}
                if mprops.get("is-current", False):
                    current_res = (int(mode[1]), int(mode[2]))
        for lm in logical:
            for ms in lm[5]:
                if str(ms[0]) == CONNECTOR:
                    current_scale = float(lm[2])

        # Skip only when BOTH resolution and scale already match the target.
        # Checking scale here (not just resolution) ensures a stale monitors.xml
        # with a wrong scale gets corrected on startup.
        if current_res == (pref_w, pref_h) and abs(current_scale - target_scale) < 0.01:
            _last_sysfs_preferred = preferred
            return False

        print(f"prl-display-sync: applying {pref_w}x{pref_h} "
              f"(mode={target_id}, scale={target_scale})")
        try:
            iface.ApplyMonitorsConfig(
                dbus.UInt32(serial),
                dbus.UInt32(2),  # persistent — writes to monitors.xml to survive reboots
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
            _last_sysfs_preferred = preferred
        except Exception as e:
            print(f"prl-display-sync: ApplyMonitorsConfig failed: {e}",
                  file=sys.stderr)

        return False


    def schedule_apply(bus):
        global _pending
        if _pending:
            GLib.source_remove(_pending)
        _pending = GLib.timeout_add(DEBOUNCE_MS, do_apply, bus)


    def main():
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        time.sleep(2)

        try:
            bus = dbus.SessionBus()
        except Exception as e:
            print(f"prl-display-sync: session bus unavailable: {e}",
                  file=sys.stderr)
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
      Environment = [ "PREFERRED_SCALE=${toString preferredScale}" ];
      ExecStart = "${python}/bin/python3 -u ${script}";
      Restart = "on-failure";
      RestartSec = "5";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
