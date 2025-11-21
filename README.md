# Dexcom G7 Tidbyt App

A Tidbyt application that displays real-time continuous glucose monitor (CGM) data from Dexcom G7/G6 devices on your Tidbyt LED display.

Inspired by [this Reddit post](https://www.reddit.com/r/dexcom/comments/1p0ibso/made_a_nixie_tube_display_for_my_blood_sugar/) about creating custom displays for blood sugar monitoring.

## Disclaimer

**The majority of this code was written with Claude (Anthropic's AI assistant) and has been reviewed and tested by JustinFay01, a professional Associate Software Developer at Vervint in Grand Rapids, MI.**

This is an **unofficial** app not affiliated with Dexcom, Inc. Use at your own risk. Not intended for medical decisions.

## Features

- 📊 Real-time glucose readings with trend arrows
- 🌍 Multi-region support (US, International, Japan)
- 🎨 Color-coded display based on glucose ranges
- ⏱️ Shows time since last reading with stale data detection
- 🔄 Automatic session management with retry logic
- 📝 Debug mode for troubleshooting
- 💾 Intelligent caching to minimize API calls
- 🧪 Unit tests for critical functions
- 📏 Large, bold text display for easy reading

## Display Information

The app shows your current glucose reading with visual indicators:

### Colors
- 🟢 **Green**: Normal range (70-180 mg/dL)
- 🔴 **Red**: Low glucose (<70 mg/dL) or urgent levels
- 🟠 **Orange**: High glucose (>180 mg/dL)
- ⚫ **Gray**: Stale data (>10 minutes old)

### Trend Arrows
- `↑↑` Double Up - Rising quickly
- `↑` Single Up - Rising
- `↗` Forty-Five Up - Rising slightly
- `→` Flat - Steady
- `↘` Forty-Five Down - Falling slightly
- `↓` Single Down - Falling
- `↓↓` Double Down - Falling quickly

## Prerequisites

- Tidbyt device
- Dexcom G7 or G6 CGM system
- Dexcom Share enabled (required!)
- Pixlet CLI for development

### Enable Dexcom Share

1. Open your Dexcom app
2. Go to Settings → Share
3. Enable sharing
4. Add at least one follower (this activates the Share service)

## Installation

1. Install Pixlet:
```bash
# macOS
brew install tidbyt/tidbyt/pixlet

# Or download from releases
# https://github.com/tidbyt/pixlet/releases
```

2. Clone or download this app:
```bash
git clone [your-repo]
cd tidbyt/dexcom
```

## Configuration

The app requires your Dexcom Share credentials and region:

### Required Settings
- **Username**: Your Dexcom Share username
- **Password**: Your Dexcom Share password
- **Region**: Select your server region:
  - United States (most common)
  - Outside US (Europe, Canada, etc.) *I have not tested since I live in the US*
  - Japan *I have not tested since I live in the US*

### Optional Settings
- **Units**: mg/dL or mmol/L
- **Show Trend Text**: Display trend description instead of time
- **Debug Mode**: Enable console output for troubleshooting

## Usage

### Test Locally
```bash
# Run with default settings
pixlet render dexcom_display.star

# Test with debug output
pixlet render dexcom_display.star debug=true

# Preview in browser
pixlet serve dexcom_display.star
# Open http://localhost:8080
```

### Deploy to Tidbyt
```bash
pixlet push --api-token YOUR_TOKEN YOUR_DEVICE_ID dexcom_display.star
```

## Implementation Details

This app is modeled after the [pydexcom](https://github.com/gagebenne/pydexcom) Python library and uses the unofficial Dexcom Share API.

### Authentication Flow
1. **Authenticate** → Get Account ID
2. **Login** → Get Session ID (using Account ID)
3. **Fetch Data** → Get glucose readings (using Session ID)

### API Endpoints
- Base URLs vary by region (US, International, Japan)
- Uses official Dexcom application IDs discovered by the community
- Implements automatic session refresh on expiry

### Caching Strategy
- **Account ID**: 24 hours (rarely changes)
- **Session ID**: 1 hour (conservative to avoid expired sessions)
- **Glucose Data**: 4 minutes (balance freshness vs API calls)

## Troubleshooting

### No Data Displayed

1. **Check Dexcom Share is enabled**
   - Must have at least one follower
   - Test with official Dexcom Follow app first

2. **Verify credentials**
   - Username is usually email address
   - Password is your Dexcom account password
   - NOT your follower's credentials

3. **Try different region**
   - US: Most common
   - Outside US: Europe, Canada, Australia
   - Japan: Japan only

4. **Enable debug mode**
   ```bash
   pixlet render dexcom_display.star debug=true
   ```
   Check console output for specific errors

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| Auth failed | Wrong credentials | Check username/password |
| No data available | No recent CGM readings | Check sensor is active |
| Session expired | Normal after 1 hour | App auto-retries |
| 500 Server Error | Wrong region selected | Try different region |
| Rate limited | Too many requests | Wait a few minutes |
| Stale data | API returning old data | Fixed with 10-min window |

### Debug Output

With debug mode enabled, you'll see:
```
Authenticating at: https://share2.dexcom.com/...
Auth response status: 200
Getting session from: https://share2.dexcom.com/...
Session response status: 200
Fetching glucose from: https://share2.dexcom.com/...
Glucose response status: 200
```

## Project Structure

```
dexcom/
├── dexcom_display.star       # Main app
├── tests/                     # Unit tests
│   ├── test_conversions.star # mmol/L conversion tests
│   ├── test_time_functions.star # Timestamp parsing tests
│   └── run_tests.sh          # Test runner script
└── README.md                 # This file
```

### Running Tests

Tests are written in pure Starlark and can be run with starlark-go:

```bash
# Install starlark-go (one time)
go install go.starlark.net/cmd/starlark@latest

# Run all tests
cd dexcom/tests
./run_tests.sh

# Or run individual tests
starlark test_conversions.star
starlark test_time_functions.star
```

## Security Notes

- Credentials are stored in Tidbyt's configuration system
- All API calls use HTTPS
- Session tokens expire automatically
- No data is stored permanently
- Consider using a follower account instead of primary

## Limitations

- Requires active Dexcom Share (not local CGM data)
- ~5 minute delay from actual glucose reading
- Depends on unofficial API (may break without notice)
- Maximum 10-minute data window to prevent stale data
- Updates minimum every 15 seconds on Tidbyt

## Contributing

Pull requests welcome! Please test changes with debug mode enabled.

## Disclaimer

This is an **unofficial** app not affiliated with Dexcom, Inc. Use at your own risk. Not for medical decisions.

## Credits

- Based on [pydexcom](https://github.com/gagebenne/pydexcom) by gagebenne
- Inspired by the Nightscout project and 
- Thanks to the diabetes tech community for reverse engineering the API
- [This Reddit post](https://www.reddit.com/r/dexcom/comments/1p0ibso/made_a_nixie_tube_display_for_my_blood_sugar/)

## License

MIT License - See LICENSE file