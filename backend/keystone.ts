import { config } from '@keystone-6/core';
import { lists } from './schema';
import 'dotenv/config';

const databaseUrl = process.env.DATABASE_URL || 'file:./keystone.db';

export default config({
  db: {
    provider: 'sqlite',
    url: databaseUrl,
  },
  lists,
  storage: {
    local_images: {
      kind: 'local',
      type: 'image',
      generateUrl: path => `http://localhost:3000/images${path}`,
      serverRoute: { path: '/images' },
      storagePath: 'public/images',
    },
  },
  server: {
    cors: {
      origin: ['http://localhost:3000', 'http://localhost:8080', 'http://localhost:8081', 'http://127.0.0.1:8081'],
      credentials: true,
    },
  },
});