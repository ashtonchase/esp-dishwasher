# ESPHome Dishwasher Controller - Agent Guidelines

This is an ESPHome project for controlling a dishwasher via ESP32 with PCF8574 I/O expansion. The project uses YAML configuration with embedded Lambda C++ code for automation logic.

## Build and Development Commands

### ESPHome Commands
```bash
# Validate configuration (syntax check)
esphome config dishwasher.yaml

# Build firmware
esphome compile dishwasher.yaml

# Upload to device (USB)
esphome upload dishwasher.yaml

# Upload over WiFi (device must be online)
esphome upload dishwasher.yaml --device 192.168.2.197

# Clean build cache
esphome clean dishwasher.yaml

# Run with verbose logging
esphome --verbose compile dishwasher.yaml

# Show device logs
esphome logs dishwasher.yaml
```

### Testing and Validation
```bash
# Configuration validation (primary test)
esphome config dishwasher.yaml

# Dry run compilation (build test)
esphome compile --no-logs dishwasher.yaml

# Test specific components by checking logs
esphome logs dishwasher.yaml --level DEBUG
```

## Code Style Guidelines

### YAML Structure
- Use 2-space indentation (ESPHome standard)
- Alphabetize component sections where logical
- Group related components together
- Use descriptive IDs with snake_case naming
- Include comments for complex logic or hardware-specific configurations

### Component Organization
```yaml
# Standard order (follow this pattern):
esphome:                    # Device metadata
esp32:                      # Platform configuration
logger:                     # Logging setup
api:                        # Home Assistant integration
ota:                        # Over-the-air updates
wifi:                       # Network configuration
i2c:                        # I2C bus setup
spi:                        # SPI bus setup (if used)
text_sensor:               # Text-based sensors
sensor:                    # Numeric sensors
binary_sensor:             # Binary inputs
switch:                    # Output controls
output:                    # Raw outputs
light:                     # Lighting control
script:                    # Automation routines
```

### Naming Conventions
- **Component IDs**: snake_case (e.g., `dishwasher_i2c`, `board_status_led`)
- **Switch names**: Title Case with spaces (e.g., "Run Dishwasher", "Heat")
- **Script IDs**: snake_case with descriptive purpose (e.g., `drain_and_fill_routine`)
- **Sensor names**: Title Case (e.g., "Water Temperature", "Uptime")
- **GPIO references**: Use GPIOxx format (e.g., GPIO23, GPIO0)

### Import and Component Guidelines
- Always specify platform for components (e.g., `platform: gpio`)
- Use internal: true for diagnostic/utility components
- Include restore_mode for safety-critical switches
- Add appropriate icons from Material Design Icons (mdi:*)
- Use entity_category for organization (diagnostic, config)

### Lambda C++ Code Style
```yaml
# Lambda formatting:
- lambda: |-
    id(dw_state).publish_state("Standby");
    // Multi-line C++ code
    if (condition) {
        // Logic here
    }
```

### Error Handling and Safety
- All relay switches should have `restore_mode: ALWAYS_OFF` unless explicitly needed
- Use delayed_on/off filters for button debouncing
- Include proper delays between state changes (minimum 1s for relay protection)
- Add logging for state transitions and error conditions
- Use script.wait for sequential operations

### Hardware Configuration Patterns
```yaml
# PCF8574 I/O expansion pattern:
pin:
  pcf8574: pcf8574_hub
  number: 1
  mode:
    output: true
  inverted: true

# I2C configuration:
i2c:
  id: dishwasher_i2c
  sda: GPIO2
  scl: GPIO15
  frequency: 10khz
```

### Script and Automation Guidelines
- Use descriptive script IDs that reflect their purpose
- Include logging statements at key transition points
- Use script.execute and script.wait for sequential operations
- Break complex routines into reusable sub-scripts
- Include state updates via text_sensor for Home Assistant visibility

### WiFi and Network Configuration
- Use secrets.yaml for sensitive credentials
- Include fallback hotspot configuration
- Set static IP for reliable Home Assistant integration
- Add on_connect/on_disconnect handlers for status indication

### Documentation and Comments
- Comment hardware-specific configurations and pin mappings
- Document timing requirements for mechanical systems
- Include reference URLs for complex components
- Explain the purpose of custom scripts and automation logic

## Testing Strategy

### Configuration Testing
1. Always run `esphome config` before compilation
2. Validate YAML syntax and component references
3. Check for undefined IDs or missing dependencies

### Hardware Testing
1. Test individual components before complex automation
2. Use logging to verify script execution flow
3. Monitor device logs during operation
4. Verify safety interlocks and emergency stops

### Integration Testing
1. Test Home Assistant API connectivity
2. Verify OTA update functionality
3. Test WiFi fallback hotspot behavior
4. Validate all switch and sensor entities in HA

## Common Patterns

### Switch with Script Integration
```yaml
- platform: gpio
  id: "run_dw_sw"
  name: "Run Dishwasher"
  on_turn_on: 
    - script.execute: dishwasher_routine
  on_turn_off:
    - script.stop: dishwasher_routine
    - script.execute: abort_dishwasher_routine
```

### State Management
```yaml
text_sensor:
  - platform: template
    name: Status
    id: dw_state

# Update state in scripts:
- lambda: |-
    id(dw_state).publish_state("Main Wash");
```

### Safety-First Relay Control
```yaml
- platform: gpio
  name: "Heat"
  id: "heat_sw"
  restore_mode: ALWAYS_OFF
  pin:
    pcf8574: pcf8574_hub
    number: 3
    mode:
      output: true
    inverted: true
```

## Version Control

### Files to Track
- dishwasher.yaml (main configuration)
- secrets.yaml (if not containing sensitive data)
- Any custom component files

### Files to Ignore
- .esphome/ (build directory)
- .pioenvs/ (PlatformIO build files)
- Any compiled binaries