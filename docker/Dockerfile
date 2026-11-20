# OpenCode coding agent
# Debian 13 + standalone OpenCode binary

FROM debian:13

LABEL description="OpenCode coding agent environment"

# -----------------------------------------------------------------------------
# PRE-SETUP: DO NOT EDIT
# -----------------------------------------------------------------------------

# Host UID/GID to match, so files written to the mounted workspace stay yours
ARG HOST_UID=1000
ARG HOST_GID=1000
ENV HOST_UID=${HOST_UID} HOST_GID=${HOST_GID}
ARG OPENCODE_VERSION=2.3.2
# user creation
RUN groupadd -g "${HOST_GID}" agent && useradd -u "${HOST_UID}" -g agent -d /home/agent -m -s /bin/bash agent
# GWDG mirror (optional); comment out to use the default Debian mirror
RUN for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.sources; do [ -f "$f" ] || continue; sed -i -e 's|https\?://deb.debian.org/debian|http://ftp.gwdg.de/pub/linux/debian/debian|g' -e 's|https\?://security.debian.org/debian-security|http://ftp.gwdg.de/pub/linux/debian/debian-security|g' "$f"; done
# Install base packages
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl git && apt-get clean && rm -rf /var/lib/apt/lists/*
# Setup opencode 2 (globally)
RUN set -e; case "$(uname -m)" in x86_64) arch=x64 ;; aarch64|arm64) arch=arm64 ;; *) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;; esac; curl -fsSL -o /tmp/opencode.tar.gz "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-${arch}.tar.gz"; tar -xzf /tmp/opencode.tar.gz -C /usr/local/bin; rm /tmp/opencode.tar.gz; chmod 755 /usr/local/bin/opencode

# =============================================================================
# YOUR TOOLS
# Runs as root. Add your own RUN commands below.
# =============================================================================

# --- Office / document toolchain ---------------------------------------------
# libreoffice   real engine for docx/xlsx/pptx -> pdf (real pagination + filters)
# pandoc        md/html/rtf/odt/latex <-> docx/html
# poppler-utils pdftotext -layout, pdftoppm, pdfinfo, pdfunite, pdftocairo
# qpdf/gs       structural edits, compression, PDF/A; mupdf-tools = mutool
# tesseract     OCR; ocrmypdf makes scanned PDFs searchable
# fonts         the important part: metric-compatible substitutes avoid reflow
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TZ=UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
        libreoffice-writer libreoffice-calc libreoffice-impress \
        pandoc \
        poppler-utils poppler-data qpdf ghostscript mupdf-tools \
        tesseract-ocr tesseract-ocr-eng tesseract-ocr-deu tesseract-ocr-osd \
        ocrmypdf unpaper pngquant \
        imagemagick \
        fonts-liberation fonts-crosextra-carlito fonts-crosextra-caladea \
        fonts-dejavu-core fonts-urw-base35 fonts-noto-core fonts-noto-color-emoji \
        fonts-opensymbol \
        python3 python3-venv python3-pip \
        libpango-1.0-0 libpangoft2-1.0-0 libharfbuzz0b libfontconfig1 \
        unzip zip file \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# Notes:
#   * fonts-liberation = Arial/Times/Courier metrics; carlito/caladea = Calibri/Cambria.
#     Add fonts-noto-cjk (~300M) if CJK documents are common.
#   * Swap the three libreoffice-* packages for the *-nogui variants to save ~400M;
#     keep the GUI ones if conversion fidelity ever looks off.
#   * add libreoffice-java-common + default-jre-headless only if docs with
#     embedded OLE/SmartArt/WordArt fail to import.

# --- Python libs for authoring and inspecting office files --------------------
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir --upgrade pip wheel \
    && /opt/venv/bin/pip install --no-cache-dir \
        python-docx docxtpl python-pptx openpyxl xlsxwriter pandas \
        pypdf pymupdf pdfplumber pikepdf reportlab pillow \
        markdown beautifulsoup4 lxml jinja2 weasyprint
ENV PATH="/opt/venv/bin:${PATH}"

# --- Build-time smoke test (fails the build instead of failing at runtime) ----
RUN set -eux; \
    soffice --version; \
    pandoc --version | head -1; \
    pdftotext -v 2>&1 | head -1; \
    tesseract --list-langs; \
    python -c "import docx, openpyxl, pptx, pypdf, fitz, pdfplumber, pikepdf, reportlab, weasyprint; print('python ok')"; \
    printf '<h1>smoke</h1>' > /tmp/smoke.html; \
    soffice --headless --convert-to pdf --outdir /tmp /tmp/smoke.html; \
    test -s /tmp/smoke.pdf; \
    pdftotext /tmp/smoke.pdf - | grep -q smoke; \
    rm -f /tmp/smoke.*
# =============================================================================

# -----------------------------------------------------------------------------
# RUNTIME-SETUP: DO NOT EDIT
# -----------------------------------------------------------------------------
USER agent
WORKDIR /home/agent/workspace

RUN mkdir -p /home/agent/.config/opencode /home/agent/workspace/.agent-memory/share /home/agent/.local && ln -sf /home/agent/workspace/.agent-memory/share /home/agent/.local/share

ENV HOME=/home/agent WORKSPACE=/home/agent/workspace PATH="/home/agent/.local/bin:$PATH"

CMD ["/bin/bash"]
