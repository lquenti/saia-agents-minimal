# Enable GitLab Pages

This guide explains how to enable GitLab Pages for the Advanced Coding Agent repository.

## Prerequisites

- Admin access to the GitLab repository
- GitLab Premium plan (or Pages enabled on your instance)

## Step 1: Enable GitLab Pages in Project Settings

1. Navigate to your repository on GitLab
2. Go to **Settings** → **Pages**
3. Under **Access level**, select:
   - **Private** - Only project members can access
   - **Enabled** - Anyone with the link can access
   - **Disabled** - Pages are not accessible
4. Click **Save changes**

## Step 2: Verify CI/CD Pipeline

The `.gitlab-ci.yml` file is already configured to:

1. Convert all `.md` files to HTML
2. Add navigation across all pages
3. Use GitHub Markdown CSS for styling
4. Deploy to `public/` directory

### Pipeline Stages

| Stage | Purpose |
|-------|---------|
| `build` | Test documentation builds (MR only) |
| `lint` | Check markdown syntax (MR only) |
| `deploy` | Deploy to GitLab Pages (default branch only) |

## Step 3: Trigger Pipeline

The pipeline automatically runs when you push to the default branch (`main`).

### Automatic Triggers

| Trigger | When | Jobs Run |
|---------|------|----------|
| Push to `main` | Code changes | `pages` (deploy) |
| Merge Request | MR created | `lint`, `build` |

### Manual Triggers

You can also manually trigger the pipeline:

#### Option 1: Run Full Pipeline Manually

1. Go to **CI/CD** → **Pipelines**
2. Click **Run pipeline**
3. Select branch: `main`
4. Click **Run pipeline**

This runs all jobs automatically.

#### Option 2: Selective Manual Jobs

For more control, you can choose specific jobs:

1. Go to **CI/CD** → **Pipelines**
2. Click **Run pipeline**
3. Select branch: `main`
4. **Toggle specific jobs** (click the play button next to each):
   - `manual_lint` - Check markdown syntax
   - `manual_build` - Build documentation
   - `manual_pages_deploy` - Deploy to Pages
5. Click **Run pipeline**

This is useful for:
- Testing changes before full deploy
- Running specific checks
- Re-deploying without code changes

### Using Pipeline Variables

You can also use variables to control behavior:

```bash
# In Run pipeline dialog:
Variable: MANUAL_LINT
Value: true

# This will run the lint job automatically
```

## Step 4: Access Your Pages

After the pipeline completes successfully:

1. Go to **Settings** → **Pages**
2. Find the **Pages URL** (format: `https://gitlab-ce.gwdg.de/jdecker/advanced-coding-agent/-/pages/`)
3. Click to view your documentation

## Troubleshooting

### Pipeline Fails

**Check the logs:**
1. Go to **CI/CD** → **Pipelines**
2. Click on the failed pipeline
3. Click on the `pages` job
4. Review the error message

**Common issues:**
- `npm install` fails → Check Node.js version in Docker image
- `public/` directory missing → Script creates it automatically
- HTML conversion fails → Check markdown syntax

### Pages Not Accessible

**Verify:**
1. Pipeline completed successfully (green checkmark)
2. GitLab Pages is enabled in Settings
3. Access level is not set to "Disabled"

**Re-deploy:**
1. Go to **CI/CD** → **Pipelines**
2. Run a new pipeline on `main` branch
3. Wait for `pages` job to complete

### Styling Issues

**Check:**
1. CDN is accessible (GitHub Markdown CSS)
2. Navigation links match your file names
3. HTML is valid (use validator)

## Custom Domain (Optional)

If you want to use a custom domain:

1. Go to **Settings** → **Pages**
2. Under **Custom domain**, enter your domain
3. Add CNAME record pointing to GitLab Pages
4. Click **Save changes**

## Update Documentation

When you update `.md` files:

1. Commit and push changes
2. Pipeline automatically runs
3. Pages update within 1-2 minutes

## Manual Build (Local Testing)

Test the conversion locally before pushing:

```bash
# Install dependencies
npm install -g markdown-it

# Run conversion
node scripts/convert-to-html.js

# View locally
cd public
python3 -m http.server 8080

# Open in browser
open http://localhost:8080
```

## Security Notes

- Pages are static HTML (no server-side code)
- Markdown is sanitized during conversion
- No external scripts are loaded (except CSS CDN)
- Sensitive information should not be in markdown files

## Support

- GitLab Pages documentation: https://docs.gitlab.com/ee/user/project/pages/
- CI/CD documentation: https://docs.gitlab.com/ee/ci/

---

**Next Steps:**
1. Enable Pages in Settings
2. Push `.gitlab-ci.yml` to trigger first build
3. Access your documentation via Pages URL
