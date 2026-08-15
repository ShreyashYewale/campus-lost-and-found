import { config } from '@keystone-6/core';
import { lists } from './schema';
import { withAuth, session } from './auth';
import path from 'path';
import 'dotenv/config';

const databaseUrl = process.env.DATABASE_URL || 'file:./keystone.db';

export default withAuth(config({
  db: {
    provider: 'sqlite',
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
      origin: ['http://localhost:3000', 'http://localhost:8080', 'http://localhost:8081', 'http://localhost:127.0.0.1:8081'],
      credentials: true,
    },
  },
}));