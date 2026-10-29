# Managed by Ansible. Local changes will be overwritten.
#
# LiteLLM pre-call hook that gives every client the same persona (Muninn).
# Prompts are assembled by the llm role from prompts/ in hlac into
# persona.json next to this file. The calling key's alias picks the surface;
# keys with no surface pass through untouched.
import json
import logging
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

from litellm.integrations.custom_logger import CustomLogger

log = logging.getLogger("persona")

CONFIG = json.loads((Path(__file__).parent / "persona.json").read_text())
TZ = ZoneInfo(CONFIG["timezone"])
LOCAL_MODELS = set(CONFIG["local_models"])

# Sent by Open WebUI with ENABLE_FORWARD_USER_INFO_HEADERS=true
USER_NAME_HEADER = "x-openwebui-user-name"


def _headers(data):
    """Request headers, lower-cased, wherever this LiteLLM version keeps them."""
    for container in (data.get("proxy_server_request"), data.get("metadata"), data.get("litellm_metadata")):
        if isinstance(container, dict) and isinstance(container.get("headers"), dict):
            return {str(k).lower(): v for k, v in container["headers"].items()}
    return {}


def _prepend(messages, text):
    """Put text at the start of the first system message, adding one if needed.

    Merging instead of adding a second system message matters: several local
    chat templates reject or mangle more than one.
    """
    if messages and messages[0].get("role") in ("system", "developer"):
        first = dict(messages[0])
        content = first.get("content")
        if isinstance(content, list):
            first["content"] = [{"type": "text", "text": text}] + content
        elif content:
            first["content"] = f"{text}\n\n{content}"
        else:
            first["content"] = text
        return [first] + messages[1:]
    return [{"role": "system", "content": text}] + messages


class Persona(CustomLogger):
    async def async_pre_call_hook(self, user_api_key_dict, cache, data, call_type):
        if call_type not in ("completion", "acompletion"):
            return data
        messages = data.get("messages")
        surface = CONFIG["surfaces"].get(getattr(user_api_key_dict, "key_alias", None) or "")
        if not surface or not isinstance(messages, list):
            return data

        local = data.get("model") in LOCAL_MODELS
        name = _headers(data).get(USER_NAME_HEADER) if local else None

        text = surface["system"]
        if local and surface.get("personal"):
            text = f"{text}\n\n{surface['personal']}"
        text = text.replace("{{USER_NAME}}", name or "the user")
        now = datetime.now(TZ)
        hour = now.hour % 12 or 12
        text += f"\n\nCurrent date and time: {now:%A, %B} {now.day}, {now:%Y}, {hour}:{now:%M %p %Z}"

        data["messages"] = _prepend(messages, text)
        return data


proxy_handler_instance = Persona()
