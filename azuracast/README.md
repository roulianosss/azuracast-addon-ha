# AzuraCast Add-on for Home Assistant

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armv7 Architecture][armv7-shield]

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg

## About

This add-on integrates [AzuraCast](https://www.azuracast.com/), a self-hosted web radio management suite, directly into Home Assistant. AzuraCast is a free and open-source platform that allows you to manage every aspect of your online radio station.

This implementation provides a clean, native integration without Docker-in-Docker complexity, offering better performance and security.

## Features

- Complete web radio management solution
- Multiple radio stations support
- Built-in streaming with Icecast support
- AutoDJ with smart playlist management
- Live broadcasting capabilities
- Listener statistics and analytics
- RESTful API for automation
- Web-based file manager
- Scheduled playlists
- Request system for listeners
- Native Home Assistant integration with automatic sensors
- Lightweight implementation without Docker-in-Docker
- Optimized for Home Assistant environment

## Installation

1. Add this repository to your Home Assistant add-on store
2. Install the "AzuraCast" add-on
3. Configure the add-on (see Configuration section)
4. Start the add-on
5. Access AzuraCast through the web interface

## Configuration

The add-on can be configured with the following options:

```yaml
AZURACAST_HTTP_PORT: 80
AZURACAST_HTTPS_PORT: 443
LETSENCRYPT_ENABLE: false
MYSQL_ROOT_PASSWORD: ""
MYSQL_USER: "azuracast"
MYSQL_PASSWORD: ""
MYSQL_DATABASE: "azuracast"
```

### Option: `AZURACAST_HTTP_PORT`

The HTTP port for the web interface. Default: `80`

### Option: `AZURACAST_HTTPS_PORT`

The HTTPS port for the web interface. Default: `443`

### Option: `LETSENCRYPT_ENABLE`

Enable Let's Encrypt SSL certificate generation. Default: `false`

### Option: `MYSQL_ROOT_PASSWORD`

MySQL root password. If left empty, a random password will be generated automatically.

### Option: `MYSQL_USER`

MySQL username for AzuraCast. Default: `azuracast`

### Option: `MYSQL_PASSWORD`

MySQL password for AzuraCast user. If left empty, a random password will be generated automatically.

### Option: `MYSQL_DATABASE`

MySQL database name. Default: `azuracast`

## Usage

1. After starting the add-on, access the web interface at `http://homeassistant.local:8080` (or the port you configured)
2. Follow the on-screen setup wizard to create your admin account
3. Create your first radio station
4. Upload music and configure playlists
5. Start broadcasting!

## Support

For issues with this Home Assistant add-on, please open an issue on the [GitHub repository](https://github.com/julienortscheid/azuracast-addon-ha).

For AzuraCast-specific questions, visit the [AzuraCast documentation](https://docs.azuracast.com/).

## Documentation

For more detailed documentation, see [DOCS.md](DOCS.md).

## License

MIT License - See LICENSE file for details

AzuraCast is licensed under the Apache License 2.0.
