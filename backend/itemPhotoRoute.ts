import fs from 'fs';
import path from 'path';
import { randomBytes } from 'crypto';
import express from 'express';
import sizeOf from 'image-size';

type CommonContext = {
  withRequest: (
    req: unknown,
    res: unknown,
  ) => Promise<{
    session?: { itemId?: string };
    sudo: () => {
      prisma: {
        item: {
          update: (args: {
            where: { id: string };
            data: {
              photo_id: string;
              photo_extension: string;
              photo_filesize: number;
              photo_width: number;
              photo_height: number;
            };
          }) => Promise<unknown>;
        };
      };
    };
    db: {
      Item: {
        findOne: (args: { where: { id: string } }) => Promise<{ postedById?: string | null } | null>;
      };
    };
  }>;
};

const imagesDir = path.join(process.cwd(), 'public', 'images');

function ensureImagesDir() {
  if (!fs.existsSync(imagesDir)) {
    fs.mkdirSync(imagesDir, { recursive: true });
  }
}

function generatePhotoId() {
  return randomBytes(16).toString('hex');
}

export function registerItemPhotoRoute(app: any, commonContext: CommonContext) {
  app.post(
    '/rest/items/:id/photo',
    express.json({ limit: '10mb' }),
    async (req: any, res: any) => {
      try {
        const { imageBase64, filename, mimetype } = req.body ?? {};

        if (!imageBase64 || typeof imageBase64 !== 'string') {
          res.status(400).json({ error: 'imageBase64 is required' });
          return;
        }

        const buffer = Buffer.from(imageBase64, 'base64');
        if (buffer.length === 0) {
          res.status(400).json({ error: 'Invalid image data' });
          return;
        }

        const metadata = sizeOf(buffer);
        if (!metadata.width || !metadata.height || !metadata.type) {
          res.status(400).json({ error: 'Unsupported or invalid image format' });
          return;
        }

        const extension = metadata.type === 'jpg' ? 'jpg' : metadata.type;
        const allowed = new Set(['jpg', 'png', 'webp', 'gif']);
        if (!allowed.has(extension)) {
          res.status(400).json({ error: `Unsupported image type: ${extension}` });
          return;
        }

        const context = await commonContext.withRequest(req, res);
        if (!context.session?.itemId) {
          res.status(401).json({ error: 'Not authenticated' });
          return;
        }

        const itemId = String(req.params.id);
        const item = await context.db.Item.findOne({ where: { id: itemId } });

        if (!item) {
          res.status(404).json({ error: 'Item not found' });
          return;
        }

        if (item.postedById !== context.session.itemId) {
          res.status(403).json({ error: 'Only the item owner can upload a photo' });
          return;
        }

        const photoId = generatePhotoId();
        ensureImagesDir();
        fs.writeFileSync(path.join(imagesDir, `${photoId}.${extension}`), buffer);

        await context.sudo().prisma.item.update({
          where: { id: itemId },
          data: {
            photo_id: photoId,
            photo_extension: extension,
            photo_filesize: buffer.length,
            photo_width: metadata.width,
            photo_height: metadata.height,
          },
        });

        res.json({
          ok: true,
          photo: {
            id: photoId,
            extension,
            filename: typeof filename === 'string' ? filename : `${photoId}.${extension}`,
            mimetype: typeof mimetype === 'string' ? mimetype : `image/${extension}`,
          },
        });
      } catch (error) {
        console.error('Photo upload failed', error);
        res.status(500).json({ error: String(error) });
      }
    },
  );
}
