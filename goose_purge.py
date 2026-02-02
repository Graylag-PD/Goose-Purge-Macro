# klippy/extras/goose_purge.py

class GoosePurge:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.gcode = self.printer.lookup_object('gcode')

        # So far just diag msg 
        self.gcode.respond_info("Goose Purge module loaded")

def load_config(config):
    cfg_ver = config.getint("config_version", default=1)
    return GoosePurge(config)
