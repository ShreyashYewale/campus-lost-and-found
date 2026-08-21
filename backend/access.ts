type Session = {
  itemId?: string;
  listKey?: string;
  data?: {
    id?: string;
    name?: string;
  };
};

export const isLoggedIn = ({ session }: { session?: Session }) => !!session?.itemId;

export const isOwner = ({
  session,
  item,
}: {
  session?: Session;
  item?: { postedById?: string | null };
}) => !!session?.itemId && session.itemId === item?.postedById;

export const isClaimant = ({
  session,
  item,
}: {
  session?: Session;
  item?: { claimantId?: string | null };
}) => !!session?.itemId && session.itemId === item?.claimantId;

export const isNotificationRecipient = ({
  session,
  item,
}: {
  session?: Session;
  item?: { recipientId?: string | null };
}) => !!session?.itemId && session.itemId === item?.recipientId;

type AccessContext = {
  session?: Session;
  item?: { claimantId?: string | null; itemId?: string | null };
  context: {
    db: {
      Item: {
        findOne: (args: { where: { id: string } }) => Promise<{ postedById?: string | null } | null>;
      };
    };
  };
};

export const canUpdateClaim = async ({ session, item, context }: AccessContext) => {
  if (!session?.itemId || !item?.itemId) return false;

  const relatedItem = await context.db.Item.findOne({
    where: { id: String(item.itemId) },
  });

  return relatedItem?.postedById === session.itemId;
};
