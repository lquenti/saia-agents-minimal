# Gitlawb Opengateway Setup for OpenClaude

## Configuration

To use Gitlawb Opengateway with OpenClaude, add these lines to your `.env` file:

```bash
# Gitlawb Opengateway Configuration
OPENCLAUDE_API_KEY=your_actual_gitlawb_api_key_here
MODEL=mimo-v2.5-pro
OPENAI_BASE_URL=https://opengateway.gitlawb.com/v1
```

## Steps

1. **Get your API key** from Gitlawb Opengateway
2. **Edit `.env`** file in the project root:
   ```bash
   nano .env
   ```
3. **Uncomment and update** the Gitlawb section:
   ```bash
   # Replace this line:
   # OPENCLAUDE_API_KEY=your_gitlawb_api_key_here
   
   # With your actual key:
   OPENCLAUDE_API_KEY=sk-ant-your-actual-key-here
   ```
4. **Restart the container**:
   ```bash
   sudo ./start-openclaude.sh
   ```

## Verify Configuration

After starting the container, check that the correct provider is configured:

```bash
# Inside the container
openclaude providers list
```

You should see:
```
│ Provider  Gitlawb Opengateway │
│ Model     mimo-v2.5-pro       │
│ Endpoint  https://opengateway.gitlawb.com/v1 │
```

## Troubleshooting

### "Using default provider" message
- Check that `OPENCLAUDE_API_KEY` is set (not commented out)
- Verify `OPENAI_BASE_URL` is set correctly
- Restart the container after changes

### Connection errors
- Verify your API key is correct
- Check network connectivity to `https://opengateway.gitlawb.com`
- Ensure the container has network access (no `--network none`)

### Wrong model
- Confirm `MODEL=mimo-v2.5-pro` is set
- Check that the model is available on Gitlawb Opengateway

## Security Notes

- **Never commit `.env` to git** - it's in `.gitignore` for a reason
- **Store API keys securely** - consider using a secrets manager
- **Rotate keys regularly** - follow security best practices
