// backend/schema.ts
import { list } from '@keystone-6/core';
import { allowAll } from '@keystone-6/core/access';
import {
  text, relationship, timestamp, select, image, checkbox, password
} from '@keystone-6/core/fields';

export const lists = {
  User: list({
    access: allowAll,
    fields: {
      name: text({ validation: { isRequired: true } }),
      email: text({ isIndexed: 'unique', validation: { isRequired: true } }),
      password: password(),
      items: relationship({ ref: 'Item.postedBy', many: true }),
      claims: relationship({ ref: 'Claim.claimant', many: true }),
      notifications: relationship({ ref: 'Notification.recipient', many: true }),
      createdAt: timestamp({ defaultValue: { kind: 'now' } }),
    },
  }),

  Item: list({
    access: allowAll,
    fields: {
      title: text({ validation: { isRequired: true } }),
      description: text({ ui: { displayMode: 'textarea' } }),
      type: select({
        options: [
          { label: 'Lost', value: 'lost' },
          { label: 'Found', value: 'found' },
        ],
        validation: { isRequired: true },
        db: { isNullable: false },
      }),
      category: select({
        options: [
          { label: 'Electronics', value: 'electronics' },
          { label: 'ID / Cards', value: 'id_cards' },
          { label: 'Keys', value: 'keys' },
          { label: 'Bags', value: 'bags' },
          { label: 'Books / Stationery', value: 'books' },
          { label: 'Clothing', value: 'clothing' },
          { label: 'Other', value: 'other' },
        ],
        validation: { isRequired: true },
      }),
      location: text({ validation: { isRequired: true } }),
      photo: image({ storage: 'local_images' }),
      status: select({
        options: [
          { label: 'Open', value: 'open' },
          { label: 'Claimed', value: 'claimed' },
          { label: 'Resolved', value: 'resolved' },
        ],
        defaultValue: 'open',
      }),
      dateOccurred: timestamp(),
      postedBy: relationship({ ref: 'User.items', many: false }),
      claims: relationship({ ref: 'Claim.item', many: true }),
      createdAt: timestamp({ defaultValue: { kind: 'now' } }),
    },
  }),

  Claim: list({
    access: allowAll,
    fields: {
      item: relationship({ ref: 'Item.claims', many: false }),
      claimant: relationship({ ref: 'User.claims', many: false }),
      message: text({ ui: { displayMode: 'textarea' } }),
      status: select({
        options: [
          { label: 'Pending', value: 'pending' },
          { label: 'Approved', value: 'approved' },
          { label: 'Rejected', value: 'rejected' },
        ],
        defaultValue: 'pending',
      }),
      createdAt: timestamp({ defaultValue: { kind: 'now' } }),
    },
  }),

  Notification: list({
    access: allowAll,
    fields: {
      recipient: relationship({ ref: 'User.notifications', many: false }),
      type: select({
        options: [
          { label: 'Possible Match', value: 'match' },
          { label: 'New Claim', value: 'claim' },
          { label: 'Claim Approved', value: 'claim_approved' },
          { label: 'Claim Rejected', value: 'claim_rejected' },
        ],
      }),
      message: text(),
      relatedItem: relationship({ ref: 'Item', many: false }),
      isRead: checkbox({ defaultValue: false }),
      createdAt: timestamp({ defaultValue: { kind: 'now' } }),
    },
  }),
};