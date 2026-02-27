# Chromatic

A headless Chrome instance on your private network, exposing the [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/) (CDP) for AI agents, Playwright, and automation scripts.

## Why This Exists

You might want to automate testing of a web-app, perhaps using a script or a computer-use agent. The usual options are all painful:

- Running Chrome locally will hog your laptop's RAM, especially if you're performing tests in-parallel.
- Running Chrome from the cloud against your local dev server is slow, fragile, and can lead to security risks (Ngrok).

This template puts headless Chrome on [Ambit](https://github.com/ToxicPine/ambit), so it lives on your private Tailscale network and is invisible to everyone else. 

Your agents and scripts connect to it by hostname, and strangers can't find it at all.

Since Ambit connects all your devices and cloud apps into the same private network, Chromatic can reach `http://localhost:3000` on your dev machine, or any service running in another Ambit app, without tunnels or port forwarding. CDP has no auth layer, so Ambit provides one at the network level instead.

## Setup

You can deploy OpenCode to [Ambit](https://github.com/ToxicPine/ambit), which wraps Fly.io.

```bash
npx skills add ToxicPine/ambit-skills --skill ambit-cli  # optional, but helpful for AI agents
npx @cardelli/ambit create lab
npx @cardelli/ambit deploy my-browser.lab --template ToxicPine/ambit-templates/chromatic
```

## (Beta) Use with Playwright MCP

[Playwright MCP](https://github.com/microsoft/playwright-mcp) gives your agents, including Claude Code, access to browser-use.

If you deploy Chromatic to `my-browser.lab`, your MCP settings should look like this:

{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "@playwright/mcp@latest",
        "--cdp-endpoint", "http://my-browser.lab:9222" // USE YOUR ACTUAL URL HERE.
      ]
    }
  }
}

## Connect

```javascript
// Puppeteer
const browser = await puppeteer.connect({
  browserWSEndpoint: 'ws://my-browser.lab:9222'
});

// Playwright
const browser = await chromium.connectOverCDP('http://my-browser.lab:9222');
```

## Default Specs (Configurable)

| | |
|---|---|
| CPU | 1x shared |
| Memory | 1 GB |
| Connection limit | 25 (hard), 20 (soft) |
| Auto stop | Suspend when idle |
| Auto start | Wake on CDP connection |

## Files

```
Dockerfile   — Alpine-based Chrome image
start.sh     — Chrome launch script with proxy support
fly.toml     — Fly.io deployment config (CDP on port 9222)
```
