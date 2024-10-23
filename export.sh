#!/bin/bash

# Create directory structure
mkdir -p figma-qr-generator/src/components/ui
mkdir -p figma-qr-generator/src/hooks
mkdir -p figma-qr-generator/src/lib

# Copy all required files
cat > figma-qr-generator/package.json << 'EOL'
{
  "name": "figma-qr-generator",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc -b && vite build",
    "build:figma": "vite build --outDir dist && tsc -p tsconfig.node.json",
    "lint": "eslint .",
    "preview": "vite preview"
  },
  "dependencies": {
    "@hookform/resolvers": "^3.9.0",
    "@radix-ui/react-accordion": "^1.2.0",
    "@radix-ui/react-alert-dialog": "^1.1.1",
    "@radix-ui/react-aspect-ratio": "^1.1.0",
    "@radix-ui/react-avatar": "^1.1.0",
    "@radix-ui/react-checkbox": "^1.1.1",
    "@radix-ui/react-collapsible": "^1.1.0",
    "@radix-ui/react-context-menu": "^2.2.1",
    "@radix-ui/react-dialog": "^1.1.1",
    "@radix-ui/react-dropdown-menu": "^2.1.1",
    "@radix-ui/react-hover-card": "^1.1.1",
    "@radix-ui/react-icons": "^1.3.0",
    "@radix-ui/react-label": "^2.1.0",
    "@radix-ui/react-menubar": "^1.1.1",
    "@radix-ui/react-navigation-menu": "^1.2.0",
    "@radix-ui/react-popover": "^1.1.1",
    "@radix-ui/react-progress": "^1.1.0",
    "@radix-ui/react-radio-group": "^1.2.0",
    "@radix-ui/react-scroll-area": "^1.1.0",
    "@radix-ui/react-select": "^2.1.1",
    "@radix-ui/react-separator": "^1.1.0",
    "@radix-ui/react-slider": "^1.2.0",
    "@radix-ui/react-slot": "^1.1.0",
    "@radix-ui/react-switch": "^1.1.0",
    "@radix-ui/react-tabs": "^1.1.0",
    "@radix-ui/react-toast": "^1.2.1",
    "@radix-ui/react-toggle": "^1.1.0",
    "@radix-ui/react-toggle-group": "^1.1.0",
    "@radix-ui/react-tooltip": "^1.1.2",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.1",
    "cmdk": "^1.0.0",
    "date-fns": "^3.6.0",
    "embla-carousel-react": "^8.3.0",
    "input-otp": "^1.2.4",
    "lucide-react": "^0.446.0",
    "next-themes": "^0.3.0",
    "qrcode": "^1.5.3",
    "react": "^18.3.1",
    "react-colorful": "^5.6.1",
    "react-dom": "^18.3.1",
    "react-hook-form": "^7.53.0",
    "react-resizable-panels": "^2.1.3",
    "recharts": "^2.12.7",
    "sonner": "^1.5.0",
    "tailwind-merge": "^2.5.2",
    "tailwindcss-animate": "^1.0.7",
    "vaul": "^1.0.0",
    "zod": "^3.23.8"
  },
  "devDependencies": {
    "@figma/plugin-typings": "^1.85.0",
    "@types/node": "^22.7.3",
    "@types/qrcode": "^1.5.5",
    "@types/react": "^18.3.9",
    "@types/react-dom": "^18.3.0",
    "@vitejs/plugin-react": "^4.3.1",
    "autoprefixer": "^10.4.20",
    "eslint": "^9.11.1",
    "eslint-plugin-react-hooks": "^5.1.0-rc.0",
    "eslint-plugin-react-refresh": "^0.4.12",
    "globals": "^15.9.0",
    "postcss": "^8.4.47",
    "tailwindcss": "^3.4.13",
    "typescript": "^5.5.3",
    "typescript-eslint": "^8.7.0",
    "vite": "^5.4.8"
  }
}
EOL

cat > figma-qr-generator/manifest.json << 'EOL'
{
  "name": "QR Code Generator",
  "id": "figma-qr-generator",
  "api": "1.0.0",
  "main": "code.js",
  "ui": "index.html",
  "editorType": ["figma"],
  "networkAccess": {
    "allowedDomains": ["none"]
  }
}
EOL

cat > figma-qr-generator/code.ts << 'EOL'
figma.showUI(__html__, {
  width: 400,
  height: 600,
});

figma.ui.onmessage = async (msg) => {
  if (msg.type === 'create-qr') {
    const nodes: SceneNode[] = [];
    
    try {
      const imageHash = figma.createImage(
        new Uint8Array(
          atob(msg.qrDataUrl.split(',')[1])
            .split('')
            .map((c) => c.charCodeAt(0))
        )
      );

      const rect = figma.createRectangle();
      rect.resize(300, 300);
      rect.fills = [
        {
          type: 'IMAGE',
          imageHash: imageHash.hash,
          scaleMode: 'FILL',
        },
      ];

      // Center the QR code in the viewport
      const center = figma.viewport.center;
      rect.x = center.x - rect.width / 2;
      rect.y = center.y - rect.height / 2;

      nodes.push(rect);
      figma.currentPage.selection = nodes;
      figma.viewport.scrollAndZoomIntoView(nodes);
    } catch (error) {
      figma.notify('Failed to create QR code', { error: true });
    }
  }
};
EOL

cat > figma-qr-generator/src/App.tsx << 'EOL'
import { QRCodeGenerator } from '@/components/QRCodeGenerator';
import { Toaster } from '@/components/ui/toaster';

function App() {
  return (
    <>
      <QRCodeGenerator />
      <Toaster />
    </>
  );
}

export default App;
EOL

cat > figma-qr-generator/src/components/QRCodeGenerator.tsx << 'EOL'
import { useState } from 'react';
import QRCode from 'qrcode';
import { HexColorPicker } from 'react-colorful';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import { useToast } from '@/hooks/use-toast';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { 
  Wand2, 
  Palette, 
  Link as LinkIcon, 
  RefreshCw,
  QrCode
} from 'lucide-react';

const patterns = [
  { id: 'dots-square', name: 'Dots Square', config: { dots: 'dots', type: 'square' } },
  { id: 'dots-rounded', name: 'Dots Rounded', config: { dots: 'dots', type: 'dots' } },
  { id: 'rounded-square', name: 'Rounded Square', config: { dots: 'rounded', type: 'square' } },
  { id: 'classy', name: 'Classy', config: { dots: 'classy', type: 'rounded' } },
  { id: 'classy-rounded', name: 'Classy Rounded', config: { dots: 'classy-rounded', type: 'dots' } },
];

export function QRCodeGenerator() {
  const [qrColor, setQrColor] = useState('#000000');
  const [qrBackground, setQrBackground] = useState('#FFFFFF');
  const [qrPreview, setQrPreview] = useState('');
  const [pattern, setPattern] = useState(patterns[0]);
  const [link, setLink] = useState('');
  const { toast } = useToast();

  const generateRandomColor = () => {
    return '#' + Math.floor(Math.random()*16777215).toString(16).padStart(6, '0');
  };

  const generateRandomPattern = () => {
    const randomIndex = Math.floor(Math.random() * patterns.length);
    setPattern(patterns[randomIndex]);
  };

  const generateQRCode = async () => {
    try {
      const qrText = link || Math.random().toString(36).substring(7);
      const qrDataUrl = await QRCode.toDataURL(qrText, {
        color: {
          dark: qrColor,
          light: qrBackground,
        },
        width: 300,
        margin: 1,
        type: 'image/png',
        quality: 1,
        ...pattern.config
      });

      setQrPreview(qrDataUrl);

      parent.postMessage(
        {
          pluginMessage: {
            type: 'create-qr',
            qrDataUrl,
          },
        },
        '*'
      );

      toast({
        title: 'Success',
        description: 'QR Code generated and added to Figma canvas!',
      });
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to generate QR code',
        variant: 'destructive',
      });
    }
  };

  const ColorPicker = ({ color, onChange, label }: { color: string; onChange: (color: string) => void; label: string }) => (
    <Popover>
      <PopoverTrigger asChild>
        <Button variant="outline" className="w-full justify-between">
          <div className="flex items-center gap-2">
            <div
              className="h-4 w-4 rounded-full border"
              style={{ backgroundColor: color }}
            />
            {label}
          </div>
          <Palette className="h-4 w-4" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-full p-0" align="start">
        <div className="p-3">
          <HexColorPicker color={color} onChange={onChange} />
          <Input
            value={color}
            onChange={(e) => onChange(e.target.value)}
            className="mt-2"
          />
        </div>
      </PopoverContent>
    </Popover>
  );

  return (
    <div className="p-4 max-w-md mx-auto">
      <Card className="p-6">
        <div className="space-y-6">
          <div className="flex justify-between items-center">
            <div className="flex items-center gap-2">
              <QrCode className="h-5 w-5" />
              <h2 className="text-lg font-semibold">QR Code Generator</h2>
            </div>
            <Button
              variant="outline"
              size="icon"
              onClick={() => {
                setQrColor(generateRandomColor());
                setQrBackground(generateRandomColor());
                generateRandomPattern();
                generateQRCode();
              }}
              title="Randomize All"
            >
              <RefreshCw className="h-4 w-4" />
            </Button>
          </div>

          <div className="space-y-4">
            <div className="space-y-2">
              <Label className="text-sm font-medium">Link (Optional)</Label>
              <div className="flex gap-2">
                <div className="relative flex-1">
                  <LinkIcon className="absolute left-3 top-2.5 h-4 w-4 text-muted-foreground" />
                  <Input
                    placeholder="Enter URL or text..."
                    value={link}
                    onChange={(e) => setLink(e.target.value)}
                    className="pl-9"
                  />
                </div>
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={() => setLink('')}
                  className="shrink-0"
                >
                  <RefreshCw className="h-4 w-4" />
                </Button>
              </div>
            </div>

            <div className="space-y-2">
              <Label className="text-sm font-medium">Pattern Style</Label>
              <div className="flex gap-2">
                <Select
                  value={pattern.id}
                  onValueChange={(value) => setPattern(patterns.find(p => p.id === value) || patterns[0])}
                >
                  <SelectTrigger className="flex-1">
                    <SelectValue placeholder="Select pattern" />
                  </SelectTrigger>
                  <SelectContent>
                    {patterns.map((p) => (
                      <SelectItem key={p.id} value={p.id}>
                        {p.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                <Button
                  variant="ghost"
                  size="icon"
                  onClick={generateRandomPattern}
                  className="shrink-0"
                >
                  <RefreshCw className="h-4 w-4" />
                </Button>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <ColorPicker
                  color={qrColor}
                  onChange={setQrColor}
                  label="QR Color"
                />
                <Button
                  variant="ghost"
                  size="sm"
                  className="w-full"
                  onClick={() => setQrColor(generateRandomColor())}
                >
                  <RefreshCw className="h-3 w-3 mr-2" />
                  Random
                </Button>
              </div>

              <div className="space-y-2">
                <ColorPicker
                  color={qrBackground}
                  onChange={setQrBackground}
                  label="Background"
                />
                <Button
                  variant="ghost"
                  size="sm"
                  className="w-full"
                  onClick={() => setQrBackground(generateRandomColor())}
                >
                  <RefreshCw className="h-3 w-3 mr-2" />
                  Random
                </Button>
              </div>
            </div>
          </div>

          <div className="flex justify-center">
            {qrPreview ? (
              <img
                src={qrPreview}
                alt="QR Code Preview"
                className="border rounded-lg p-2"
                style={{ width: '200px', height: '200px', objectFit: 'contain' }}
              />
            ) : (
              <div className="border rounded-lg p-2 w-[200px] h-[200px] flex items-center justify-center text-muted-foreground">
                Preview
              </div>
            )}
          </div>

          <Button
            className="w-full"
            size="lg"
            onClick={generateQRCode}
          >
            Generate QR Code
          </Button>
        </div>
      </Card>
    </div>
  );
}
EOL

cat > figma-qr-generator/README.md << 'EOL'
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
EOL

chmod +x export.sh