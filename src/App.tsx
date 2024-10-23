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