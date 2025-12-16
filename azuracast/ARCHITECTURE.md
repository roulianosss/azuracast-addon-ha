# Architecture Documentation

## Overview

This add-on provides a simplified, native integration of AzuraCast into Home Assistant, avoiding the complexity of Docker-in-Docker solutions.

## Design Philosophy

### Simple & Clean
- Direct service integration without nested containers
- Minimal privilege requirements
- Clear separation of concerns

### Native Integration
- Built-in Home Assistant sensor support
- Automatic monitoring and status reporting
- Uses Home Assistant's supervisor APIs

### Performance Optimized
- Single container for all services
- Efficient resource usage
- Fast startup and shutdown

## Architecture Components

```
┌─────────────────────────────────────────────────────┐
│           Home Assistant Add-on Container           │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌───────────────────────────────────────────┐    │
│  │         Supervisor (Process Manager)       │    │
│  └───────────────────────────────────────────┘    │
│           │                                         │
│           ├─► MariaDB (Database)                   │
│           │                                         │
│           ├─► PHP-FPM (Application Server)         │
│           │                                         │
│           ├─► Nginx (Web Server)                   │
│           │                                         │
│           ├─► Icecast (Streaming Server)           │
│           │                                         │
│           └─► HA Integration (Python Script)       │
│                                                     │
│  ┌───────────────────────────────────────────┐    │
│  │         Persistent Data (/data)            │    │
│  │  - Database files                          │    │
│  │  - Station configurations                  │    │
│  │  - Media uploads                           │    │
│  │  - Backups                                 │    │
│  └───────────────────────────────────────────┘    │
│                                                     │
└─────────────────────────────────────────────────────┘
         │                           │
         ▼                           ▼
    Web Interface              Home Assistant
   (Port 8080)                   Sensors
```

## Component Details

### 1. Supervisor
- Manages all services lifecycle
- Automatic restart on failures
- Centralized logging
- Priority-based startup

### 2. MariaDB Database
- Stores AzuraCast configuration and data
- Persistent storage in `/data/azuracast/db`
- Automatically initialized on first run
- Secure password generation

### 3. PHP-FPM + Nginx
- Serves AzuraCast web interface
- RESTful API endpoint
- Efficient FastCGI process manager
- Configurable ports

### 4. Icecast
- Streaming audio server
- Multiple station support
- Admin interface
- WebSocket support for real-time updates

### 5. Home Assistant Integration
- Python script monitoring AzuraCast
- Exposes sensors for:
  - System status
  - Station count
  - Listener statistics per station
  - Now playing information
- Polls every 30 seconds
- Automatic retry on failures

## Data Flow

### Station Broadcasting
```
Media Files → AzuraCast → Liquidsoap → Icecast → Listeners
```

### Home Assistant Integration
```
AzuraCast API → Python Monitor → Home Assistant Sensors
```

### Configuration Flow
```
Home Assistant UI → config.yaml → run.sh → Service Configuration
```

## Security Considerations

### Improvements Over Docker-in-Docker
- No `full_access` required
- Reduced privilege requirements
- No nested Docker daemon
- Smaller attack surface

### Current Security Features
- Random password generation
- Isolated database
- Local-only services by default
- Read-only SSL certificate access

### Recommendations
- Change default Icecast passwords
- Use strong MySQL passwords
- Enable HTTPS with Let's Encrypt
- Restrict port access via firewall

## Performance Characteristics

### Resource Requirements
- **RAM**: 1-2 GB minimum
- **CPU**: 1-2 cores recommended
- **Storage**: 5+ GB for media files
- **Network**: Depends on listener count

### Startup Time
- First start: 2-3 minutes (includes database initialization)
- Subsequent starts: 30-60 seconds

### Scaling
- Supports up to 10-20 concurrent stations
- Listener capacity depends on available resources
- Each station requires dedicated ports

## File Structure

```
/app/
├── run.sh                 # Main startup script
└── ha_integration.py      # Home Assistant integration

/data/azuracast/
├── db/                    # MariaDB database files
├── stations/              # Station configurations
├── uploads/               # Media files
├── backups/               # Backup files
└── logs/                  # Application logs

/var/www/azuracast/
└── [AzuraCast source code]

/etc/
├── nginx/
│   └── http.d/
│       └── azuracast.conf # Nginx configuration
├── supervisor/
│   └── conf.d/
│       └── azuracast.conf # Supervisor configuration
└── icecast.xml            # Icecast configuration
```

## Comparison with Docker-in-Docker Approach

### Original Approach (Docker-in-Docker)
**Pros:**
- Uses official AzuraCast containers
- Easier to maintain upstream compatibility

**Cons:**
- Requires `full_access: true` and elevated privileges
- Multiple layers of containerization
- Higher resource usage
- Complex networking
- Difficult to debug
- Security concerns

### New Approach (Native Integration)
**Pros:**
- Simpler architecture
- Better performance
- Reduced security risks
- Easier debugging
- Native Home Assistant integration
- Lower resource usage

**Cons:**
- Manual service management
- Requires maintaining component versions
- More initial setup complexity

## Future Enhancements

### Planned Features
1. **MQTT Integration**: Native MQTT discovery for sensors
2. **Webhook Support**: Real-time event notifications
3. **Backup Automation**: Integration with HA snapshot system
4. **Multi-language Support**: UI translations
5. **Advanced Monitoring**: Performance metrics and alerts

### Integration Ideas
- Automation triggers for listener thresholds
- Media upload via Home Assistant UI
- Station control from HA dashboard
- Text-to-speech announcements
- Schedule synchronization with HA calendar

## Troubleshooting

### Common Issues

**Services not starting:**
- Check logs: `/var/log/azuracast/`
- Verify disk space
- Check port conflicts

**Database connection errors:**
- Ensure MariaDB is running
- Verify credentials in `.env`
- Check database initialization

**Streaming not working:**
- Verify Icecast configuration
- Check station setup in AzuraCast
- Ensure media files are uploaded

**HA Integration not working:**
- Check Python script logs
- Verify AzuraCast API is accessible
- Restart ha-integration service

## Contributing

When contributing to this add-on, please:
1. Test on multiple architectures
2. Maintain backward compatibility
3. Update documentation
4. Follow security best practices
5. Add appropriate logging

## References

- [AzuraCast Documentation](https://docs.azuracast.com/)
- [Home Assistant Add-on Development](https://developers.home-assistant.io/docs/add-ons/)
- [Supervisor Documentation](http://supervisord.org/)
- [Icecast Documentation](https://icecast.org/docs/)
