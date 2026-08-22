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
} from './access';
import { findMatchingItems, notifyMatch } from './matching';
import { findPossibleDuplicate } from './duplicateCheck';
import { randomInt } from 'node:crypto';

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
      validateInput: async ({ operation, resolvedData, inputData, context, addValidationError }) => {
        // Only check on create, and only when the user hasn't chosen to override.
        if (operation !== 'create') return;
        if (inputData.allowDuplicate === true) return;

        const rawPostedBy =
          resolvedData.postedBy?.connect?.id ?? context.session?.itemId ?? null;
        const postedById = rawPostedBy != null ? String(rawPostedBy) : null;

        const duplicate = await findPossibleDuplicate(context, {
          title: (resolvedData.title as string) ?? '',
          type: (resolvedData.type as string) ?? '',
          category: (resolvedData.category as string) ?? '',
          location: (resolvedData.location as string) ?? '',
          postedById,
        });

        if (duplicate) {
          addValidationError(
            `You already posted a similar item: "${duplicate.title}". ` +
            `If this is a different item, set allowDuplicate: true to post it anyway.`
          );
        }
      },
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
      // When true, skips the duplicate-detection check for this post.
      allowDuplicate: checkbox({ defaultValue: false }),
      createdAt: timestamp({ defaultValue: { kind: 'now' } }),
    },
  }),

  Claim: list({
    access: {
      operation: {
        query: isLoggedIn,
        create: isLoggedIn,
        update: isLoggedIn,
        delete: isClaimant,
      },
    },
    hooks: {
      // When a claim is approved, generate a one-time password (OTP) that the
      // finder and claimant use to confirm the hand-over in person.
      resolveInput: async ({ operation, resolvedData, item }) => {
        if (
          operation === 'update' &&
          resolvedData.status === 'approved' &&
          item?.status !== 'approved'
        ) {
          const otp = String(randomInt(100000, 1000000));
          resolvedData.otpCode = otp;
          resolvedData.otpExpiresAt = new Date(Date.now() + 15 * 60 * 1000).toISOString();
          resolvedData.otpVerified = false;
        }
        return resolvedData;
      },
      afterOperation: async ({ operation, item, context }) => {
        const sudo = context.sudo();

        // On create: notify the item owner that a claim came in.
        if (operation === 'create' && item?.itemId) {
          const relatedItem = await sudo.db.Item.findOne({
            where: { id: String(item.itemId) },
          });
          if (relatedItem?.postedById) {
            await sudo.db.Notification.createOne({
              data: {
                recipient: { connect: { id: relatedItem.postedById } },
                type: 'claim',
                message: `Someone submitted a claim on your item "${relatedItem.title}".`,
                relatedItem: { connect: { id: String(relatedItem.id) } },
              },
            });
          }
        }

        // On approval: send the OTP to the claimant to prove identity at hand-over.
        if (operation === 'update' && item?.status === 'approved') {
          // Fetch the claim explicitly - claimantId / otpCode aren't always present
          // on the `item` object after an Admin UI status-only update, so we resolve
          // them from the stored claim record to be safe.
          const claim = await sudo.db.Claim.findOne({ where: { id: String(item.id) } });
          const claimantId = (claim as any)?.claimantId ?? item.claimantId ?? null;
          const otpCode = (claim as any)?.otpCode ?? item.otpCode ?? null;

          if (claimantId && otpCode) {
            await sudo.db.Notification.createOne({
              data: {
                recipient: { connect: { id: String(claimantId) } },
                type: 'claim_approved',
                message:
                  `Your claim was approved. Your collection OTP is ${otpCode}. ` +
                  `Show it to the finder to collect the item. It expires in 15 minutes.`,
                ...(item.itemId
                  ? { relatedItem: { connect: { id: String(item.itemId) } } }
                  : {}),
              },
            });
          }
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
      // --- OTP for in-person hand-over verification ---
      otpCode: text(),
      otpExpiresAt: timestamp(),
      otpVerified: checkbox({ defaultValue: false }),
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