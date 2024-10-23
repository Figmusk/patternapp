# Figma QR Code Generator Plugin

A beautiful and intuitive QR code generator plugin for Figma.

## Features
- Generate random QR codes with customizable colors
- Real-time preview
- Color picker with hex input
- Random color generation
- Various QR code patterns
- One-click randomization of all properties

## Installation Instructions

1. Download the plugin files
2. Open Figma and go to Plugins > Development > Import plugin from manifest
3. Select the manifest.json file from this project
4. The plugin will now be available in your Figma plugins menu

## Development

1. Clone the repository
2. Install dependencies: `npm install`
3. Start development server: `npm run dev`
4. Build for production: `npm run build`

## Building for Figma

1. Run `npm run build`
2. The built files will be in the `dist` directory
3. Use these files to create your Figma plugin

## Usage

1. Open Figma
2. Right-click > Plugins > QR Code Generator
3. Customize colors using the color pickers
4. Click "Generate QR Code" to add it to your canvas
5. Use the randomize buttons to experiment with different styles