// backend/schema.ts
import { list } from '@keystone-6/core';
import {
  text, relationship, timestamp, select, image, checkbox, password
} from '@keystone-6/core/fields';
import {
  isLoggedIn,
  isOwner,
  isClaimant,
  isNotificationRecipient,
  canUpdateClaim,
} from './access';
import { findMatchingItems, notifyMatch } from './matching';

export const lists = {
  User: list({
    access: {
      operation: {
        query: () => true,
        create: () => true,
        update: ({ session, item }) => session?.itemId === item.id,
        delete: ({ session, item }) => session?.itemId === item.id,
      },
    },
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
    access: {
      operation: {
        query: () => true,
        create: isLoggedIn,
        update: isOwner,
        delete: isOwner,
      },
    },
    hooks: {
      afterOperation: async ({ operation, item, context }) => {
        if (operation !== 'create' || !item) return;

        const matches = await findMatchingItems(context, {
          id: item.id,
          title: item.title as string,
          type: item.type as string,
          category: item.category as string,
          location: item.location as string,
          postedById: item.postedById as string | null | undefined,
        });

        for (const match of matches) {
          await notifyMatch(
            context,
            {
              id: item.id,
              title: item.title as string,
              type: item.type as string,
              category: item.category as string,
              location: item.location as string,
              postedById: item.postedById as string | null | undefined,
            },
            {
              id: match.id,
              title: match.title as string,
              type: match.type as string,
              category: match.category as string,
              location: match.location as string,
              postedById: match.postedById as string | null | undefined,
            }
          );
        }
      },
    },
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
    access: {
      operation: {
        query: isLoggedIn,
        create: isLoggedIn,
        update: canUpdateClaim,
        delete: isClaimant,
      },
    },
    hooks: {
      afterOperation: async ({ operation, item, context, originalItem }) => {
        if (operation === 'create' && item?.itemId) {
          const sudo = context.sudo();
          const relatedItem = await sudo.db.Item.findOne({
            where: { id: String(item.itemId) },
          });

          if (!relatedItem?.postedById) return;

          await sudo.db.Notification.createOne({
            data: {
              recipient: { connect: { id: relatedItem.postedById } },
              type: 'claim',
              message: `Someone submitted a claim on your item "${relatedItem.title}".`,
              relatedItem: { connect: { id: String(relatedItem.id) } },
            },
          });
          return;
        }

        if (operation !== 'update' || !item?.itemId || !item.claimantId) return;

        const nextStatus = item.status as string;
        const previousStatus = originalItem?.status as string | undefined;
        if (nextStatus === previousStatus) return;
        if (nextStatus !== 'approved' && nextStatus !== 'rejected') return;

        const sudo = context.sudo();
        const relatedItem = await sudo.db.Item.findOne({
          where: { id: String(item.itemId) },
        });
        if (!relatedItem) return;

        await sudo.db.Notification.createOne({
          data: {
            recipient: { connect: { id: String(item.claimantId) } },
            type: nextStatus === 'approved' ? 'claim_approved' : 'claim_rejected',
            message:
              nextStatus === 'approved'
                ? `Your claim on "${relatedItem.title}" was approved.`
                : `Your claim on "${relatedItem.title}" was rejected.`,
            relatedItem: { connect: { id: String(relatedItem.id) } },
          },
        });

        if (nextStatus === 'approved') {
          await sudo.db.Item.updateOne({
            where: { id: String(relatedItem.id) },
            data: { status: 'claimed' },
          });
        }
      },
    },
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
    access: {
      operation: {
        query: isLoggedIn,
        create: () => false,
        update: isNotificationRecipient,
        delete: isNotificationRecipient,
      },
      filter: {
        query: isNotificationRecipient,
      },
    },
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
