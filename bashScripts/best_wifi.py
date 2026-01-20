import subprocess
import re

def get_saved_wifi_profiles():
    """
    Get the list of saved Wi-Fi profiles using `nmcli`.
    """
    try:
        result = subprocess.run(
            ["nmcli", "-t", "-f", "NAME", "connection", "show"],
            text=True,
            capture_output=True,
            check=True,
        )
        return [line.strip() for line in result.stdout.split("\n") if line.strip()]
    except subprocess.CalledProcessError as e:
        print("Error retrieving saved Wi-Fi profiles:", e)
        return []

def get_visible_wifi_networks():
    """
    Get the list of visible Wi-Fi networks using `nmcli`.
    """
    try:
        result = subprocess.run(
            ["nmcli", "-t", "-f", "SSID", "dev", "wifi", "list"],
            text=True,
            capture_output=True,
            check=True,
        )
        return [line.strip() for line in result.stdout.split("\n") if line.strip()]
    except subprocess.CalledProcessError as e:
        print("Error retrieving visible Wi-Fi networks:", e)
        return []

def find_common_networks(saved_profiles, visible_networks):
    """
    Find Wi-Fi networks that are both remembered and in range.
    """
    return list(set(saved_profiles) & set(visible_networks))

def test_wifi_speed(profile_name):
    """
    Test the Wi-Fi speed by connecting to the network and running `speedtest-cli`.
    """
    try:
        # Connect to the Wi-Fi network
        subprocess.run(
            ["nmcli", "connection", "up", profile_name],
            text=True,
            capture_output=True,
            check=True,
        )
        print(f"Connected to {profile_name}, testing speed...")

        # Run speedtest-cli and capture output
        result = subprocess.run(
            ["speedtest-cli", "--no-upload", "--simple", "--secure"],
            text=True,
            capture_output=True,
            check=True,
        )
        output = result.stdout

        # Extract download speed using regex
        download_match = re.search(r"Download:\s+([\d.]+)\s+(\w+)", output)
        if download_match:
            download_speed = float(download_match.group(1))
            unit = download_match.group(2)
            if unit == "Mbit/s":
                return download_speed  # Speed is already in Mbit/s
            elif unit == "Kbit/s":
                return download_speed / 1000  # Convert to Mbit/s
        else:
            print(f"Could not measure download speed for {profile_name}.")
            return 0  # Default to 0 if speed could not be measured
    except subprocess.CalledProcessError as e:
        print(f"Failed to test speed for {profile_name}: {e.stderr.strip()}")
        return 0

def connect_to_best_network(common_networks):
    """
    Connect to the network with the highest download speed.
    """
    best_network = None
    best_speed = 0

    for network in common_networks:
        print(f"Testing network: {network}")
        speed = test_wifi_speed(network)
        print(f"Download speed for {network}: {speed} Mbit/s")
        if speed > best_speed:
            best_speed = speed
            best_network = network

    if best_network:
        print(f"Best network is {best_network} with {best_speed} Mbit/s. Connecting...")
        subprocess.run(
            ["nmcli", "connection", "up", best_network],
            text=True,
            capture_output=True,
            check=True,
        )
        print(f"Connected to {best_network}.")
    else:
        print("No suitable networks found.")


# Main logic
if __name__ == "__main__":
    print("Getting saved Wi-Fi profiles...")
    saved_profiles = get_saved_wifi_profiles()

    print("Getting visible Wi-Fi networks...")
    visible_networks = get_visible_wifi_networks()

    print("Finding common networks...")
    common_networks = find_common_networks(saved_profiles, visible_networks)

    if common_networks:
        print(f"Common networks found: {common_networks}")
        connect_to_best_network(common_networks)
    else:
        print("No remembered networks are currently in range.")

