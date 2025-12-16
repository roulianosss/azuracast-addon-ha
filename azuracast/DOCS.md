# AzuraCast Add-on Documentation

## Introduction

This Home Assistant add-on provides a complete AzuraCast web radio management suite integration. AzuraCast is a powerful, self-hosted solution for managing internet radio stations with features like live streaming, AutoDJ, listener statistics, and much more.

## Installation Steps

### 1. Add the Repository

Add this repository to your Home Assistant instance:

1. Navigate to **Supervisor** → **Add-on Store**
2. Click the three dots in the top right corner
3. Select **Repositories**
4. Add this repository URL
5. Click **Add**

### 2. Install the Add-on

1. Find "AzuraCast" in the add-on store
2. Click on it
3. Click **Install**
4. Wait for the installation to complete (this may take several minutes)

### 3. Configure the Add-on

Before starting the add-on, configure it according to your needs:

```yaml
AZURACAST_HTTP_PORT: 80
AZURACAST_HTTPS_PORT: 443
LETSENCRYPT_ENABLE: false
MYSQL_ROOT_PASSWORD: "your-secure-password"
MYSQL_USER: "azuracast"
MYSQL_PASSWORD: "your-secure-password"
MYSQL_DATABASE: "azuracast"
```

**Important Notes:**
- If you leave `MYSQL_ROOT_PASSWORD` or `MYSQL_PASSWORD` empty, random passwords will be generated automatically
- Make sure to save these passwords if you need to access the database directly
- The default ports (80, 443) may conflict with other services; adjust as needed

### 4. Start the Add-on

1. Go to the **Info** tab
2. Click **Start**
3. Wait for the add-on to start (first start may take 5-10 minutes)
4. Check the **Log** tab for any errors

## First Time Setup

### Access the Web Interface

Once the add-on is running, access AzuraCast at:
- `http://homeassistant.local:8080` (or your configured HTTP port)

### Initial Configuration Wizard

1. **Create Admin Account**: On first access, you'll be prompted to create an administrator account
2. **System Settings**: Configure basic system settings like timezone and site URL
3. **Create Your First Station**: Follow the wizard to set up your first radio station

## Configuration Options

### Network Ports

The add-on exposes multiple ports for different purposes:

- **80/443**: Web interface (HTTP/HTTPS)
- **8000-8100**: Radio streaming ports (one per station)
  - Each station uses multiple ports:
    - Main radio port (e.g., 8000)
    - SFTP port (e.g., 8005)
    - WebSocket port (e.g., 8006)

### Database Configuration

AzuraCast uses MySQL for data storage. The database runs inside the add-on container.

**Important**: Data is persisted in the `/data/azuracast` directory, which is mapped to your Home Assistant storage.

### SSL/TLS Configuration

For SSL support:
1. Set `LETSENCRYPT_ENABLE: true`
2. Ensure ports 80 and 443 are accessible from the internet
3. Configure a valid domain name pointing to your Home Assistant instance

**Note**: SSL configuration requires additional setup and may not work in all environments.

## Managing Radio Stations

### Creating a Station

1. Log in to the AzuraCast web interface
2. Click **Add Station**
3. Configure station details:
   - Name and description
   - Frontend (Icecast or SHOUTcast)
   - Backend (Liquidsoap)
   - Ports (automatically assigned)

### Uploading Music

Two methods to upload music:

1. **Web Interface**:
   - Go to your station
   - Click **Media** → **Music Files**
   - Click **Upload**

2. **SFTP**:
   - Use an SFTP client
   - Connect to your Home Assistant IP
   - Port: Station SFTP port (e.g., 8005)
   - Username/Password: Created in Station settings

### Creating Playlists

1. Go to **Playlists**
2. Click **Add Playlist**
3. Configure:
   - **Standard**: Regular playlist
   - **Advanced**: With scheduling rules
   - **Once per Hour**: Jingles, ads, etc.

### Going Live

For live broadcasting:

1. Go to **Streamers/DJs**
2. Create a streamer account
3. Use streaming software (OBS, BUTT, etc.) with provided credentials
4. When live, AutoDJ automatically fades out

## API Access

AzuraCast provides a powerful REST API for automation.

### Generating API Keys

1. Go to **Profile** → **API Keys**
2. Click **Add API Key**
3. Give it a name and set permissions
4. Copy the generated key

### API Documentation

Access the API documentation at:
- `http://homeassistant.local:8080/api`

### Example API Usage

```bash
# Get station status
curl -X GET "http://homeassistant.local:8080/api/station/1/status" \
  -H "X-API-Key: your-api-key"

# Get current playing song
curl -X GET "http://homeassistant.local:8080/api/nowplaying/1" \
  -H "X-API-Key: your-api-key"
```

## Integration with Home Assistant

### Sensors

You can create sensors to monitor your radio station:

```yaml
sensor:
  - platform: rest
    name: "Radio Station Listeners"
    resource: "http://homeassistant.local:8080/api/nowplaying/1"
    value_template: "{{ value_json.listeners.current }}"
    headers:
      X-API-Key: "your-api-key"
```

### Automations

Example automation to announce when listeners increase:

```yaml
automation:
  - alias: "Radio Listener Alert"
    trigger:
      platform: numeric_state
      entity_id: sensor.radio_station_listeners
      above: 10
    action:
      service: notify.mobile_app
      data:
        message: "Your radio station has {{ states('sensor.radio_station_listeners') }} listeners!"
```

## Backup and Restore

### Backup

Data is stored in `/data/azuracast` on your Home Assistant instance. This is included in Home Assistant backups.

For manual backup:
1. Stop the add-on
2. Copy `/data/azuracast` to a safe location
3. Restart the add-on

### Restore

1. Stop the add-on
2. Replace `/data/azuracast` with your backup
3. Restart the add-on

## Troubleshooting

### Add-on Won't Start

1. Check logs: **Supervisor** → **AzuraCast** → **Log**
2. Common issues:
   - Port conflicts: Change ports in configuration
   - Insufficient resources: AzuraCast needs at least 2GB RAM
   - Docker issues: Restart Home Assistant

### Web Interface Not Accessible

1. Verify the add-on is running
2. Check that the port is correct
3. Try accessing via IP: `http://YOUR_HA_IP:8080`
4. Check firewall settings

### No Audio from Station

1. Verify the station is started (in AzuraCast dashboard)
2. Check that AutoDJ has playlists configured
3. Ensure music files are uploaded and processed
4. Test stream URL directly: `http://YOUR_HA_IP:8000/radio.mp3`

### Performance Issues

AzuraCast is resource-intensive. Recommendations:
- Minimum 2GB RAM
- Adequate CPU (especially for encoding multiple streams)
- Fast storage (SSD recommended)
- Consider running on a dedicated machine for multiple stations

## Advanced Configuration

### Custom Docker Compose

For advanced users, you can modify the Docker Compose configuration:

1. Access add-on storage
2. Edit `/azuracast/docker-compose.yml`
3. Restart the add-on

**Warning**: Custom modifications may break the add-on or be overwritten on updates.

### Environment Variables

Additional environment variables can be set in the AzuraCast `.env` file located in `/azuracast/.env`

## Resources

- [AzuraCast Official Documentation](https://docs.azuracast.com/)
- [AzuraCast GitHub Repository](https://github.com/AzuraCast/AzuraCast)
- [AzuraCast Discord Community](https://discord.gg/azuracast)
- [Home Assistant Community Forum](https://community.home-assistant.io/)

## Support

For issues specific to this Home Assistant add-on:
- GitHub Issues: [https://github.com/julienortscheid/azuracast-addon-ha/issues](https://github.com/julienortscheid/azuracast-addon-ha/issues)

For AzuraCast-specific questions:
- AzuraCast Support: [https://docs.azuracast.com/en/user-guide/troubleshooting](https://docs.azuracast.com/en/user-guide/troubleshooting)
