import fs from 'fs';
import multer from 'multer';
import os from 'os';

const upload = multer({
  dest: os.tmpdir(),
  limits: { fileSize: 10 * 1024 * 1024 },
});

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

export function registerItemPhotoRoute(app: any, commonContext: CommonContext) {
  app.post('/api/items/:id/photo', upload.single('photo'), async (req: any, res: any) => {
    const tempPath = req.file?.path as string | undefined;

    try {
      if (!req.file) {
        res.status(400).json({ error: 'Photo file is required' });
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

      // graphql-upload v15+ is ESM-only; import the Upload class from its subpath.
      const { default: Upload } = await import('graphql-upload/Upload.mjs');
      const fileUpload = new Upload();
      fileUpload.resolve({
        createReadStream: () => fs.createReadStream(tempPath!),
        filename: req.file.originalname || 'photo.jpg',
        mimetype: req.file.mimetype || 'image/jpeg',
      });

      await context.db.Item.updateOne({
        where: { id: itemId },
        data: {
          photo: { upload: fileUpload },
        },
      });

      res.json({ ok: true });
    } catch (error) {
      console.error('Photo upload failed', error);
      res.status(500).json({ error: String(error) });
    } finally {
      if (tempPath) {
        fs.unlink(tempPath, () => {});
      }
    }
  });
}
