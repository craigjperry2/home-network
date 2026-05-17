# Implementation: Home Assistant Wake-on-LAN for `s1`

This document details the exact configuration steps required to create a Wake-on-LAN switch for the `s1` server within Home Assistant and expose it to Apple HomeKit.

## Server Details (`s1`)
The following network details are specific to the `s1` host on the local network (Interface: `enp0s31f6`):
- **MAC Address:** `9c:5c:8e:87:b9:36`
- **IP Address:** `192.168.5.181`
- **Broadcast Address:** `192.168.7.255` (Derived from the /22 subnet)

## Step 1: Home Assistant Configuration

You must edit the `configuration.yaml` file on your Home Assistant OS instance (running on the always-on Raspberry Pi 5).

### 1. Enable Wake on LAN
Add the `wake_on_lan` integration to the top level of your configuration:

```yaml
wake_on_lan:
```

### 2. Define the Switch
Add a new switch under the `switch` domain using the `wake_on_lan` platform and the specific details for `s1`:

```yaml
switch:
  - platform: wake_on_lan
    mac: "9c:5c:8e:87:b9:36"
    name: "s1 Plex Server"
    host: "192.168.5.181"
    broadcast_address: "192.168.7.255"
```
*Note: The `host` parameter is critical; it tells Home Assistant to continuously ping `192.168.5.181` to determine the accurate "On/Off" state of the switch based on the server's actual power state.*

### 3. Apply Changes
Save the `configuration.yaml` file. In the Home Assistant UI, go to **Developer Tools > YAML**, click **Check Configuration**, and if valid, restart Home Assistant.

---

## Step 2: HomeKit Exposure

Once Home Assistant restarts, the new entity `switch.s1_plex_server` will be available. You now need to expose it to the Apple Home app via the HomeKit Bridge.

### Option A: Using the UI (Recommended)
1. In Home Assistant, navigate to **Settings > Devices & Services**.
2. Locate the **Apple** integration and find your **HomeKit Bridge**.
3. Click **Configure**.
4. Proceed through the setup. Ensure the `Switch` domain is selected.
5. In the entity selection screen, ensure `switch.s1_plex_server` is checked to be included in the bridge.

### Option B: Using YAML Configuration
If you manage your HomeKit Bridge via `configuration.yaml`, update your `homekit` block to include the specific entity:

```yaml
homekit:
  - filter:
      include_entities:
        - switch.s1_plex_server
```

---

## Expected Behavior

1. **Visibility:** You will see a new switch named **s1 Plex Server** in the Apple Home app on your iOS devices.
2. **State Monitoring:** When `s1` is awake (e.g., currently streaming Plex), Home Assistant's ping will succeed, and the switch in the Apple Home app will appear **On**.
3. **Auto-Sleep:** After 5 minutes of inactivity, `s1`'s internal `autosuspend` logic will put the server to sleep. Home Assistant's ping will fail, and the Apple Home switch will update to **Off**.
4. **Remote Wake:** If you are away from home and connected to Tailscale, you can open the Apple Home app and tap the switch to turn it **On**. Home Assistant will send the Layer 2 Magic Packet over the local LAN, waking `s1` instantly so it becomes available on the tailnet.