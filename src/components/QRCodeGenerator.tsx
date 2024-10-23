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