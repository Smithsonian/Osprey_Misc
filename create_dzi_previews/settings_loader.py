"""Load Osprey settings from a settings.py file (same format as Osprey Worker)."""

import importlib.util
import os


def load_settings(settings_path=None):
    """
    Load settings module from file path.

    Resolution order: explicit path -> OSPREY_SETTINGS env -> ./settings.py
    """
    if not settings_path:
        settings_path = os.environ.get("OSPREY_SETTINGS")
    if not settings_path:
        settings_path = os.path.join(os.getcwd(), "settings.py")
    if not os.path.isfile(settings_path):
        raise FileNotFoundError(f"settings file not found: {settings_path}")
    spec = importlib.util.spec_from_file_location("osprey_dzi_settings", settings_path)
    if spec is None or spec.loader is None:
        raise ImportError(f"cannot load settings from {settings_path}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def validate_settings(settings):
    """Ensure API settings required for dashboard lookups are present."""
    missing = []
    for name in ("api_url", "api_key", "project_alias"):
        if not getattr(settings, name, ""):
            missing.append(name)
    if missing:
        raise ValueError(f"settings missing required values: {', '.join(missing)}")
