# Dexcom G7 Tidbyt App

A Tidbyt application that displays real-time continuous glucose monitor (CGM) data from Dexcom G7/G6 devices on your Tidbyt LED display.

## Features

- 📊 Real-time glucose readings with trend arrows
- 🌍 Multi-region support (US, International, Japan)
- 🎨 Color-coded display based on glucose ranges
- ⏱️ Shows time since last reading
- 🔄 Automatic session management with retry logic
- 📝 Debug mode for troubleshooting
- 💾 Intelligent caching to minimize API calls

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
  - Outside US (Europe, Canada, etc.)
  - Japan

### Optional Settings
- **Units**: mg/dL or mmol/L
- **Show Trend Text**: Display trend description instead of time
- **Debug Mode**: Enable console output for troubleshooting

## Usage

### Test Locally
```bash
# Run with default settings
pixlet render dexcom_g7_pydexcom.star

# Test with debug output
pixlet render dexcom_g7_pydexcom.star debug=true

# Preview in browser
pixlet serve dexcom_g7_pydexcom.star
# Open http://localhost:8080
```

### Deploy to Tidbyt
```bash
pixlet push --api-token YOUR_TOKEN YOUR_DEVICE_ID dexcom_g7_pydexcom.star
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
- **Session ID**: 2 hours (Dexcom's typical session length)
- **Glucose Data**: 5 minutes (balance freshness vs API calls)

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
   pixlet render dexcom_g7_pydexcom.star debug=true
   ```
   Check console output for specific errors

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| Auth failed | Wrong credentials | Check username/password |
| No data available | No recent CGM readings | Check sensor is active |
| Session expired | Normal after 2 hours | App auto-retries |
| 500 Server Error | Wrong region selected | Try different region |
| Rate limited | Too many requests | Wait a few minutes |

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

## Files

- `dexcom_g7_pydexcom.star` - Main app (recommended)
- `dexcom_g7.star` - Original simpler version
- `dexcom_g7_oauth.star` - Version with OAuth placeholder
- `authentication_ideas.md` - Authentication documentation
- `http_guide.md` - HTTP module reference

## Security Notes

- Credentials are stored in Tidbyt's configuration system
- All API calls use HTTPS
- Session tokens expire automatically
- No data is stored permanently
- Consider using a follower account instead of primary

## Limitations

- Requires active Dexcom Share (not local CGM data)
- ~5 minute delay from actual glucose reading
- Depends on unofficial API (may break)
- Maximum 24 hours of historical data
- Updates minimum every 15 seconds on Tidbyt

## Contributing

Pull requests welcome! Please test changes with debug mode enabled.

## Disclaimer

This is an **unofficial** app not affiliated with Dexcom, Inc. Use at your own risk. Not for medical decisions.

## Credits

- Based on [pydexcom](https://github.com/gagebenne/pydexcom) by gagebenne
- Inspired by the Nightscout project
- Thanks to the diabetes tech community

## License

MIT License - See LICENSE file