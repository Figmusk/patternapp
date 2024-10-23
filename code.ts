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