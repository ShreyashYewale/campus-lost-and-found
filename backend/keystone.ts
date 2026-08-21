import { config } from '@keystone-6/core';
import { lists } from './schema';
import { withAuth, session } from './auth';
import { registerItemPhotoRoute } from './itemPhotoRoute';
import 'dotenv/config';

const databaseUrl = process.env.DATABASE_URL || 'file:./keystone.db';
const dbProvider = databaseUrl.startsWith('postgres') ? 'postgresql' : 'sqlite';

export default withAuth(config({
  db: {
    provider: dbProvider,
    url: databaseUrl,
  },
  lists,
  session,
  storage: {
    local_images: {
      kind: 'local',
      type: 'image',
      generateUrl: (filePath) => `http://localhost:3000/images${filePath}`,
      serverRoute: { path: '/images' },
      storagePath: 'public/images',
    },
  },
  server: {
    cors: {
      // Flutter web uses a random localhost port unless --web-port is set.
      origin: (
        origin: string | undefined,
        callback: (err: Error | null, allow?: boolean) => void,
      ) => {
        if (
          !origin ||
          /^https?:\/\/(localhost|127\.0\.0\.1|0\.0\.0\.0)(:\d+)?$/.test(origin)
        ) {
          callback(null, true);
          return;
        }
        callback(new Error(`Origin not allowed by CORS: ${origin}`));
      },
      credentials: true,
      allowedHeaders: [
        'Content-Type',
        'Authorization',
        'Apollo-Require-Preflight',
        'Accept',
        'X-Apollo-Operation-Name',
      ],
      methods: ['GET', 'POST', 'OPTIONS'],
    },
    extendExpressApp: (app, commonContext) => {
      registerItemPhotoRoute(app, commonContext);
    },
  },
}));