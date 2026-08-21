import { createRequire } from 'node:module';
import { Readable } from 'stream';
import express from 'express';

const require = createRequire(__filename);
const { Upload } = require('graphql-upload');

type CommonContext = {
  withRequest: (
    req: unknown,
    res: unknown,
  ) => Promise<{
    session?: { itemId?: string };
    db: {
      Item: {
        findOne: (args: { where: { id: string } }) => Promise<{ postedById?: string | null } | null>;
        updateOne: (args: {
          where: { id: string };
          data: { photo: { upload: unknown } };
        }) => Promise<unknown>;
      };
    };
  }>;
};

function createUploadFromBuffer(buffer: Buffer, filename: string, mimetype: string) {
  const upload = new Upload();
  upload.resolve({
    createReadStream: () => Readable.from(buffer),
    filename,
    mimetype,
    encoding: 'utf-8',
  });
  return upload;
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

        const safeFilename =
          typeof filename === 'string' && filename.length > 0 ? filename : 'photo.jpg';
        const safeMimetype =
          typeof mimetype === 'string' && mimetype.length > 0 ? mimetype : 'image/jpeg';

        await context.db.Item.updateOne({
          where: { id: itemId },
          data: {
            photo: {
              upload: createUploadFromBuffer(buffer, safeFilename, safeMimetype),
            },
          },
        });

        res.json({ ok: true });
      } catch (error) {
        console.error('Photo upload failed', error);
        res.status(500).json({ error: String(error) });
      }
    },
  );
}
