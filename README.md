# ESPHome Dishwasher Controller

[![ESPHome](https://img.shields.io/badge/ESPHome-compatible-blue.svg)](https://esphome.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: ESP32](https://img.shields.io/badge/Platform-ESP32-green.svg)](https://www.espressif.com/en/products/socs/esp32)

A custom ESPHome configuration for controlling a dishwasher using an ESP32 with PCF8574 I/O expansion. This project provides a complete washing cycle with pre-wash, main wash, rinse, and optional heated drying phases, all controllable via Home Assistant.

## 🚀 Features

- **Complete Washing Cycle**: Pre-wash → Main Wash → Rinse → Optional Heated Dry
- **Home Assistant Integration**: Full API support with status monitoring
- **Safety First**: All relays default to OFF with proper interlocks
- **Flexible Configuration**: Optional heated wash and drying cycles
- **Real-time Status**: LED indicators and Home Assistant status updates
- **Manual Control**: Board button for manual cycle initiation
- **WiFi Fallback**: Captive portal for reliable connectivity

## 📋 Cycle Overview

| Phase | Duration | Description |
|-------|----------|-------------|
| Pre-Wash | 21m 54s | Initial cleaning with 3 sub-phases |
| Main Wash | 1h 2m 16s | Heavy cleaning with detergent dispensing |
| Pre-Rinse | 10m 57s | Initial rinse to remove soap residue |
| Final Rinse | 21m 12s | Final rinse with fresh water |
| Heated Dry (Optional) | 23m 45s | Heat-based drying cycle |

**Total Time**: 1h 42m 51s (without heated dry) or 2h 6m 36s (with heated dry)

## 🛠️ Hardware Requirements

### Essential Components
- **ESP32 Development Board** (e.g., ESP32-DevKitC)
- **PCF8574 I/O Expander** (I2C address 0x27)
- **6x 5V or 12V Relays** (with appropriate driver circuits)
- **Status LED** (built-in LED on GPIO23)
- **Push Button** (for manual control on GPIO0)

### Relay Connections
| PCF8574 Pin | Function | Relay Control |
|-------------|----------|---------------|
| P1 | Run Dishwasher | Main cycle control |
| P3 | Heat Element | Water heating |
| P4 | Circulation Pump | Water circulation |
| P5 | Drain Pump | Water draining |
| P6 | Fill Valve | Water filling |
| P7 | Detergent Dispenser | Soap release |

### I2C Connections
```
ESP32    PCF8574
GPIO2 → SDA
GPIO15 → SCL
5V → VCC
GND → GND
```

## 🔧 Installation

### Prerequisites
- [ESPHome](https://esphome.io/) installed
- [Home Assistant](https://www.home-assistant.io/) (recommended)
- Basic electronics knowledge

### Setup Steps

1. **Clone this repository**
   ```bash
   git clone https://github.com/[your-username]/esphome-dishwasher-controller.git
   cd esphome-dishwasher-controller
   ```

2. **Configure secrets**
   ```bash
   cp secrets.yaml.example secrets.yaml
   # Edit secrets.yaml with your WiFi and API credentials
   ```

3. **Hardware Assembly**
   - Connect ESP32 to PCF8574 via I2C
   - Wire relays to PCF8574 outputs
   - Connect dishwasher components to relays
   - Add push button to GPIO0
   - Connect status LED to GPIO23

4. **Upload Configuration**
   ```bash
   # Validate configuration
   esphome config dishwasher.yaml
   
   # Build and upload
   esphome upload dishwasher.yaml
   ```

5. **Add to Home Assistant**
   - The device should auto-discover in Home Assistant
   - Add the "Dishwasher Status" sensor to your dashboard
   - Create automations based on dishwasher states

## 📱 Home Assistant Integration

### Available Entities

| Entity | Type | Description |
|--------|------|-------------|
| Run Dishwasher | Switch | Start/stop washing cycle |
| Heated Wash | Switch | Enable heated drying option |
| Heat | Switch | Manual heat control |
| Circulate | Switch | Manual circulation control |
| Drain | Switch | Manual drain control |
| Fill | Switch | Manual fill control |
| Dispense | Switch | Manual detergent control |
| Dishwasher Status | Text Sensor | Current cycle phase |
| Dishwasher Uptime | Sensor | Device uptime |

### Example Automations

```yaml
# Notification when cycle completes
automation:
  - alias: "Dishwasher Complete Notification"
    trigger:
      platform: state
      entity_id: sensor.dishwasher_status
      to: "Standby"
      for: "00:00:10"
    action:
      service: notify.mobile_app
      data:
        message: "Dishwasher cycle is complete!"
        title: "Dishwasher 🍽️"
```

## ⚠️ Safety Considerations

### Electrical Safety
- **Always** use appropriate relay drivers for your relay voltage
- Ensure proper isolation between low-voltage and high-voltage circuits
- Include fuses and circuit breakers as needed
- Follow local electrical codes and regulations

### Water Safety
- Install water leak detectors near the dishwasher
- Use water-safe connectors and hoses
- Include overflow protection in your plumbing
- Test all connections before permanent installation

### Software Safety
- All relays default to `ALWAYS_OFF` for safety
- The abort routine provides emergency stop functionality
- WiFi fallback ensures reliable operation
- Manual override available via physical button

## 🔄 Advanced Configuration

### Customizing Cycle Times

Edit the timing values in the script sections:

```yaml
# Example: Change circulation time
- id: circ_alternate_240s
  then:
    - switch.turn_on: circ_sw
    - delay: 300s  # Changed from 240s to 300s
```

### Adding Temperature Monitoring

For enhanced safety and efficiency, add a temperature sensor:

```yaml
# Add to sensor section
- platform: max31865
  name: "Water Temperature"
  cs_pin: GPIO17
  # ... other configuration
```

### Energy Monitoring

Track power consumption with an energy monitor:

```yaml
# Add to sensor section
- platform: hlw8012
  name: "Dishwasher Power"
  # ... configuration
```

## 🐛 Troubleshooting

### Common Issues

| Problem | Solution |
|---------|----------|
| Device not connecting | Check WiFi credentials and range |
| Relays not working | Verify PCF8574 I2C connection (0x27) |
| Cycle not starting | Ensure all safety switches are OFF |
| Status not updating | Check Home Assistant API connection |

### Debug Mode

Enable verbose logging for troubleshooting:

```yaml
logger:
  level: DEBUG
  logs:
    component: DEBUG
```

### Factory Reset

If you need to reset the device:

```bash
esphome run dishwasher.yaml --device /dev/ttyUSB0 --erase-flash
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Guidelines

1. Follow the existing code style
2. Add comments for new features
3. Update documentation for any changes
4. Test thoroughly before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [ESPHome](https://esphome.io/) for the amazing firmware framework
- [Home Assistant](https://www.home-assistant.io/) for the home automation platform
- The ESPHome community for inspiration and support

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Search existing [GitHub Issues](https://github.com/[your-username]/esphome-dishwasher-controller/issues)
3. Create a new issue with detailed information
4. Join the [ESPHome Discord](https://discord.gg/KhAMKrd) for community support

---

**⚠️ Disclaimer**: This project involves controlling high-voltage appliances and water systems. Ensure you have the necessary knowledge and skills to work with these systems safely. The author is not responsible for any damage or injury resulting from the use of this project.

**🔧 Always test with a load lamp before connecting to actual dishwasher components!**