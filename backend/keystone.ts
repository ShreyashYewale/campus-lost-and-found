import { config } from '@keystone-6/core';
import { lists } from './schema';
import 'dotenv/config';

export default config({
  db: {
    provider: 'postgresql',
    url: 'process.env.DATABASE_URL',
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
    cors: { origin: ['http://localhost:3000', 'http://localhost:8080'], credentials: true },
  },
});