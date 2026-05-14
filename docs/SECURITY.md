# Security & Hardening

Security configuration and hardening guide for the Advanced Coding Agent.

## Container Security

### Non-Root User

The container runs as a non-root user (`agent`) to limit potential damage:

```bash
# Inside container
whoami  # → agent
id      # → uid=1000(agent) gid=1000(agent)
```

### Read-Only Filesystem

Root filesystem is read-only. Only mounted volumes are writable:

```bash
# Test (should fail)
touch /etc/test  # ❌ Permission denied

# Allowed (writable mount)
touch /home/agent/workspace/projects/current/test  # ✅ Works
```

### Dropped Capabilities

All Linux capabilities are dropped except essentials:

```bash
# Check capabilities
cat /proc/1/status | grep Cap
```

### Resource Limits

```yaml
# Memory: 4GB max
mem_limit: 4g

# CPU: 2 cores max
cpus: 2

# PIDs: Prevent fork bombs
pids_limit: 100
```

### Network Isolation

By default, **no network access**:

```bash
# Should fail
curl https://api.openai.com  # ❌ Network unreachable

# Enable if needed (use carefully!)
docker run --network host ...  # ⚠️ Not recommended
```

---

## Filesystem Access Control

### Access Matrix

| Path | Access | Purpose |
|------|--------|---------|
| `/home/agent/workspace/projects/` | **RW** | Your mounted project |
| `/home/agent/workspace/docs/` | **RO** | Documentation |
| `/home/agent/workspace/temp/` | **RW** | Ephemeral workspace |
| `/home/agent/workspace/logs/` | **RW** | Agent logs |
| `/home/agent/.opencode/` | **RO** | Agent configuration |
| `/home/cloud/` | **❌** | No access (host system) |
| `/etc/` | **❌** | No access (system config) |
| `/var/` | **❌** | No access (system data) |
| `/root/` | **❌** | No access (root home) |

### Blocked Paths

```bash
# These paths are not accessible
/
/etc
/var
/root
/home/cloud
/sys
/dev
```

---

## Blocked Commands

The following commands are blocked by security rules:

### Destructive Commands
```bash
rm -rf /
dd
mkfs
fdisk
partition
```

### Permission Changes
```bash
chmod -R 777
chown -R root
```

### Privilege Escalation
```bash
sudo
su
passwd
```

### System Modifications
```bash
apt-get install
apt-get remove
apt-get purge
```

---

## Security Rules (agents.json)

```json
{
  "security": {
    "allowExternalCalls": false,
    "allowNetworkAccess": false,
    "blockedCommands": [
      "rm -rf /",
      "dd",
      "mkfs",
      "fdisk",
      "partition",
      "chmod -R 777",
      "chown -R root",
      "sudo",
      "su",
      "passwd"
    ]
  }
}
```

### Customizing Security Rules

**To allow network access (use carefully!):**

```json
{
  "security": {
    "allowNetworkAccess": true
  }
}
```

**To allow external API calls (use carefully!):**

```json
{
  "security": {
    "allowExternalCalls": true
  }
}
```

**To add custom blocked commands:**

```json
{
  "security": {
    "blockedCommands": [
      "rm -rf /",
      "dd",
      "your-custom-command"
    ]
  }
}
```

⚠️ **Warning:** Disabling security rules can expose your system to risks. Only do so if you understand the implications.

---

## API Key Security

### Never Commit API Keys

```bash
# ✅ Good: .env is in .gitignore
echo ".env" >> .gitignore

# ❌ Bad: Committing API keys
git add .env  # Never do this!
```

### Environment Variables

```bash
# Store in .env (not committed)
OPENCODE_API_KEY=sk-proj-xxx...
OPENCLAUDE_API_KEY=sk-ant-xxx...

# Load in shell
source .env
export OPENCODE_API_KEY
```

### Docker Secrets (Advanced)

For production use, consider Docker secrets:

```bash
# Create secret
echo "sk-proj-xxx..." | docker secret create api_key -

# Use in compose
services:
  agent:
    secrets:
      - api_key
    environment:
      - OPENCODE_API_KEY_FILE=/run/secrets/api_key
```

---

## Skill Security

### Enabled Skills

These skills are safe to enable:

| Skill | Risk Level | Notes |
|-------|------------|-------|
| `github` | 🟢 Low | Read-only by default |
| `git` | 🟢 Low | Local operations only |
| `fileops` | 🟡 Medium | Limited to workspace |
| `shell` | 🟡 Medium | Blocked commands enforced |
| `web` | 🟢 Low | Fetch only, no POST |
| `diffs` | 🟢 Low | Read-only |
| `session-logs` | 🟢 Low | Local logs only |
| `python` | 🟢 Low | Local execution |

### Disabled Skills

These skills require additional review:

| Skill | Risk Level | Reason |
|-------|------------|--------|
| `voice-call` | 🟠 High | External API calls |
| `browser-automation` | 🟠 High | Network access, TTY |

---

## Best Practices

### 1. Use Shell Aliases

```bash
# Add to ~/.bashrc
alias start-agent='/path/to/advanced-coding-agent/start-opencode.sh'
```

**Benefits:**
- ✅ Consistent configuration
- ✅ No manual path typing
- ✅ Reduces errors

### 2. Review Before Running

```bash
# Always review what you're about to run
cat start-opencode.sh
cat agents.json
cat tools.md
```

### 3. Use Read-Only Mounts

```bash
# For read-only projects
-v /path/to/project:/home/agent/workspace/projects/current:ro
```

### 4. Monitor Resource Usage

```bash
# Check container resources
docker stats advanced-coding-agent

# Check logs
docker logs -f advanced-coding-agent
```

### 5. Regular Updates

```bash
# Update base image periodically
docker build --no-cache -f Dockerfile.opencode -t advanced-coding-agent .

# Update skills
cd skills/matt-pocock && git pull
cd skills/addy-osmani && git pull
```

---

## Incident Response

### If Something Goes Wrong

1. **Stop the container immediately:**
   ```bash
   docker rm -f advanced-coding-agent
   ```

2. **Review logs:**
   ```bash
   docker logs advanced-coding-agent
   ```

3. **Check what changed:**
   ```bash
   git status
   git diff
   ```

4. **Report security issues:**
   - Open an issue in the repository
   - Do not share sensitive information publicly

---

## Compliance

### OWASP Top 10 Considerations

| Vulnerability | Mitigation |
|---------------|------------|
| A01: Broken Access Control | Non-root user, read-only filesystem |
| A02: Cryptographic Failures | API keys in env vars, not code |
| A03: Injection | Blocked dangerous commands |
| A04: Insecure Design | Security rules in agents.json |
| A05: Security Misconfiguration | Default secure settings |
| A06: Vulnerable Components | Regular updates |
| A07: Auth Failures | API key authentication |
| A08: Data Integrity | Read-only mounts |
| A09: Logging Failures | Container logs enabled |
| A10: SSRF | Network isolation |

---

## Related Documentation

- [Configuration Guide](CONFIGURATION.md)
- [Tools Reference](../tools.md)
- [Software Engineering Workflow](SOFTWARE_ENGINEERING_WORKFLOW.md)

---

**Security is everyone's responsibility.** Report issues responsibly.
