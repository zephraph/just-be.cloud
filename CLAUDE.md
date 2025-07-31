# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Smallweb project - a file-based hosting platform where each subfolder becomes a subdomain. Apps are written as simple modules that export a `fetch` function or static files.

- **Runtime**: Deno 2.4.1 (configured in `mise.toml`)
- **Framework**: Smallweb (https://www.smallweb.run)
- **Architecture**: File-based hosting with instant deployment
- **No build process**: Changes are live immediately

## Project Structure

```
.
├── .smallweb/config.json    # Smallweb configuration (domain, auth)
├── mise.toml                # Deno runtime version
├── example/main.ts          # Example app with fetch handler
└── www/index.md            # Static markdown content
```

## Development Commands

### Starting the Server
```bash
smallweb up                  # Start smallweb server
```

### App Management
```bash
smallweb list               # List all apps
smallweb open <app>         # Open app in browser
smallweb run <app> [args]   # Run app CLI command
```

### Testing and Type Checking
```bash
deno test                   # Run tests (searches for *test.ts files)
deno check **/*.ts          # Type check TypeScript files
```

### Configuration
```bash
smallweb config             # Open config file
smallweb doctor             # Check system for issues
```

## App Development

### Dynamic Apps
Create `main.ts` with exported `fetch` function:
```typescript
export default {
    fetch: (req: Request) => {
        return new Response("Hello!");
    },
    run: (args: string[]) => {
        console.log("CLI command");
    },
};
```

### Static Apps
- Use `index.html` or `index.md` for static content
- Folders without entry points serve static files

### Subdomain Mapping
- Each subfolder becomes a subdomain
- `example/` → `example.localhost` (or configured domain)
- Use `.smallweb/config.json` to set custom domain

## Configuration Files

### .smallweb/config.json
```json
{
  "domain": "localhost",
  "authorizedKeys": [],
  "authorizedEmails": []
}
```

### App-specific (optional)
Create `smallweb.json` in app directory for custom configuration.