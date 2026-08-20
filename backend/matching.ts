import { type KeystoneContext } from '@keystone-6/core/types';

type ItemRecord = {
  id: string | number;
  title: string;
  type: string;
  category: string;
  location: string;
  postedById?: string | null;
};

export async function findMatchingItems(
  context: KeystoneContext,
  item: ItemRecord
) {
  const oppositeType = item.type === 'lost' ? 'found' : 'lost';

  return context.db.Item.findMany({
    where: {
      AND: [
        { type: { equals: oppositeType } },
        { category: { equals: item.category } },
        { location: { equals: item.location } },
        { status: { equals: 'open' } },
        { id: { not: { equals: String(item.id) } } },
      ],
    },
  });
}

export async function notifyMatch(
  context: KeystoneContext,
  newItem: ItemRecord,
  existingItem: ItemRecord
) {
  const sudo = context.sudo();

  if (newItem.postedById) {
    await sudo.db.Notification.createOne({
      data: {
        recipient: { connect: { id: newItem.postedById } },
        type: 'match',
        message: `Possible match: "${existingItem.title}" may match your ${newItem.type} item "${newItem.title}".`,
        relatedItem: { connect: { id: String(existingItem.id) } },
      },
    });
  }

  if (existingItem.postedById) {
    await sudo.db.Notification.createOne({
      data: {
        recipient: { connect: { id: existingItem.postedById } },
        type: 'match',
        message: `Possible match: "${newItem.title}" may match your ${existingItem.type} item "${existingItem.title}".`,
        relatedItem: { connect: { id: String(newItem.id) } },
      },
    });
  }
}
