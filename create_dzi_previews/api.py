"""HTTP helpers for the Osprey Dashboard API (adapted from worker/api.py)."""

import time

import requests


def send_get(url, logger, timeout=60, slow_threshold=10, log_res=False):
    """Execute GET request. Returns parsed JSON dict on success, None on failure."""
    start = time.monotonic()
    try:
        r = requests.get(url, timeout=timeout)
    except requests.RequestException as e:
        logger.error(f"send_get failed: {url}|{e}")
        return None
    elapsed = time.monotonic() - start

    if r.status_code != 200:
        logger.error(f"send_get error {r.status_code}: {url}|{r.text[:200]}")
        return None

    try:
        results = r.json()
    except ValueError:
        logger.error(f"send_get non-JSON: {url}|{r.status_code}|{r.text[:200]}")
        return None

    if elapsed > slow_threshold:
        logger.warning(f"send_get (slow, {elapsed:.1f}s): {url}")
    else:
        logger.debug(f"send_get ({elapsed:.1f}s): {url}")
    if log_res:
        logger.debug(f"send_get_res: {results}")
    return results


def send_request(url, payload, logger, log_res=False, slow_threshold=10, timeout=60):
    """Execute POST request with form-encoded payload. Returns parsed JSON or None."""
    # Mask api_key in logs
    safe_payload = {k: (v if k != "api_key" else "***") for k, v in payload.items()}
    start = time.monotonic()
    try:
        r = requests.post(url, data=payload, timeout=timeout)
    except requests.RequestException as e:
        logger.error(f"send_request failed: {url}|{safe_payload}|{e}")
        return None
    elapsed = time.monotonic() - start

    if r.status_code != 200:
        logger.error(f"send_request error {r.status_code}: {url}|{safe_payload}")
        return None

    try:
        results = r.json()
    except ValueError:
        logger.error(f"send_request non-JSON: {url}|{safe_payload}|{r.status_code}|{r.text[:200]}")
        return None

    if elapsed > slow_threshold:
        logger.warning(f"send_request (slow, {elapsed:.1f}s): {url}|{safe_payload}")
    else:
        logger.debug(f"send_request ({elapsed:.1f}s): {url}|{safe_payload}")
    if log_res:
        logger.debug(f"send_request_res: {results}")
    return results
