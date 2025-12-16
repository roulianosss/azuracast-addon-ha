#!/usr/bin/env python3
"""
Home Assistant Integration for AzuraCast Add-on
This script monitors AzuraCast and exposes data to Home Assistant via API
"""

import json
import time
import logging
import sys
from typing import Dict, Optional
import requests
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger('ha-integration')

class AzuraCastMonitor:
    """Monitor AzuraCast and expose metrics to Home Assistant"""

    def __init__(self):
        self.azuracast_url = "http://localhost"
        self.ha_supervisor_url = "http://supervisor/core"
        self.supervisor_token = self._get_supervisor_token()
        self.poll_interval = 30  # seconds

    def _get_supervisor_token(self) -> Optional[str]:
        """Get the Supervisor token for Home Assistant API access"""
        try:
            with open('/data/options.json', 'r') as f:
                return None  # Token is automatically handled by bashio
        except Exception as e:
            logger.warning(f"Could not get supervisor token: {e}")
            return None

    def get_azuracast_status(self) -> Optional[Dict]:
        """Get AzuraCast system status"""
        try:
            response = requests.get(
                f"{self.azuracast_url}/api/status",
                timeout=10
            )
            if response.status_code == 200:
                return response.json()
            else:
                logger.warning(f"Failed to get status: {response.status_code}")
                return None
        except Exception as e:
            logger.error(f"Error getting AzuraCast status: {e}")
            return None

    def get_stations(self) -> Optional[list]:
        """Get list of all stations"""
        try:
            response = requests.get(
                f"{self.azuracast_url}/api/stations",
                timeout=10
            )
            if response.status_code == 200:
                return response.json()
            else:
                logger.warning(f"Failed to get stations: {response.status_code}")
                return None
        except Exception as e:
            logger.error(f"Error getting stations: {e}")
            return None

    def get_nowplaying(self, station_id: int) -> Optional[Dict]:
        """Get now playing information for a station"""
        try:
            response = requests.get(
                f"{self.azuracast_url}/api/nowplaying/{station_id}",
                timeout=10
            )
            if response.status_code == 200:
                return response.json()
            else:
                logger.warning(f"Failed to get nowplaying for station {station_id}: {response.status_code}")
                return None
        except Exception as e:
            logger.error(f"Error getting nowplaying for station {station_id}: {e}")
            return None

    def create_sensor_state(self, entity_id: str, state: str, attributes: Dict) -> Dict:
        """Create a sensor state payload for Home Assistant"""
        return {
            "state": state,
            "attributes": {
                **attributes,
                "integration": "azuracast",
                "last_updated": datetime.now().isoformat()
            }
        }

    def publish_to_ha(self, entity_id: str, state: str, attributes: Dict):
        """Publish sensor state to Home Assistant (placeholder for future MQTT integration)"""
        # This would integrate with Home Assistant's MQTT Discovery or REST API
        # For now, we just log the data
        logger.info(f"Sensor {entity_id}: {state} | Attributes: {json.dumps(attributes, indent=2)}")

    def monitor_loop(self):
        """Main monitoring loop"""
        logger.info("Starting AzuraCast monitoring loop...")

        while True:
            try:
                # Get system status
                status = self.get_azuracast_status()
                if status:
                    self.publish_to_ha(
                        "sensor.azuracast_status",
                        "online" if status.get("online") else "offline",
                        {
                            "online": status.get("online", False),
                            "version": status.get("version", "unknown")
                        }
                    )

                # Get stations
                stations = self.get_stations()
                if stations:
                    self.publish_to_ha(
                        "sensor.azuracast_stations",
                        str(len(stations)),
                        {
                            "count": len(stations),
                            "stations": [s.get("name", "Unknown") for s in stations]
                        }
                    )

                    # Monitor each station
                    for station in stations:
                        station_id = station.get("id")
                        station_name = station.get("name", "Unknown")

                        # Get now playing data
                        nowplaying = self.get_nowplaying(station_id)
                        if nowplaying:
                            listeners = nowplaying.get("listeners", {})
                            current_listeners = listeners.get("current", 0)
                            unique_listeners = listeners.get("unique", 0)

                            now_playing = nowplaying.get("now_playing", {})
                            song = now_playing.get("song", {})

                            self.publish_to_ha(
                                f"sensor.azuracast_station_{station_id}_listeners",
                                str(current_listeners),
                                {
                                    "station_name": station_name,
                                    "current_listeners": current_listeners,
                                    "unique_listeners": unique_listeners,
                                    "song_title": song.get("title", "Unknown"),
                                    "song_artist": song.get("artist", "Unknown"),
                                    "is_live": now_playing.get("is_live", False)
                                }
                            )

                # Wait before next poll
                time.sleep(self.poll_interval)

            except KeyboardInterrupt:
                logger.info("Monitoring stopped by user")
                break
            except Exception as e:
                logger.error(f"Error in monitoring loop: {e}")
                time.sleep(self.poll_interval)

def main():
    """Main entry point"""
    logger.info("AzuraCast Home Assistant Integration starting...")

    # Wait for AzuraCast to be ready
    logger.info("Waiting for AzuraCast to become available...")
    time.sleep(60)  # Give AzuraCast time to start

    monitor = AzuraCastMonitor()

    try:
        monitor.monitor_loop()
    except Exception as e:
        logger.error(f"Fatal error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
