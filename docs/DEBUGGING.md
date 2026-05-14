# Debugging Guide

Troubleshooting and debugging the Advanced Coding Agent.

---

## Container Inspection

### Check Running Containers

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Filter by name
docker ps --filter "name=advanced-coding-agent"
```

### View Container Logs

```bash
# Live log stream
docker logs -f advanced-coding-agent

# Last 100 lines
docker logs --tail 100 advanced-coding-agent

# Timestamps
docker logs -t advanced-coding-agent

# Since specific time
docker logs --since 2024-01-01T00:00:00 advanced-coding-agent
```

### Enter Running Container

```bash
# Interactive bash shell
docker exec -it advanced-coding-agent /bin/bash

# Interactive bash shell (if bash not available)
docker exec -it advanced-coding-agent /bin/sh

# Run command directly
docker exec -it advanced-coding-agent whoami
docker exec -it advanced-coding-agent which uv
```

### Inspect Container Configuration

```bash
# Full JSON configuration
docker inspect advanced-coding-agent

# Specific field
docker inspect --format='{{.Config.Image}}' advanced-coding-agent
docker inspect --format='{{.State.Status}}' advanced-coding-agent
docker inspect --format='{{.Mounts}}' advanced-coding-agent
```

---

## Build Issues

### Docker Build Fails

**Check Dockerfile syntax:**

```bash
# Validate Dockerfile
docker build --dry-run -f Dockerfile.opencode .
```

**Check build context:**

```bash
# See what files are included
docker build -f Dockerfile.opencode --progress=plain . 2>&1 | grep "sending build context"
```

**Clean and rebuild:**

```bash
# Remove old image
docker rmi advanced-coding-agent

# Rebuild
./build-opencode.sh
```

### Image Not Found

**Problem:** `docker: Error response: image advanced-coding-agent:latest not found`

**Solution:**

```bash
# Build the image
./build-opencode.sh

# Or manually
docker build -f Dockerfile.opencode -t advanced-coding-agent .
```

### Build Too Slow

**Enable build cache:**

```bash
# Don't use --no-cache unless necessary
docker build -f Dockerfile.opencode -t advanced-coding-agent .

# Use buildx for better caching (optional)
docker buildx build -f Dockerfile.opencode -t advanced-coding-agent .
```

---

## Runtime Issues

### Container Exits Immediately

**Check logs:**

```bash
docker logs advanced-coding-agent
```

**Common causes:**

1. **Missing .env file**
   ```bash
   cp .env.example .env
   nano .env
   ```

2. **Invalid API key**
   ```bash
   # Check .env
   cat .env | grep API_KEY
   ```

3. **Port conflict**
   ```bash
   # Check if port is in use
   netstat -tlnp | grep 3111
   ```

### Agent Not Starting

**Check if process is running:**

```bash
docker exec advanced-coding-agent ps aux | grep opencode
docker exec advanced-coding-agent ps aux | grep openclaude
```

**Check environment variables:**

```bash
docker exec advanced-coding-agent env | grep MODEL
docker exec advanced-coding-agent env | grep API_KEY
```

### Skills Not Loading

**Verify skills exist:**

```bash
docker exec advanced-coding-agent ls -la /home/agent/.opencode/skills/
docker exec advanced-coding-agent ls -la /home/agent/.openclaude/skills/
```

**Check agents.json:**

```bash
docker exec advanced-coding-agent cat /home/agent/agents.json | jq '.skills'
```

---

## Performance Issues

### High Memory Usage

**Check container memory:**

```bash
docker stats advanced-coding-agent
```

**Solution:** Increase memory limit in `start-*.sh`

```bash
# Edit start-opencode.sh
# Change: --memory=4g
# To: --memory=8g
```

### Slow Startup

**Check image size:**

```bash
docker images advanced-coding-agent
```

**Solution:** Rebuild with smaller base or optimize Dockerfile

### Slow Agent Response

**Check model configuration:**

```bash
docker exec advanced-coding-agent env | grep MODEL
```

**Check network:**

```bash
docker exec advanced-coding-agent ping api.openai.com
```

---

## File System Issues

### Changes Not Persisting

**Check mount:**

```bash
docker inspect --format='{{.Mounts}}' advanced-coding-agent
```

**Verify workspace directory:**

```bash
docker exec advanced-coding-agent ls -la /home/agent/workspace/
```

**Solution:** Ensure you're mounting the correct directory

### Permission Denied

**Check container user:**

```bash
docker exec advanced-coding-agent whoami
docker exec advanced-coding-agent id
```

**Solution:** Run as agent user, not root

```bash
# In container
chown -R agent:agent /home/agent/workspace
```

---

## Network Issues

### API Connection Failed

**Test network connectivity:**

```bash
docker exec advanced-coding-agent ping 8.8.8.8
docker exec advanced-coding-agent curl -I https://api.openai.com
```

**Check network mode:**

```bash
docker inspect --format='{{.HostConfig.NetworkMode}}' advanced-coding-agent
```

**Solution:** Enable network if disabled

```bash
# Edit start-*.sh
# Remove: --network=none
```

### Proxy Issues

**Check proxy settings:**

```bash
docker exec advanced-coding-agent env | grep -i proxy
```

**Solution:** Add proxy to .env

```bash
HTTP_PROXY=http://proxy.example.com:8080
HTTPS_PROXY=http://proxy.example.com:8080
```

---

## Debug Mode

### Verbose Output

**Enable debug logging:**

```bash
# Add to .env
DEBUG=true
```

**Check container logs:**

```bash
docker logs -f advanced-coding-agent
```

### Shell Access

**Get shell in container:**

```bash
docker exec -it advanced-coding-agent /bin/bash

# Then debug manually
which opencode
opencode --version
cat /home/agent/.opencode/config.json
```

### Run Commands

**Execute specific commands:**

```bash
docker exec advanced-coding-agent opencode --help
docker exec advanced-coding-agent node --version
docker exec advanced-coding-agent python3 --version
docker exec advanced-coding-agent uv --version
```

---

## Common Error Messages

### "Cannot connect to Docker daemon"

```bash
# Linux
sudo systemctl start docker
sudo usermod -aG docker $USER

# macOS
# Open Docker Desktop

# Windows
# Open Docker Desktop
```

### "Permission denied while accessing /var/run/docker.sock"

```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or run with sudo (not recommended)
sudo ./start-opencode.sh
```

### "OCI runtime exec failed: exec failed"

```bash
# Container may have exited
docker ps -a

# Restart container
./start-opencode.sh
```

### "Error response from daemon: conflict"

```bash
# Container name conflict
docker rm advanced-coding-agent

# Or use different name
# Edit start-*.sh: --name advanced-coding-agent
```

---

## Diagnostic Script

**Create a diagnostic script:**

```bash
#!/bin/bash
# diagnostic.sh

echo "=== Docker Status ==="
docker info | head -20

echo ""
echo "=== Images ==="
docker images | grep advanced-coding-agent

echo ""
echo "=== Containers ==="
docker ps -a | grep advanced-coding-agent

echo ""
echo "=== Build Test ==="
docker build --dry-run -f Dockerfile.opencode . 2>&1 | tail -5

echo ""
echo "=== Environment ==="
cat .env | grep -E "(API_KEY|MODEL)"
```

---

## Getting Help

### Check Logs

```bash
# Container logs
docker logs advanced-coding-agent

# System logs
journalctl -u docker
```

### Check Configuration

```bash
# .env file
cat .env

# agents.json
cat agents.json

# tools.md
cat tools.md
```

### Verify Installation

```bash
# Docker version
docker --version

# Scripts executable
ls -la *.sh

# Required files
ls -la Dockerfile.* .env agents.json
```

---

## Related Documentation

- [Configuration Guide](CONFIGURATION.md) - API keys and models
- [Security Guide](SECURITY.md) - Container hardening
- [Usage Guide](USAGE.md) - Common usage patterns
- [Scripts Guide](SCRIPTS.md) - Build/start workflow

---

**WAAAGH! When things break, smash the problem!** 🪓👊
